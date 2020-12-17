import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:hive/hive.dart';
import 'package:indigo24/db/country_dao.dart';
import 'package:indigo24/db/country_model.dart';
import 'package:indigo24/pages/auth/restore_password.dart';
import 'package:indigo24/pages/chat/chat_models/chat_model.dart';
import 'package:indigo24/pages/chat/chat_models/hive_names.dart';
import 'package:indigo24/pages/chat/chat_models/messages_model.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_auth_title.dart';
import 'package:indigo24/pages/tabs/tabs.dart';
import '../countries.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Api _api;
  TextEditingController loginController;
  TextEditingController passwordController;
  bool _obscureText;
  var _singInResult;
  int countryId;
  var country;
  List countries;
  var phonePrefix = '77';

  String _currentCountry;
  String loginError;
  String passwordError;
  CountryDao _countryDao;

  var length;
  @override
  void initState() {
    super.initState();
    _obscureText = true;
    loginController = TextEditingController();
    passwordController = TextEditingController();
    countries = List<Country>();
    countryId = 0;
    _currentCountry = "Казахстан";
    loginError = "";
    passwordError = "";

    _api = Api();
    _countryDao = CountryDao();
    _getCountries().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    loginController.dispose();
    passwordController.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0),
        child: AppBar(
          centerTitle: true,
          backgroundColor: whiteColor,
          brightness: Brightness.light,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: introBackgroundProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            _buildForeground()
          ],
        ),
      ),
    );
  }

  _getCountries() async {
    var list = await _countryDao.getAll();
    setState(() {
      countries = list;
      country = countries[countryId];
      _selectedCountry = country;
      length = country.length;
    });
  }

  Widget _buildForeground() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    topLeft: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    _space(10),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Row(
                        children: <Widget>[
                          InkWell(
                            child: Ink(
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    '$_currentCountry',
                                    style: TextStyle(
                                      color: greyColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    child: Icon(
                                      Icons.navigate_next,
                                      color: greyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: changeCountry,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          IndigoAuthTitle(title: localization.phoneNumber),
                          Stack(
                            alignment: Alignment.centerLeft,
                            children: <Widget>[
                              Text(
                                '+$phonePrefix',
                                style: TextStyle(
                                  color: blackPurpleColor,
                                  fontSize: 16,
                                ),
                              ),
                              TextField(
                                controller: loginController,
                                inputFormatters: [
                                  phonePrefix != null
                                      ? length != null
                                          ? LengthLimitingTextInputFormatter(
                                              length - phonePrefix.length)
                                          : LengthLimitingTextInputFormatter(
                                              100)
                                      : LengthLimitingTextInputFormatter(100),
                                ],
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: blackPurpleColor,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  focusColor: blackColor,
                                  fillColor: blackColor,
                                  hoverColor: blackColor,
                                  prefixText: '1$phonePrefix ',
                                  prefixStyle:
                                      TextStyle(color: transparentColor),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$loginError',
                            style: TextStyle(
                              color: redColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          _space(30),
                          IndigoAuthTitle(title: localization.password),
                          TextField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            style: TextStyle(
                              color: blackPurpleColor,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: '********',
                              hintStyle: TextStyle(
                                color: blackPurpleColor,
                                fontSize: 16,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Image(
                                    image: AssetImage(
                                      _obscureText
                                          ? 'assets/images/eyeClose.png'
                                          : 'assets/images/eyeOpen.png',
                                    ),
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _space(10),
                          Text(
                            '$passwordError',
                            style: TextStyle(
                                color: redColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _space(15),
                    FlatButton(
                      child: Text(
                        '${localization.forgotPassword}?',
                        style: TextStyle(
                          color: greyColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestorePasswordPage(),
                          ),
                        );
                      },
                    ),
                    _space(0),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ProgressButton(
                        defaultWidget: Text(
                          "${localization.next}",
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        progressWidget: CircularProgressIndicator(),
                        borderRadius: 10.0,
                        color: primaryColor,
                        onPressed: () async {
                          if (passwordController.text.isEmpty) {
                            setState(() {
                              passwordError = '${localization.enterPassword}';
                            });
                          } else {
                            setState(() {
                              passwordError = '';
                            });
                          }
                          int prefixLength =
                              _selectedCountry.phonePrefix.length;

                          int controllerLength = prefixLength +
                              loginController.text.replaceAll(" ", '').length;

                          int minLength = _selectedCountry.min;
                          int maxLength = _selectedCountry.max;

                          if (controllerLength >= minLength &&
                              controllerLength <= maxLength) {
                            setState(() {
                              loginError = '';
                            });
                          } else {
                            print('else');
                            setState(() {
                              loginError = '${localization.enterPhone}';
                            });
                          }
                          if (passwordController.text.isNotEmpty &&
                              controllerLength >= minLength &&
                              controllerLength <= maxLength) {
                            setState(() {
                              loginError = '';
                              passwordError = '';
                            });
                            await _api
                                .signIn("$phonePrefix${loginController.text}",
                                    passwordController.text)
                                .then((response) async {
                              _singInResult = response;
                              if ('${response['success']}' == 'true') {
                                Hive.box<MessageModel>(HiveBoxes.messages)
                                    .clear();
                                Hive.box<ChatModel>(HiveBoxes.chats).clear();
                                await _api.getBalance();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => Tabs(),
                                  ),
                                  (r) => false,
                                );
                              } else {
                                setState(() {
                                  passwordError = _singInResult["message"];
                                });
                              }
                            });
                          }
                        },
                      ),
                    ),
                    _space(50),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Country _selectedCountry;

  Future<void> changeCountry() async {
    _selectedCountry = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Countries(countries),
      ),
    );

    if (_selectedCountry != null)
      setState(() {
        _currentCountry = _selectedCountry.title;
        phonePrefix = _selectedCountry.phonePrefix;
        length = _selectedCountry.length;
        passwordController.text = '';
        loginController.text = '';
      });
  }

  _space(double h) {
    return Container(
      height: h,
    );
  }
}
