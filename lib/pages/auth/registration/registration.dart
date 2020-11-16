import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/db/country_dao.dart';
import 'package:indigo24/db/country_model.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/widgets/indigo_square.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../countries.dart';
import 'phone_confirm.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

int start = 0;
Timer _timer;

get tamer => _timer;

class _RegistrationPageState extends State<RegistrationPage> {
  var api = Api();
  TextEditingController loginController;
  TextEditingController passwordController;
  var countryId = 0;
  var country;
  var countries = new List<Country>();
  var smsCode = 0;
  List<DropdownMenuItem<String>> dropDownMenuItems;
  String _currentCountry = "Казахстан";
  String loginError = "";

  var mask;
  var loginFormatter;
  String _hintText = '+77';
  var length;
  CountryDao countryDao = CountryDao();
  var _selectedCountry;

  bool isPageOpened = true;

  Color timerColor = primaryColor;

  @override
  void initState() {
    super.initState();
    if (start != 59) {
      startTimer();
    }
    loginController = TextEditingController();
    passwordController = TextEditingController();
    _getCountries();
  }

  @override
  void dispose() {
    super.dispose();
    isPageOpened = false;
    _timer = null;
    loginController.dispose();
    passwordController.dispose();
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
                    image: introBackgroundProvider, fit: BoxFit.cover),
              )),
              _buildForeground()
            ],
          ),
        ));
  }

  _getCountries() async {
    var list = await countryDao.getAll();
    setState(() {
      countries = list;
      _selectedCountry = countries[0];
      _currentCountry = countries[0].title;
      loginFormatter = MaskTextInputFormatter(
          mask: '${_selectedCountry.mask}', filter: {"*": RegExp(r'[0-9]')});
      country = countries[countryId];
      length = country.length;
    });
  }

  Future<void> changeCountry() async {
    _selectedCountry = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Countries(countries)),
    );
    if (_selectedCountry != null)
      setState(() {
        _currentCountry = _selectedCountry.title;
        _hintText = _selectedCountry.mask;
        loginFormatter = MaskTextInputFormatter(
            mask: '${_selectedCountry.mask}', filter: {"*": RegExp(r'[0-9]')});
        length = _selectedCountry.length;
        loginController.text = '';
      });
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    if (_timer == null) {
      _timer = Timer.periodic(oneSec, (Timer timer) {
        if (isPageOpened) {
          setState(() {
            if (start < 1) {
              timer.cancel();
              _timer = null;
            } else {
              start = start - 1;
            }
          });
        } else {
          if (start < 1) {
            timer.cancel();
          } else {
            start = start - 1;
          }
        }
      });
    }
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
                                  Text(
                                    '$_currentCountry ',
                                    style: TextStyle(
                                      color: blackPurpleColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Container(
                                    child: Icon(
                                      Icons.navigate_next,
                                      color: blackPurpleColor,
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
                              IndigoSquare(),
                              SizedBox(width: 10),
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
                              TextField(
                                controller: loginController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                                inputFormatters: [
                                  loginFormatter,
                                ],
                                decoration: InputDecoration(
                                  hintText: '$_hintText',
                                  focusColor: Colors.black,
                                  fillColor: Colors.black,
                                  hoverColor: Colors.black,
                                  prefixStyle: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$loginError',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _space(30),
                    Text(
                      '${start != 0 ? start : ''}',
                      style: TextStyle(
                        color: timerColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _space(30),
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
                          if (start == 0) {
                            if (loginController.text.isNotEmpty) {
                              var temp = loginController.text
                                  .replaceAll(' ', '')
                                  .replaceAll('+', '');
                              if (temp.length == length) {
                                await api
                                    .checkRegistration(temp)
                                    .then((checkPhoneResult) async {
                                  if (checkPhoneResult['success'] == false) {
                                    await api
                                        .sendSms(temp)
                                        .then((sendSmsResult) {
                                      setState(() {
                                        start = 59;
                                      });
                                      startTimer();
                                      if (sendSmsResult['success'] == true) {
                                        setState(() {
                                          loginError = '';
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PhoneConfirmPage(
                                              sendSmsResult['pin'],
                                              temp,
                                            ),
                                          ),
                                        );
                                      } else {
                                        setState(() {
                                          loginError = sendSmsResult['message'];
                                        });
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      loginError =
                                          '${checkPhoneResult['message']}';
                                    });
                                  }
                                });
                              } else {
                                setState(() {
                                  loginError = '${localization.enterPhone}';
                                });
                              }
                            } else {
                              setState(() {
                                loginError = '${localization.enterPhone}';
                              });
                            }
                          } else {
                            setState(() {
                              if (timerColor == primaryColor) {
                                timerColor = redColor;
                                Future.delayed(const Duration(seconds: 2), () {
                                  timerColor = primaryColor;
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

  _space(double h) {
    return Container(
      height: h,
    );
  }
}
