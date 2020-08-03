import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api.dart';

import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/circle.dart';
import 'package:indigo24/widgets/keyboard.dart';
import 'package:indigo24/widgets/pin_code.dart';

import '../../../main.dart';

int accountLength;

// TODO REMOVE THIS CLASS AFTER BACKEND FIXES HERMES
class PaymentsServicePage extends StatefulWidget {
  final String _logo;
  final int serviceID;
  final String title;
  final String account;
  final String amount;

  PaymentsServicePage(this.serviceID, this._logo, this.title,
      {this.account, this.amount});

  @override
  _PaymentsServicePageState createState() => _PaymentsServicePageState();
}

class _PaymentsServicePageState extends State<PaymentsServicePage> {
  Api api = Api();

  showAlertDialog(BuildContext context, String type, String message,
      {bool withPop}) {
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
        // type == '1'
        // ? Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => PaymentHistoryPage()),(r) => false)
        // :
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        if (withPop != null) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
      },
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        print('showed dialog');
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 1.0),
          child: CupertinoAlertDialog(
            title: Text(type == '0'
                ? "${localization.attention}"
                : type == '1'
                    ? '${localization.success}'
                    : '${localization.error}'),
            content: Text(message),
            actions: [
              okButton,
            ],
          ),
        );
      },
    );
  }

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  bool isAuthenticated = false;

  final receiverController = TextEditingController();
  final sumController = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      setState(() {
        receiverController.text = widget.account;
        sumController.text = widget.amount;
      });
    }
  }

  bool isCalculated = false;
  double amount;
  double exchangeRate;
  double expectedAmount;
  String expectedCurrency;
  _showLockScreen(BuildContext context, String title,
      {bool withPin,
      bool opaque,
      CircleUIConfig circleUIConfig,
      KeyboardUIConfig keyboardUIConfig,
      Widget cancelButton,
      List<String> digits}) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            withPin: withPin,
            title: '$title',
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: cancelButton,
            deleteButton: Text(
              'Delete',
              style: const TextStyle(fontSize: 16, color: Color(0xFF001D52)),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Color(0xFFF7F7F7),
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
          ),
        ));
  }

  _onPasscodeEntered(String enteredPasscode) {
    print('user pin is ${user.pin}');
    if ('${user.pin}'.toString() == 'false') {
      print('set pin');
      api.createPin(enteredPasscode);
    }

    bool isValid = '${user.pin}' == enteredPasscode;
    _verificationNotifier.add(isValid);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (isValid) {
        _onPasscodeCancelled();
        // api
        //     .paymentProceed(
        //         widget.serviceID,
        //         '${receiverController.text.replaceAll(' ', '').replaceAll('+', '')}',
        //         expectedAmount)
        //     .then((result) {
        //   showAlertDialog(context, '1', '${result['message']}');
        //   api.getBalance().then((result) {
        //     setState(() {});
        //   });
        // });
        api
            .payService(
                widget.serviceID,
                '${receiverController.text.replaceAll(' ', '').replaceAll('+', '')}',
                sumController.text) 
            .then((services) {
          if (services['message'] == 'Not authenticated' &&
              services['success'].toString() == 'false') {
            logOut(context);
            return services;
          } else {
            if (services['success'].toString() == 'false')
              showAlertDialog(context, '0', services['message']);
            else {
              showAlertDialog(context, '1', services['message']);
              api.getBalance().then((result) {
                setState(() {});
              });
            }
            return services;
          }
        });
        setState(() {
          this.isAuthenticated = isValid;
        });
      }
    });
  }

  _onPasscodeCancelled() {
    Navigator.pop(context);
  }

  var temp;
  var accountRegex;
  String amountPlaceholder = '';
  String accountPlaceholder = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: FutureBuilder(
            future: api.getService(widget.serviceID).then((getServiceResult) {
              getServiceResult['result'].forEach((element) {
                // print('forEach element $element');
                if ('${element['name']}' == 'amount') {
                  amountPlaceholder = element['placeholder'];
                }
                if ('${element['name']}' == 'account') {
                  accountPlaceholder = element['placeholder'];
                  accountMask = element['mask'];
                  accountRegex = new RegExp(r'' + element['regex']);
                  if (element['mask'] == ' ') {
                    // print('if');
                    // temp = 'false';
                    // loginFormatter = MaskTextInputFormatter(filter: { "*" : RegExp(r'[0-9]') });
                  } else {
                    // print('else else');
                    accountLength = element['mask'].replaceAll(' ', '').length;

                    // loginFormatter = MaskTextInputFormatter(mask: '${element['mask']}', filter: { "*" : RegExp(r'[0-9]') });
                  }
                }
              });
              return getServiceResult;
            }),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? GestureDetector(
                      onTap: () {
                        if (!FocusScope.of(context).hasPrimaryFocus) {
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/background_little.png',
                                  fit: BoxFit.fill,
                                ),
                                Column(
                                  children: <Widget>[
                                    AppBar(
                                      centerTitle: true,
                                      title: Text("${localization.payments}"),
                                      leading: IconButton(
                                        icon: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Image(
                                            image: AssetImage(
                                              'assets/images/backWhite.png',
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 0, right: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: 0.6,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                            color: Color(0xFFD1E1FF),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 30, right: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(height: 15),
                                                Text(
                                                  '${localization.walletBalance}',
                                                  style: fS14(c: 'FFFFFF'),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  '${user.balance} ₸',
                                                  style: fS18(c: 'FFFFFF'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isCalculated
                                ? Container(
                                    color: whiteColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              '${localization.account}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: darkGreyColor2,
                                              ),
                                            ),
                                            Text(
                                              '${receiverController.text}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: blackPurpleColor,
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              '${localization.service}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: darkGreyColor2,
                                              ),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  '${widget.title}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: blackPurpleColor,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Image.network(
                                                  '${widget._logo}',
                                                  width: 30,
                                                  height: 30,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 10,
                                          width: 10,
                                          color: Colors.red,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              '${localization.toPay}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: blackPurpleColor,
                                              ),
                                            ),
                                            Text(
                                              '${amount.toStringAsFixed(3)}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: blackPurpleColor,
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              '${localization.conversion}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: blackPurpleColor,
                                              ),
                                            ),
                                            Text(
                                              '${expectedAmount.toStringAsFixed(3)}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: blackPurpleColor,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : mainPaymentsDetailMobile(snapshot.data),
                            SizedBox(
                              height: 10,
                            ),
                            isCalculated
                                ? Center(
                                    child: Text(
                                        '1 $expectedCurrency = $exchangeRate KZT',
                                        style: TextStyle(
                                            color: Color(0xFF001D52))))
                                : Center(),
                            Center(
                                child: Text(
                                    '${localization.minAmount} ${snapshot.data['service']['min']} KZT',
                                    style:
                                        TextStyle(color: Color(0xFF001D52)))),
                            Center(
                                child: Text(
                                    '${localization.maxAmount} ${snapshot.data['service']['max']} KZT',
                                    style:
                                        TextStyle(color: Color(0xFF001D52)))),
                            Center(
                                child: Text(
                                    '${localization.commission} ${snapshot.data['service']['commission']}%',
                                    style:
                                        TextStyle(color: Color(0xFF001D52)))),
                            transferButton(snapshot),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    )
                  : Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Container transferButton(snapshot) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: -2,
            offset: Offset(0.0, 0.0))
      ]),
      child: ButtonTheme(
        height: 40,
        child: RaisedButton(
          onPressed: () async {
            if (receiverController.text.isNotEmpty &
                sumController.text.isNotEmpty) {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if (receiverController.text.isNotEmpty &
                  sumController.text.isNotEmpty) {
                String str =
                    "${receiverController.text.replaceAll(' ', '').replaceAll('+', '')}";
                bool matches = accountRegex.hasMatch(str);
                if (int.parse(sumController.text) >=
                    snapshot.data['service']['min']) {
                  if (int.parse(sumController.text) <=
                      snapshot.data['service']['max']) {
                    if (matches) {
                      await _showLockScreen(context, '${localization.enterPin}',
                          opaque: false,
                          cancelButton: Text('Cancel',
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF001D52)),
                              semanticsLabel: 'Cancel'));
                    } else {
                      showAlertDialog(
                          context, '0', '${localization.enterValidAccount}');
                    }
                  } else {
                    showAlertDialog(
                        context, '0', '${localization.enterBelowMax}');
                  }
                } else {
                  showAlertDialog(
                      context, '0', '${localization.enterAboveMin}');
                }
                // if (isCalculated) {
                //   String str =
                //       "${receiverController.text.replaceAll(' ', '').replaceAll('+', '')}";
                //   bool matches = accountRegex.hasMatch(str);
                //   if (int.parse(sumController.text) >=
                //       snapshot.data['service']['min']) {
                //     if (int.parse(sumController.text) <=
                //         snapshot.data['service']['max']) {
                //       if (matches) {
                //         await _showLockScreen(context, '${localization.enterPin}',
                //             opaque: false,
                //             cancelButton: Text('Cancel',
                //                 style: const TextStyle(
                //                     fontSize: 16, color: Color(0xFF001D52)),
                //                 semanticsLabel: 'Cancel'));
                //       } else {
                //         showAlertDialog(
                //             context, '0', '${localization.enterValidAccount}');
                //       }
                //     } else {
                //       showAlertDialog(
                //           context, '0', '${localization.enterBelowMax}');
                //     }
                //   } else {
                //     showAlertDialog(
                //         context, '0', '${localization.enterAboveMin}');
                //   }
                // } else {
                //   api
                //       .calculateSum(
                //           widget.serviceID,
                //           '${receiverController.text.replaceAll(' ', '').replaceAll('+', '')}',
                //           sumController.text)
                //       .then((result) {
                //     result = json.decode(result);
                //     if (result['message'] == 'Not authenticated' &&
                //         result['success'].toString() == 'false') {
                //       logOut(context);
                //     } else {
                //       print('this is $result');
                //       setState(() {
                //         isCalculated = true;
                //         amount = result['Amount'];
                //         exchangeRate = result['ExchangeRate'];
                //         expectedAmount = result['ExpectedAmount'];
                //         expectedCurrency = result['ExpectedCurrency'];
                //       });
                //     }
                //   });
                // }
              }
            }
          },
          child: Container(
            height: 50,
            width: 200,
            child: Center(
              child: Text(
                '${isCalculated ? localization.pay : localization.calculate}',
                style: TextStyle(
                    color: Color(0xFF0543B8), fontWeight: FontWeight.w800),
              ),
            ),
          ),
          color: Color(0xFFFFFFFF),
          textColor: Color(0xFF001D52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
        ),
      ),
    );
  }

  String accountMask = '';
  Container mainPaymentsDetailMobile(snapshot) {
    return Container(
      height: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            padding: EdgeInsets.only(top: 20),
            child: Text(
              '${widget.title}',
              maxLines: 3,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF001D52),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: temp == 'false'
                            ? [
                                LengthLimitingTextInputFormatter(accountLength),
                                WhitelistingTextInputFormatter.digitsOnly,
                              ]
                            : [
                                LengthLimitingTextInputFormatter(accountLength),
                                WhitelistingTextInputFormatter.digitsOnly,
                              ],
                        decoration: InputDecoration.collapsed(
                          // hintText: '${localization.phoneNumber}',
                          hintText: accountPlaceholder,
                        ),
                        controller: receiverController,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                child: Image.network('${widget._logo}', width: 40.0),
              ),
            ],
          ),
          Container(
            height: 1.0,
            color: Colors.grey,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: sumController,
                    decoration: InputDecoration.collapsed(
                        // hintText: '${localization.amount}',
                        hintText: amountPlaceholder),
                    style: TextStyle(fontSize: 20),
                    inputFormatters: [
                      BlacklistingTextInputFormatter(new RegExp(r"^(?!(0))$")),
                    ],
                    onChanged: (value) {
                      if (sumController.text[0] == '0') {
                        sumController.clear();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
