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
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../main.dart';

class PaymentsServicePage extends StatefulWidget {
  final String _logo;
  final int serviceID;
  final String title;
  final String account;
  final String amount;
  final int providerId;
  final isConvertable;

  PaymentsServicePage(
    this.serviceID,
    this._logo,
    this.title, {
    @required this.providerId,
    this.account,
    this.amount,
    this.isConvertable,
  });

  @override
  _PaymentsServicePageState createState() => _PaymentsServicePageState();
}

class _PaymentsServicePageState extends State<PaymentsServicePage> {
  bool isCalculated;

  int _accountLength;

  Api _api;

  StreamController<bool> _verificationNotifier;

  RegExp _accountRegex;
  String _amountPlaceholder = '';
  String _accountPlaceholder = '';

  MaskTextInputFormatter _loginFormatter;
  Map<String, dynamic> _service;

  TextEditingController _receiverController;
  TextEditingController _sumController;

  double _amount = 0.0;
  double _exchangeRate = 0.0;
  double _expectedAmount = 0.0;
  String _expectedCurrency = '';

  String accountExample;
  String amountExample;

  @override
  void initState() {
    super.initState();
    isCalculated = false;
    _verificationNotifier = StreamController<bool>.broadcast();

    _receiverController = TextEditingController();
    _sumController = TextEditingController();

    _api = Api();

    _api.getService(widget.serviceID).then((getServiceResult) {
      print('get servies is $getServiceResult');
      getServiceResult['result'].forEach((element) {
        if ('${element['name']}' == 'amount') {
          _amountPlaceholder = element['placeholder'];
        }
        if ('${element['name']}' == 'account') {
          _accountPlaceholder = element['placeholder'];
          accountExample = '${element['mask']}';

          _accountRegex = RegExp(r'' + element['regex']);
          RegExp anyRegExp = RegExp(r'.');

          if (element['mask'] == ' ') {
            _loginFormatter = MaskTextInputFormatter(filter: {"*": anyRegExp});
          } else {
            print('else else $element');
            if (element['mask'].toString() != 'null') {
              _accountLength = element['mask'].length;
            }
            _loginFormatter = MaskTextInputFormatter(
                mask: '${element['mask']}', filter: {"*": anyRegExp});
          }
        }
      });
      setState(() {
        _service = getServiceResult;
      });
    });

    if (widget.account != null) {
      setState(() {
        _receiverController.text = widget.account;
        _sumController.text = widget.amount;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _receiverController.dispose();
    _sumController.dispose();
    _verificationNotifier.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
            body: _service != null
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
                                    margin: EdgeInsets.only(left: 0, right: 20),
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
                                              Row(
                                                children: [
                                                  Text(
                                                    '${user.balance}',
                                                    style: fS18(c: 'FFFFFF'),
                                                  ),
                                                  Image(
                                                    image: AssetImage(
                                                        "assets/images/tenge.png"),
                                                    height: 12,
                                                    width: 12,
                                                  ),
                                                ],
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
                                            '${_receiverController.text}',
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
                                            '${_amount.toStringAsFixed(2)}',
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
                                            '${_expectedAmount.toStringAsFixed(2)}',
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
                              : _details(_service),
                          SizedBox(
                            height: 10,
                          ),
                          isCalculated
                              ? Center(
                                  child: Text(
                                      '1 $_expectedCurrency = ${_exchangeRate.toStringAsFixed(2)} KZT',
                                      style:
                                          TextStyle(color: Color(0xFF001D52))))
                              : Center(),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                              child: Text(
                                  '${localization.minAmount} ${_service['service']['min']} KZT',
                                  style: TextStyle(color: Color(0xFF001D52)))),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                              child: Text(
                                  '${localization.maxAmount} ${_service['service']['max']} KZT',
                                  style: TextStyle(color: Color(0xFF001D52)))),
                          _service['service']['commission'].toString() != '0'
                              ? Center(
                                  child: Text(
                                      '${localization.commission} ${_service['service']['commission'] * _amount} KZT',
                                      style:
                                          TextStyle(color: Color(0xFF001D52))))
                              : SizedBox(
                                  height: 0,
                                  width: 0,
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                              child: Text(
                                  '${localization.commission} ${_service['service']['commission']}%',
                                  style: TextStyle(color: Color(0xFF001D52)))),
                          _transferButton(_service),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  )
                : Center(child: CircularProgressIndicator())),
      ),
    );
  }

  showAlertDialog(BuildContext context, String type, String message,
      {bool withPop}) {
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
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
    if ('${user.pin}'.toString() == 'false') {
      print('set pin');
      _api.createPin(enteredPasscode);
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
        _api
            .payService(
                widget.serviceID,
                '${_receiverController.text.replaceAll(' ', '').replaceAll('+', '')}',
                _sumController.text)
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
              _api.getBalance().then((result) {
                setState(() {});
              });
            }
            return services;
          }
        });
      }
    });
  }

  _onPasscodeCancelled() {
    Navigator.pop(context);
  }

  Container _transferButton(snapshot) {
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
            if (_receiverController.text.isNotEmpty &
                _sumController.text.isNotEmpty) {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }

              if (_receiverController.text.isNotEmpty &
                  _sumController.text.isNotEmpty) {
                // String str =
                //     "${_receiverController.text.replaceAll(' ', '').replaceAll('+', '')}";
                // bool matches = _accountRegex.hasMatch(str);
                // if (int.parse(_sumController.text) >=
                //     _service['service']['min']) {
                //   if (int.parse(_sumController.text) <=
                //       _service['service']['max']) {
                //     if (matches) {
                //       await _showLockScreen(
                //         context,
                //         '${localization.enterPin}',
                //         opaque: false,
                //         cancelButton: Text(
                //           'Cancel',
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Color(0xFF001D52),
                //           ),
                //           semanticsLabel: 'Cancel',
                //         ),
                //       );
                //     } else {
                //       showAlertDialog(
                //           context, '0', '${localization.enterValidAccount}');
                //     }
                //   } else {
                //     showAlertDialog(
                //         context, '0', '${localization.enterBelowMax}');
                //   }
                // } else {
                //   showAlertDialog(
                //       context, '0', '${localization.enterAboveMin}');
                // }
                if (widget.isConvertable == 0 || isCalculated == true) {
                  String str =
                      "${_receiverController.text.replaceAll(' ', '').replaceAll('+', '')}";
                  bool matches = _accountRegex.hasMatch(str);
                  if (int.parse(_sumController.text) >=
                      _service['service']['min']) {
                    if (int.parse(_sumController.text) <=
                        _service['service']['max']) {
                      if (matches) {
                        await _showLockScreen(
                          context,
                          '${localization.enterPin}',
                          opaque: false,
                          cancelButton: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF001D52),
                            ),
                          ),
                        );
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
                } else {
                  print('ptinr');
                  _api
                      .calculateSum(
                          widget.serviceID,
                          '${_receiverController.text.replaceAll(' ', '').replaceAll('+', '')}',
                          _sumController.text,
                          widget.providerId)
                      .then((result) {
                    print(result);
                    if (result['message'] == 'Not authenticated' &&
                        result['success'].toString() == 'false') {
                      logOut(context);
                    } else if (result['success'].toString() == 'true') {
                      print('this is $result');
                      setState(() {
                        isCalculated = true;
                        _amount = double.parse(result['Amount'].toString());
                        _exchangeRate =
                            double.parse(result['ExchangeRate'].toString());
                        _expectedAmount =
                            double.parse(result['ExpectedAmount'].toString());
                        _expectedCurrency = result['ExpectedCurrency'];
                      });
                    }
                  });
                }
              }
            }
          },
          child: Container(
            height: 50,
            width: 200,
            child: Center(
              child: Text(
                '${isCalculated == false && widget.isConvertable == 1 ? localization.calculate : localization.pay}',
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

  Container _details(snapshot) {
    return Container(
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
                        inputFormatters: [
                          _loginFormatter,
                          _accountLength != null
                              ? LengthLimitingTextInputFormatter(_accountLength)
                              : LengthLimitingTextInputFormatter(50),
                        ],
                        decoration: InputDecoration.collapsed(
                          hintText: _accountPlaceholder,
                        ),
                        controller: _receiverController,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Text('${localization.example} $accountExample')
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
                child: Column(
                  children: <Widget>[
                    Container(
                      child: TextFormField(
                        controller: _sumController,
                        decoration: InputDecoration.collapsed(
                            hintText: _amountPlaceholder),
                        style: TextStyle(fontSize: 20),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            _service['service']['max'].toString().length,
                          ),
                          BlacklistingTextInputFormatter(
                              new RegExp(r"^(?!(0))$")),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ],
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
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
    );
  }
}
