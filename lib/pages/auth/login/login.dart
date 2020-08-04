import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/restore_password.dart';
import 'dart:convert';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/backgrounds.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var api = Api();
  TextEditingController loginController;
  TextEditingController passwordController;
  bool _obscureText = true;
  var singInResult;
  var countryId = 0;
  var country;
  var countries = new List<Country>();
  var _countries;
  var phonePrefix = '77';
  List _titles = [];
  String _currentCountry = "Казахстан";
  String loginError = "";
  String passwordError = "";
  var length;
  _getCountries() async {
    await api.getCountries().then((response) {
      print('some response $response');
      if (response == false) {
        dioError(context);
      } else {
        setState(() {
          print("MY RESPONSE $response");
          Iterable list = response['countries'];
          List<dynamic> responseJson = response['countries'].toList();
          countries = list.map((model) => Country.fromJson(model)).toList();
          _countries = jsonDecode(jsonEncode(responseJson));
          for (var i = 0; i < _countries.length; i++) {
            _titles.add(_countries[i]['title']);
          }
          country = _countries[countryId];
          length = country['length'];
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List titles) {
    List<DropdownMenuItem<String>> items = List();
    for (var i = 0; i < titles.length; i++) {
      items.add(DropdownMenuItem(value: titles[i], child: Text(titles[i])));
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    loginController = TextEditingController();
    passwordController = TextEditingController();
    _getCountries();
  }

  Future<void> showError(BuildContext context, m) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('${localization.error}'),
          content: Text(m),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
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
                  color: Colors.white,
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
                                    '$_currentCountry ',
                                    style: TextStyle(
                                      color: blackPurpleColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: Image(
                                      width: 15,
                                      height: 15,
                                      image: AssetImage(
                                        'assets/images/dropDown.png',
                                      ),
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
                          Row(
                            children: <Widget>[
                              Text(
                                "${localization.phoneNumber}",
                                style: TextStyle(
                                  color: blackPurpleColor,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                          Stack(
                            alignment: Alignment.centerLeft,
                            children: <Widget>[
                              Text(
                                '+$phonePrefix',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
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
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  focusColor: Colors.black,
                                  fillColor: Colors.black,
                                  hoverColor: Colors.black,
                                  prefixText: '1$phonePrefix ',
                                  prefixStyle:
                                      TextStyle(color: Colors.transparent),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$loginError',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          _space(30),
                          Row(
                            children: <Widget>[
                              Text(
                                "${localization.password}",
                                style: TextStyle(
                                  color: blackPurpleColor,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                          TextField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: '•••••••',
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
                                color: Colors.red,
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
                        '${localization.forgotPassword}',
                        style: TextStyle(color: darkGreyColor),
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
                    _space(20),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ProgressButton(
                        defaultWidget: Text(
                          "${localization.next}",
                          style: TextStyle(
                            color: Colors.white,
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
                          if (loginController.text.isEmpty ||
                              '$phonePrefix${loginController.text}'.length !=
                                  length) {
                            setState(() {
                              loginError = '${localization.enterPhone}';
                            });
                          } else {
                            setState(() {
                              loginError = '';
                            });
                          }
                          if (passwordController.text.isNotEmpty &&
                              '$phonePrefix${loginController.text}'.length ==
                                  length) {
                            setState(() {
                              loginError = '';
                              passwordError = '';
                            });
                            await api
                                .signIn("$phonePrefix${loginController.text}",
                                    passwordController.text)
                                .then((response) async {
                              singInResult = response;
                              print("LOGIN RESULT $response");
                              if ('${response['success']}' == 'true') {
                                await api.getBalance();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => Tabs(),
                                  ),
                                  (r) => false,
                                );
                              } else {
                                setState(() {
                                  passwordError = singInResult["message"];
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

  var _selectedCountry;

  Future<void> changeCountry() async {
    _selectedCountry = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Countries(_countries)),
    );

    if (_selectedCountry != null)
      setState(() {
        _currentCountry = _selectedCountry['title'];
        phonePrefix = _selectedCountry['prefix'];
        length = _selectedCountry['length'];
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

class Countries extends StatelessWidget {
  final countries;
  Countries(this.countries);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(10),
            child: Image(
              image: AssetImage(
                'assets/images/back.png',
              ),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        brightness: Brightness.light,
        title: Text(
          "${localization.country}",
          style: TextStyle(
            color: blackPurpleColor,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ListView.separated(
            itemCount: countries.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                child: Container(
                  height: 20,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    '${countries[index]['title']}',
                    style: TextStyle(
                      color: blackPurpleColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop(countries[index]);
                },
              );
            },
            separatorBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(left: 20),
                height: 0.2,
                color: Colors.black,
              );
            },
          ),
        ),
      ),
    );
  }
}

class Country {
  int id;
  String title;
  String phonePrefix;
  String code;

  Country(int id, String name, String phonePrefix, String code) {
    this.id = id;
    this.title = name;
    this.phonePrefix = phonePrefix;
    this.code = code;
  }

  Country.fromJson(Map json)
      : id = json['id'],
        title = json['name'],
        phonePrefix = json['phonePrefix'],
        code = json['code'];

  Map toJson() {
    return {'id': id, 'title': title, 'phonePrefix': phonePrefix, 'code': code};
  }
}
