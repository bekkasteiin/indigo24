import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/db/country_dao.dart';
import 'package:indigo24/db/country_model.dart';
import 'package:indigo24/pages/auth/login/login.dart';
import 'package:indigo24/pages/auth/registration/registration.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/widgets/document/pdf_viewer.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

bool isLanguageSelected = false;

class _IntroPageState extends State<IntroPage> {
  Api _api;
  CountryDao _countryDao;
  int _tempCounter = 0;

  _showLanguages() {
    Size size = MediaQuery.of(context).size;
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: size.width * 0.5,
        height: size.width * 0.8,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              child: Text('${localization.selectOption}'),
            ),
            Container(
              height: 1,
              width: size.width,
              color: blackColor,
            ),
            Flexible(
              child: ListView.separated(
                padding: EdgeInsets.all(0),
                shrinkWrap: false,
                itemCount: localization.languages.length,
                itemBuilder: (BuildContext context, int index) {
                  return FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${localization.languages[index]['title']}'),
                        Text('${localization.languages[index]['code']}'),
                      ],
                    ),
                    onPressed: () {
                      isLanguageSelected = true;
                      setState(() {
                        localization
                            .setLanguage(localization.languages[index]['code']);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Container(
                  height: 1,
                  width: size.width,
                  color: blackColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return errorDialog;
      },
    );
  }

  // _showNews(dynamic result) {
  //   Size size = MediaQuery.of(context).size;
  //   Dialog errorDialog = Dialog(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12.0),
  //     ),
  //     child: Container(
  //       width: size.width * 0.5,
  //       height: size.width * 0.8,
  //       child: Column(
  //         children: <Widget>[
  //           Container(
  //             margin: EdgeInsets.all(10),
  //             child: Text('${localization.selectOption}'),
  //           ),
  //           Container(
  //             height: 1,
  //             width: size.width,
  //             color: blackColor,
  //           ),
  //           Flexible(
  //             child: ListView.separated(
  //               padding: EdgeInsets.all(0),
  //               shrinkWrap: false,
  //               itemCount: localization.languages.length,
  //               itemBuilder: (BuildContext context, int index) {
  //                 return FlatButton(
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: <Widget>[
  //                       Text('${result['args']}'),
  //                     ],
  //                   ),
  //                   onPressed: () async {
  //                     Navigator.pop(context);
  //                   },
  //                 );
  //               },
  //               separatorBuilder: (BuildContext context, int index) =>
  //                   Container(
  //                 height: 1,
  //                 width: size.width,
  //                 color: blackColor,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return errorDialog;
  //     },a
  //   );
  // }
  bool hided = true;
  @override
  void initState() {
    super.initState();
    getDomen().then((result) {
      setState(() {
        _domen3 = '$result';
      });
    });
    _api = Api();
    _countryDao = CountryDao();
    _getCountries();
    _initPackageInfo();

    Future.delayed(Duration.zero, () {
      if (!isLanguageSelected) _showLanguages();
    });
    // _api.getNews().then((result) async {
    //   SharedPreferences preferences = await SharedPreferences.getInstance();

    //   int showedCount = preferences.getInt('newsShowedCount');
    //   if (showedCount == null) {
    //     showedCount = 1;
    //     preferences.setInt('newsShowedCount', showedCount);
    //   }
    //   if (showedCount < 3) {
    //     showedCount++;
    //     preferences.setInt('newsShowedCount', showedCount);
    //     _showNews(result);
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  PackageInfo _packageInfo = PackageInfo();

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  String _domen3;

  getDomen() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String domen = preferences.getString('domen');
    return domen;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: whiteColor,
      child: SafeArea(
        child: Scaffold(
            backgroundColor: transparentColor,
            body: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: introBackgroundProvider, fit: BoxFit.cover),
                  ),
                ),
                AppBar(
                  backgroundColor: transparentColor,
                  elevation: 0,
                  centerTitle: true,
                  title: FittedBox(
                    child: GestureDetector(
                      onTap: () async {
                        _tempCounter++;
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        if (_tempCounter == 9) {
                          if ('$_domen3' == null) {
                            preferences.setString('domen', 'com');
                          } else {
                            if ('$_domen3' == 'xyz') {
                              preferences.setString('domen', 'com');
                            } else {
                              preferences.setString('domen', 'xyz');
                            }
                          }
                        }
                      },
                      child: Text(
                        '${localization.appVersion} ${_packageInfo.version}:${_packageInfo.buildNumber}',
                        style: TextStyle(
                          color: _domen3 == 'xyz' ? redColor : milkWhiteColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Image.asset(
                              'assets/images/intro_logo.png',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _signInButton(size),
                              SizedBox(height: 10),
                              _signUpButton(size),
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 0,
                                ),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(6.0),
                                  ),
                                ),
                                child: Container(
                                  width: 100,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () => setState(
                                          () {
                                            hided = !hided;
                                          },
                                        ),
                                        child: Container(
                                          color: transparentColor,
                                          child: Row(
                                            children: [
                                              Transform.rotate(
                                                angle: hided ? pi * 2 : pi,
                                                child: Image.asset(
                                                  'assets/images/dropDown.png',
                                                  width: 15,
                                                  height: 15,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                "${localization.currentLanguage}",
                                                style: TextStyle(
                                                  color: blackPurpleColor,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 120),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              for (var language
                                                  in localization.languages)
                                                GestureDetector(
                                                  onTap: () => setState(
                                                    () {
                                                      hided = !hided;
                                                      localization.setLanguage(
                                                        language['code'],
                                                      );
                                                      localization
                                                              .currentLanguage =
                                                          '${language['title']}';
                                                    },
                                                  ),
                                                  child: Container(
                                                    height: 30,
                                                    width: 100,
                                                    color: transparentColor,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          '${language['code']}',
                                                          textAlign:
                                                              TextAlign.justify,
                                                          style: TextStyle(
                                                            color: primaryColor,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${language['title']}',
                                                          textAlign:
                                                              TextAlign.justify,
                                                          style: TextStyle(
                                                            color:
                                                                blackPurpleColor,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        height: hided ? 0 : size.height * 0.15,
                                      )
                                    ],
                                  ),
                                ),
                              )
                              // Container(
                              //   height: 30,

                              //   child: Directionality(
                              //     textDirection: TextDirection.rtl,
                              //     child: DropdownButtonHideUnderline(
                              //       child: CustomDropdownButton(
                              //         isExpanded: false,
                              //         hint: Text(
                              //           "${localization.currentLanguage}",
                              //           style: TextStyle(
                              //             color: blackPurpleColor,
                              //             fontWeight: FontWeight.w300,
                              //           ),
                              //         ),
                              //         items:
                              //             localization.languages.map((value) {
                              //           return DropdownMenuItem(
                              //             child: Container(
                              //               height: 30,
                              //               child: Row(
                              //                 mainAxisAlignment:
                              //                     MainAxisAlignment
                              //                         .spaceBetween,
                              //                 children: [
                              //                   Text(
                              //                     '${value['code']}',
                              //                     textAlign: TextAlign.justify,
                              //                     style: TextStyle(
                              //                       color: primaryColor,
                              //                       fontWeight: FontWeight.w300,
                              //                     ),
                              //                   ),
                              //                   Text(
                              //                     '${value['title']}',
                              //                     textAlign: TextAlign.justify,
                              //                     style: TextStyle(
                              //                       color: blackPurpleColor,
                              //                       fontWeight: FontWeight.w300,
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //             value: value,
                              //           );
                              //         }).toList(),
                              //         onChanged: (value) {
                              //           localization.setLanguage(
                              //             value['code'],
                              //           );
                              //           setState(() {
                              //             localization.currentLanguage =
                              //                 '${value['title']}';
                              //           });
                              //         },
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            FlatButton(
                              child: Text(
                                "${localization.terms}".toUpperCase(),
                                style: TextStyle(
                                  color: brightGreyColor5,
                                  fontWeight: FontWeight.w300,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PDFViewer(
                                      'assets/terms.pdf',
                                      text: localization.terms,
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  dioError(context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          description: "${localization.httpError}",
          yesCallBack: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  _getCountries() async {
    await _api.getCountries().then((response) async {
      if (response == false) {
        dioError(context);
      } else {
        response['countries'].forEach((element) async {
          Country country = Country(
            element['ID'],
            element['length'],
            element['min'],
            element['max'],
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

  _signInButton(Size size) {
    return ButtonTheme(
      minWidth: size.width * 0.9,
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
      minWidth: size.width * 0.9,
      height: 60,
      child: RaisedButton(
        onPressed: () {
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
