import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/db/country_dao.dart';
import 'package:indigo24/db/country_model.dart';
import 'package:indigo24/pages/auth/login/login.dart';
import 'package:indigo24/pages/auth/registration/registration.dart';
import 'package:indigo24/pages/chat/chat_page_view_test.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/widgets/custom_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  Api _api;
  CountryDao _countryDao;
  int _tempCounter = 0; // TODO FIX REMOVE
  @override
  void initState() {
    super.initState();
    _api = Api();
    _countryDao = CountryDao();
    _getCountries();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                    image: introBackgroundProvider, fit: BoxFit.cover),
              ),
            ),
            SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _space(size.height / 2.5),
                    _signInButton(size),
                    _space(10),
                    _signUpButton(size),
                    Container(
                      child: InkWell(
                        child: Container(
                          height: 20,
                          width: 100,
                        ),
                        onTap: () async {
                          _tempCounter++;
                          if (_tempCounter == 9) {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            String _domen3 = preferences.getString('domen');
                            print(_tempCounter);
                            print('$_domen3');
                            if ('$_domen3' == null) {
                              preferences.setString('domen', 'com');
                            } else {
                              if ('$_domen3' == 'xyz') {
                                preferences.setString('domen', 'com');
                              } else {
                                preferences.setString('domen', 'xyz');
                              }
                            }
                            // exit(0); // TODO TURN ON THIS
                          }
                        },
                      ),
                    ),
                    _space(size.height / 3),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: Container(
                          child: CustomDropdownButton(
                            isExpanded: false,
                            hint: Text("${localization.currentLanguage}",
                                style: TextStyle(color: blackPurpleColor)),
                            items: localization.languages.map((value) {
                              return DropdownMenuItem(
                                child: Text('${value['title']}',
                                    style: TextStyle(color: blackPurpleColor)),
                                value: value,
                              );
                            }).toList(),
                            onChanged: (value) {
                              localization.setLanguage(value['code']);
                              setState(() {
                                localization.currentLanguage =
                                    '${value['title']}';
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    FlatButton(
                      child: Text(
                        "${localization.terms}",
                        style: TextStyle(color: brightGreyColor),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewer('assets/terms.pdf'),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  _getCountries() async {
    await _api.getCountries().then((response) async {
      print("getCountries false is it? $response");
      if (response == false) {
        dioError(context);
      } else {
        response['countries'].forEach((element) async {
          Country country = Country(
            element['ID'],
            element['length'],
            element['title'],
            element['prefix'],
            element['code'],
            element['mask'],
            element['icon'],
          );
          await _countryDao.updateOrInsert(country);
        });
      }
    });
  }

  _space(double h) {
    return Container(
      height: h,
    );
  }

  _signInButton(Size size) {
    return ButtonTheme(
      minWidth: size.width * 0.75,
      height: 60,
      child: RaisedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        child: Text(
          '${localization.login}',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
        ),
        color: whiteColor,
        textColor: blackPurpleColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
      ),
    );
  }

  _signUpButton(Size size) {
    return ButtonTheme(
      minWidth: size.width * 0.75,
      height: 60,
      child: RaisedButton(
        onPressed: () {
          print('Register is pressed');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrationPage(),
            ),
          );
        },
        child: Text(
          '${localization.registration}',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
        ),
        color: whiteColor.withOpacity(0.35),
        textColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
      ),
    );
  }
}
