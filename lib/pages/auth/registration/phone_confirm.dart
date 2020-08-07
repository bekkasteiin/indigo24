import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'registration.dart';
import 'user_registration.dart';
import 'package:indigo24/services/localization.dart' as localization;

class PhoneConfirmPage extends StatefulWidget {
  final smsCode;
  final phone;

  const PhoneConfirmPage(this.smsCode, this.phone);

  @override
  _PhoneConfirmPageState createState() => _PhoneConfirmPageState();
}

class _PhoneConfirmPageState extends State<PhoneConfirmPage> {
  bool isPageOpened;
  var api = Api();
  TextEditingController smsController;
  TextEditingController passwordController;
  String smsError = "";
  @override
  void initState() {
    super.initState();
    startTimer();
    isPageOpened = true;
    smsController = new TextEditingController();
    passwordController = new TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    isPageOpened = false;
    _timer.cancel();
    _timer = null;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
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
            backgroundColor: Colors.white, // status bar color
            brightness: Brightness.light, // status bar brightness
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
              Center(child: _buildForeground())
            ],
          ),
        ));
  }

  Timer _timer;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    if (_timer == null) {
      print('staring time');
      print(isPageOpened);
      _timer = Timer.periodic(oneSec, (Timer timer) {
        if (start == 0) {
          _timer.cancel();
          _timer = null;
        }
        if (isPageOpened) {
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

  Color smsColor = greyColor;

  Widget _buildForeground() {
    return Column(
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
                SizedBox(height: 50),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("${localization.keyFromSms}",
                              style: TextStyle(
                                  color: blackPurpleColor, fontSize: 16))
                        ],
                      ),
                      TextField(
                        controller: smsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: ""),
                      ),
                      Text(
                        '$smsError',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _space(15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    '${localization.weSentToEmail}',
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
                  style: TextStyle(color: smsColor),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ),
                      ),
                      color: whiteColor,
                      onPressed: () async {
                        if (start == 0) {
                          api.sendSms(widget.phone).then((sendSmsResult) {
                            print(sendSmsResult);
                            setState(() {
                              start = 59;
                              startTimer();
                            });
                          });
                        } else {
                          setState(() {
                            if (smsColor != redColor) {
                              smsColor = redColor;
                            }
                            Future.delayed(const Duration(seconds: 2), () {
                              if (smsColor == greyColor) {
                                smsColor = greyColor;
                              }
                            });
                          });
                        }
                      },
                      child: Ink(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            "${localization.repeat} SMS", // TODO ADD LOCALIZATION
                            style: TextStyle(
                              color: Colors.grey[700],
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
                    defaultWidget: Text("${localization.next}",
                        style: TextStyle(color: Colors.white, fontSize: 22)),
                    progressWidget: CircularProgressIndicator(),
                    borderRadius: 10.0,
                    color: primaryColor,
                    onPressed: () async {
                      //@TODO REMOVE CONDITION
                      if (smsController.text.isNotEmpty) {
                        await api
                            .checkSms(widget.phone, smsController.text)
                            .then((checkSmsResponse) async {
                          print('this is checkSmsResponse $checkSmsResponse');
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
                          smsError = '${localization.enterSmsCode}';
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
