import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/pin/pin_code.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:indigo24/services/constants.dart';

import 'package:indigo24/widgets/alerts/indigo_logout.dart';

class PaymentsServicePage extends StatefulWidget {
  final String _logo;
  final int serviceID;
  final String title;
  final String account;
  final String amount;
  final int providerId;
  final bool isConvertable;

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
      if (getServiceResult['success'] == true) {
        getServiceResult['result'].forEach((element) {
          TextEditingController elementController = TextEditingController();
          MaskTextInputFormatter elementFormatter;
          if ('${element['mask']}' != 'null') {
            elementFormatter = MaskTextInputFormatter(
              mask: '${element['mask']}',
              filter: {"*": anyRegExp},
            );
          } else {
            elementFormatter = MaskTextInputFormatter(
              filter: {"*": anyRegExp},
              mask: '***************************************',
            );
          }
          controllers.add({
            'name': element['name'],
            'controller': elementController,
            'regex': element['regex'],
            'formatter': elementFormatter,
          });
        });
        setState(() {
          _service = getServiceResult;
        });
      } else {
        showIndigoDialog(
          context: context,
          builder: CustomDialog(
            description: getServiceResult['message'],
            yesCallBack: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        );
      }
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
    print(widget.isConvertable);

    return Container(
      color: whiteColor,
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
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    "${assetsPath}wallet_header.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
                                IndigoAppBarWidget(
                                  centerTitle: true,
                                  title: Text(widget.title),
                                  leading: IconButton(
                                    icon: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Image(
                                        image: AssetImage(
                                          '${assetsPath}backWhite.png',
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  backgroundColor: transparentColor,
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
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        color: brightGreyColor,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: 20,
                                          right: 10,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(height: 15),
                                            Text(
                                              '${Localization.language.walletBalance}',
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
                                                      "${assetsPath}tenge.png"),
                                                  height: 12,
                                                  width: 12,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                                            '${Localization.language.account}',
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
                                            '${Localization.language.service}',
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
                                            '${Localization.language.toPay}',
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
                                            '${Localization.language.conversion}',
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
                                      color: blackPurpleColor,
                                    ),
                                  ),
                                )
                              : Center(),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(
                              '${Localization.language.commission} ${_service['service']['commission']}%',
                              style: TextStyle(color: greyColor2),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${Localization.language.minAmount} ${_service['service']['min']} KZT',
                              style: TextStyle(color: greyColor2),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${Localization.language.maxAmount} ${_service['service']['max']} KZT',
                              style: TextStyle(color: greyColor2),
                            ),
                          ),
                          _service['service']['commission'].toString() != '0'
                              ? Center(
                                  child: Text(
                                    '${Localization.language.commission} ${_service['service']['commission'] * _amount} KZT',
                                    style: TextStyle(color: blackPurpleColor),
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

  _showLockScreen(BuildContext context, String title, {bool withPin}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
          withPin: withPin,
          title: '$title',
          passwordEnteredCallback: _onPasscodeEntered,
          shouldTriggerVerification: _verificationNotifier.stream,
          backgroundColor: milkWhiteColor,
          cancelCallback: _onPasscodeCancelled,
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
              showIndigoDialog(
                context: context,
                builder: CustomDialog(
                  description: '${services['message']}',
                  yesCallBack: () {
                    Navigator.pop(context);
                  },
                ),
              );
            else {
              showIndigoDialog(
                context: context,
                builder: CustomDialog(
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
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: blackColor,
              blurRadius: 10.0,
              spreadRadius: -10,
              offset: Offset(0.0, 0.0))
        ],
      ),
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
            if (!widget.isConvertable || isCalculated == true) {
              if (int.parse(sum) >= _service['service']['min']) {
                if (int.parse(sum) <= _service['service']['max']) {
                  await _showLockScreen(
                    context,
                    '${Localization.language.enterPin}',
                  );
                } else {
                  showIndigoDialog(
                    context: context,
                    builder: CustomDialog(
                      description: '${Localization.language.enterBelowMax}',
                      yesCallBack: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                }
              } else {
                showIndigoDialog(
                  context: context,
                  builder: CustomDialog(
                    description: '${Localization.language.enterAboveMin}',
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
                      showIndigoDialog(
                        context: context,
                        builder: CustomDialog(
                          description: '${result['message']}',
                          yesCallBack: () {
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }
                  });
                } else {
                  showIndigoDialog(
                    context: context,
                    builder: CustomDialog(
                      description: '${Localization.language.enterBelowMax}',
                      yesCallBack: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                }
              } else {
                showIndigoDialog(
                  context: context,
                  builder: CustomDialog(
                    description: '${Localization.language.enterAboveMin}',
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
                '${isCalculated == false && widget.isConvertable ? Localization.language.calculate : Localization.language.pay}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          color: whiteColor,
          textColor: blackPurpleColor,
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
                    color: whiteColor,
                    child: Text(
                      '${widget.title}',
                      style: TextStyle(
                        fontSize: 16,
                        color: greyColor2,
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
              var snapshotMask = snapshot['result'][index]['mask'];
              var snapshotExample = snapshot['result'][index]['example'];

              String mask = snapshotMask == ''
                  ? ''
                  : snapshotMask.toString() == 'null'
                      ? ''
                      : snapshotMask;

              String example = snapshotExample == ''
                  ? ''
                  : snapshotExample.toString() == 'null'
                      ? ''
                      : snapshotExample;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: TextFormField(
                            inputFormatters: [
                              controllers[index]['formatter'],
                              LengthLimitingTextInputFormatter(50),
                            ],
                            decoration: InputDecoration.collapsed(
                              hintText:
                                  '${snapshot['result'][index]['placeholder']}',
                            ),
                            controller: controllers[index]['controller'],
                            style: TextStyle(fontSize: 20, color: greyColor2),
                          ),
                        ),
                        Text(
                          '${((mask.isNotEmpty || example.isNotEmpty) ? "${Localization.language.example}: " : '') + (example.isNotEmpty ? example : mask.isNotEmpty ? mask : '')}',
                          style: TextStyle(
                            color: greyColor,
                          ),
                        )
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
                    height: 0.5,
                    color: brightGreyColor5,
                  ),
                  Text(""),
                ],
              );
            },
            itemCount: snapshot['result'].length,
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: whiteColor,
      ),
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
    );
  }
}
