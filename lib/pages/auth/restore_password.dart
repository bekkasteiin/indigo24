import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/db/country_dao.dart';
import 'package:indigo24/db/country_model.dart';
import 'package:indigo24/pages/auth/login/login.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/backgrounds.dart';

import 'countries.dart';

class RestorePasswordPage extends StatefulWidget {
  @override
  _RestorePasswordPageState createState() => _RestorePasswordPageState();
}

class _RestorePasswordPageState extends State<RestorePasswordPage> {
  Api _api = Api();
  TextEditingController _loginController;
  TextEditingController _passwordController;
  var _countries = List<Country>();
  var _phonePrefix = '77';
  String _currentCountry = "Казахстан";
  var _selectedCountry;

  CountryDao _countryDao = CountryDao();

  _getCountries() async {
    var list = await _countryDao.getAll();
    setState(() {
      _countries = list;
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
          backgroundColor: whiteColor,
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
          _buildForeground(),
        ],
      ),
    );
  }

  Future<void> changeCountry() async {
    _selectedCountry = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Countries(_countries)),
    );

    if (_selectedCountry != null)
      setState(
        () {
          _currentCountry = _selectedCountry.title;
          _phonePrefix = _selectedCountry.phonePrefix;
        },
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
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(5),
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
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                "${Localization.language.phoneNumber}",
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
                                '+$_phonePrefix',
                                style: TextStyle(
                                  color: blackPurpleColor,
                                  fontSize: 16,
                                ),
                              ),
                              TextField(
                                controller: _loginController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: blackPurpleColor,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  focusColor: blackColor,
                                  fillColor: blackColor,
                                  hoverColor: blackColor,
                                  prefixText: '1$_phonePrefix ',
                                  prefixStyle:
                                      TextStyle(color: transparentColor),
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
                        defaultWidget: Text(
                          "${Localization.language.next}",
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
                          await _api
                              .restorePassword(
                                  _phonePrefix + _loginController.text)
                              .then(
                            (restorePasswordResponse) async {
                              if (restorePasswordResponse['success'] == true) {
                                showIndigoDialog(
                                  context: context,
                                  builder: CustomDialog(
                                    description:
                                        "${restorePasswordResponse['message']}",
                                    yesCallBack: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                        (r) => false,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                showIndigoDialog(
                                  context: context,
                                  builder: CustomDialog(
                                    description:
                                        "${restorePasswordResponse['message']}",
                                    yesCallBack: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                );
                              }
                            },
                          );
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
