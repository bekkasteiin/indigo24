import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api.dart';

import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/circle.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';
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

  Api _api;

  StreamController<bool> _verificationNotifier;

  Map<String, dynamic> _service;

  double _amount = 0.0;
  double _exchangeRate = 0.0;
  double _expectedAmount = 0.0;
  String _expectedCurrency = '';

  String accountExample;
  String amountExample;

  RegExp anyRegExp = RegExp(r'.');

  List<Map<String, dynamic>> controllers = [];
  String account = '';
  String sum = '';
  @override
  void initState() {
    super.initState();
    isCalculated = false;
    _verificationNotifier = StreamController<bool>.broadcast();

    _api = Api();

    _api.getService(widget.serviceID).then((getServiceResult) {
      getServiceResult['result'].forEach((element) {
        TextEditingController elementController = TextEditingController(
            text: element['mask'].toString() != 'null'
                ? element['mask'].replaceAll('*', '').replaceAll(' ', '')
                : '');
        controllers
            .add({'name': element['name'], 'controller': elementController});
      });
      setState(() {
        _service = getServiceResult;
      });
    });

    if (widget.account != null) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _verificationNotifier.close();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                                'assets/images/wallet_header.png',
                                 width: size.width,
                          fit: BoxFit.fitWidth,
                              ),
                              Column(
                                children: <Widget>[
                                  IndigoAppBarWidget(
                                    centerTitle: true,
                                    title: Text(localization.payments),
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
                                            '$account',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: blackPurpleColor,
                                            ),
                                          ),
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
                                          SizedBox(width: 10),
                                          Flexible(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    '${widget.title}',
                                                    maxLines: 10,
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: blackPurpleColor,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Container(
                                                  width: 30,
                                                  height: 30,
                                                  child: CachedNetworkImage(
                                                    imageUrl: '${widget._logo}',
                                                  ),
                                                ),
                                              ],
                                            ),
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
                                            '${_amount.toStringAsFixed(2)} KZT',
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
                                            '${_expectedAmount.toStringAsFixed(2)} $_expectedCurrency',
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
                                    style: TextStyle(
                                      color: Color(0xFF001D52),
                                    ),
                                  ),
                                )
                              : Center(),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(
                              '${localization.commission} ${_service['service']['commission']}%',
                              style: TextStyle(
                                color: Color(
                                  0xFF001D52,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${localization.minAmount} ${_service['service']['min']} KZT',
                              style: TextStyle(
                                color: Color(
                                  0xFF001D52,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${localization.maxAmount} ${_service['service']['max']} KZT',
                              style: TextStyle(
                                color: Color(
                                  0xFF001D52,
                                ),
                              ),
                            ),
                          ),
                          _service['service']['commission'].toString() != '0'
                              ? Center(
                                  child: Text(
                                    '${localization.commission} ${_service['service']['commission'] * _amount} KZT',
                                    style: TextStyle(
                                      color: Color(
                                        0xFF001D52,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 0,
                                  width: 0,
                                ),
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
        pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
          withPin: withPin,
          title: '$title',
          passwordEnteredCallback: _onPasscodeEntered,
          cancelButton: cancelButton,
          deleteButton: Text(
            '${localization.delete}',
            style: const TextStyle(fontSize: 16, color: whiteColor),
            semanticsLabel: '${localization.delete}',
          ),
          shouldTriggerVerification: _verificationNotifier.stream,
          backgroundColor: Color(0xFFF7F7F7),
          cancelCallback: _onPasscodeCancelled,
          digits: digits,
        ),
      ),
    );
  }

  _onPasscodeEntered(String enteredPasscode) {
    if ('${user.pin}'.toString() == 'false') {
      _api.createPin(enteredPasscode);
    }

    bool isValid = '${user.pin}' == enteredPasscode;

    _verificationNotifier.add(isValid);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (isValid) {
        _onPasscodeCancelled();
        _api.payService(widget.serviceID, controllers).then((services) {
          if (services['message'] == 'Not authenticated' &&
              services['success'].toString() == 'false') {
            logOut(context);
            return services;
          } else {
            if (services['success'].toString() == 'false')
              showDialog(
                context: context,
                builder: (BuildContext context) => CustomDialog(
                  description: '${services['message']}',
                  yesCallBack: () {
                    Navigator.pop(context);
                  },
                ),
              );
            else {
              showDialog(
                context: context,
                builder: (BuildContext context) => CustomDialog(
                  description: '${services['message']}',
                  yesCallBack: () {
                    Navigator.pop(context);
                  },
                ),
              );
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
            int amountControllerIndex = controllers
                .indexWhere((element) => element['name'] == 'account');
            account = controllers[amountControllerIndex]['controller']
                .text
                .toString()
                .replaceAll(' ', '');

            int sumControllerIndex = controllers
                .indexWhere((element) => element['name'] == 'amount');
            sum = controllers[sumControllerIndex]['controller']
                .text
                .replaceAll(' ', '');

            if (widget.isConvertable == 0 || isCalculated == true) {
              if (int.parse(sum) >= _service['service']['min']) {
                if (int.parse(sum) <= _service['service']['max']) {
                  await _showLockScreen(
                    context,
                    '${localization.enterPin}',
                    opaque: false,
                    cancelButton: Text(
                      localization.cancel,
                      style: const TextStyle(fontSize: 16, color: whiteColor),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => CustomDialog(
                      description: '${localization.enterBelowMax}',
                      yesCallBack: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                }
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => CustomDialog(
                    description: '${localization.enterAboveMin}',
                    yesCallBack: () {
                      Navigator.pop(context);
                    },
                  ),
                );
              }
            } else {
              if (int.parse(sum) >= _service['service']['min']) {
                if (int.parse(sum) <= _service['service']['max']) {
                  _api
                      .calculateSum(
                          widget.serviceID,
                          '${account.replaceAll(' ', '').replaceAll('+', '')}',
                          int.parse(sum),
                          widget.providerId)
                      .then((result) {
                    if (result['message'] == 'Not authenticated' &&
                        result['success'].toString() == 'false') {
                      logOut(context);
                    } else if (result['success'].toString() == 'true') {
                      setState(() {
                        isCalculated = true;
                        _amount = double.parse(result['Amount'].toString());
                        _exchangeRate =
                            double.parse(result['ExchangeRate'].toString());
                        _expectedAmount =
                            double.parse(result['ExpectedAmount'].toString());
                        _expectedCurrency = result['ExpectedCurrency'];
                      });
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => CustomDialog(
                          description: '${result['message']}',
                          yesCallBack: () {
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => CustomDialog(
                      description: '${localization.enterBelowMax}',
                      yesCallBack: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                }
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => CustomDialog(
                    description: '${localization.enterAboveMin}',
                    yesCallBack: () {
                      Navigator.pop(context);
                    },
                  ),
                );
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
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    color: Colors.white,
                    child: Text(
                      '${widget.title}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF001D52),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  child: CachedNetworkImage(imageUrl: '${widget._logo}'),
                ),
              ],
            ),
          ),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              MaskTextInputFormatter elementFormatter;
              if ('${snapshot['result'][index]['mask']}' != 'null') {
                elementFormatter = MaskTextInputFormatter(
                  mask: '${snapshot['result'][index]['mask']}',
                  filter: {"*": anyRegExp},
                );
              } else {
                elementFormatter = MaskTextInputFormatter(
                  filter: {"*": anyRegExp},
                  mask: '***************************************',
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: TextFormField(
                            inputFormatters: [
                              elementFormatter,
                              LengthLimitingTextInputFormatter(50),
                            ],
                            decoration: InputDecoration.collapsed(
                              hintText:
                                  '${snapshot['result'][index]['placeholder']}',
                            ),
                            controller: controllers[index]['controller'],
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Text(
                            '${snapshot['result'][index]['mask'].toString() != 'null' ? localization.example + ' ' + snapshot['result'][index]['mask'] : ' '}')
                      ],
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) {
              return Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                  Text(""),
                ],
              );
            },
            itemCount: snapshot['result'].length,
          ),
          Column(
            children: [
              SizedBox(height: 10),
              Container(
                height: 1.0,
                color: Colors.grey,
              ),
              Text(""),
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
