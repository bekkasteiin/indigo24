import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_auth_title.dart';
import 'registration.dart';
import 'user_registration.dart';
import 'package:indigo24/services/localization/localization.dart';

class PhoneConfirmPage extends StatefulWidget {
  final smsCode;
  final phone;

  const PhoneConfirmPage(this.smsCode, this.phone);

  @override
  _PhoneConfirmPageState createState() => _PhoneConfirmPageState();
}

class _PhoneConfirmPageState extends State<PhoneConfirmPage> {
  bool _isPageOpened;
  Api _api;
  TextEditingController _smsController;
  TextEditingController _passwordController;
  String smsError;
  Timer _timer;
  Color _smsColor;

  @override
  void initState() {
    super.initState();
    _isPageOpened = true;
    smsError = "";
    _smsColor = greyColor;
    _api = Api();
    _smsController = TextEditingController();
    _passwordController = TextEditingController();
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _isPageOpened = false;
    _smsController.dispose();
    _passwordController.dispose();
    _timer.cancel();
    _timer = null;
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
            Center(
              child: _buildForeground(),
            )
          ],
        ),
      ),
    );
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    if (_timer == null) {
      _timer = Timer.periodic(oneSec, (Timer timer) {
        if (start == 0) {
          _timer.cancel();
          _timer = null;
        }
        if (_isPageOpened) {
          setState(() {});
          if (tamer == null) {
            setState(() {
              start = start - 1;
            });
          } else {
            setState(() {});
          }
        }
      });
    }
  }

  Widget _buildForeground() {
    return Column(
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
                SizedBox(height: 50),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      IndigoAuthTitle(title: Localization.language.keyFromSms),
                      TextField(
                        controller: _smsController,
                        style: TextStyle(
                          color: blackPurpleColor,
                          fontSize: 16,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "",
                          hintStyle: TextStyle(color: greyColor),
                        ),
                      ),
                      Text(
                        '$smsError',
                        style: TextStyle(
                          color: redColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _space(15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    '${Localization.language.weSentToEmail}',
                    style: TextStyle(
                      color: darkGreyColor3,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$start',
                  style: TextStyle(color: _smsColor),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: transparentColor,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      color: whiteColor,
                      onPressed: () async {
                        if (start == 0) {
                          _api.sendSms(widget.phone).then((sendSmsResult) {
                            setState(() {
                              start = 59;
                              _startTimer();
                            });
                          });
                        } else {
                          setState(() {
                            if (_smsColor != redColor) {
                              _smsColor = redColor;
                            }
                            Future.delayed(const Duration(seconds: 2), () {
                              if (_smsColor == greyColor) {
                                _smsColor = greyColor;
                              }
                            });
                          });
                        }
                      },
                      child: Ink(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            "${Localization.language.repeat} SMS",
                            style: TextStyle(
                              color: greyColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
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
                      //@TODO REMOVE CONDITION
                      if (_smsController.text.isNotEmpty) {
                        await _api
                            .checkSms(widget.phone, _smsController.text)
                            .then((checkSmsResponse) async {
                          if (checkSmsResponse['success'] == true) {
                            setState(() {
                              smsError = "";
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserRegistrationPage(widget.phone),
                              ),
                            );
                          } else {
                            setState(() {
                              smsError = checkSmsResponse['message'];
                            });
                          }
                          // if (r != true) {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) =>
                          //           UserRegistrationPage(widget.phone),
                          //     ),
                          //   );
                          // } else {
                          //   _showError(context, '$r');
                          // }
                        });
                      } else {
                        setState(() {
                          smsError = '${Localization.language.enterSmsCode}';
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        )
      ],
    );
  }

  _space(double h) {
    return Container(
      height: h,
    );
  }
}
