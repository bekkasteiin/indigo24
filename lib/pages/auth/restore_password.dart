import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/db/country_dao.dart';
import 'package:indigo24/db/country_model.dart';
import 'package:indigo24/pages/auth/login/login.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/backgrounds.dart';

import 'countries.dart';

class RestorePasswordPage extends StatefulWidget {
  @override
  _RestorePasswordPageState createState() => _RestorePasswordPageState();
}

class _RestorePasswordPageState extends State<RestorePasswordPage> {
  var api = Api();
  TextEditingController _loginController;
  TextEditingController _passwordController;
  var countryId = 0;
  var country;
  var countries = List<Country>();
  var phonePrefix = '77';
  var smsCode = 0;
  List<DropdownMenuItem<String>> dropDownMenuItems;
  String _currentCountry = "Казахстан";

  CountryDao _countryDao = CountryDao();
  var length;
  _getCountries() async {
    var list = await _countryDao.getAll();
    setState(() {
      countries = list;
      country = countries[countryId];
      length = country.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
    _getCountries();
  }

  @override
  void dispose() {
    super.dispose();
    _loginController.dispose();
    _passwordController.dispose();
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
        body: Stack(
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
        ));
  }

  Future<void> _showError(BuildContext context, m, type) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: type == 0
              ? Text('${localization.error}')
              : Text('${localization.success}'),
          content: Text(m),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                if (type == 1)
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                      (r) => false);
              },
            ),
          ],
        );
      },
    );
  }

  var _selectedCountry;

  Future<void> changeCountry() async {
    _selectedCountry = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Countries(countries)),
    );

    if (_selectedCountry != null)
      setState(() {
        _currentCountry = _selectedCountry.title;
        phonePrefix = _selectedCountry._phonePrefix;
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
                // height: MediaQuery.of(context).size.height*0.4,
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
                    _space(30),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Row(
                        children: <Widget>[
                          InkWell(
                            child: Ink(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text('$_currentCountry ',
                                      style: TextStyle(
                                          color: blackPurpleColor,
                                          fontSize: 18)),
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
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("${localization.phoneNumber}",
                                  style: TextStyle(
                                      color: blackPurpleColor, fontSize: 16))
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
                                controller: _loginController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
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
                        ],
                      ),
                    ),
                    _space(30),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ProgressButton(
                        defaultWidget: Text("${localization.next}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w300)),
                        progressWidget: CircularProgressIndicator(),
                        borderRadius: 10.0,
                        color: primaryColor,
                        onPressed: () async {
                          await api
                              .restorePassword(
                                  phonePrefix + _loginController.text)
                              .then((restorePasswordResponse) async {
                            if (restorePasswordResponse['success'] == true) {
                              _showError(context,
                                  restorePasswordResponse['message'], 1);
                            } else {
                              _showError(context,
                                  restorePasswordResponse['message'], 0);
                            }
                          });
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

  _space(double h) {
    return Container(
      height: h,
    );
  }
}
