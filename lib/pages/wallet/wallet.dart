import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/wallet/balance_history.dart';
import 'package:indigo24/pages/wallet/payments/payments_category.dart';
import 'package:indigo24/pages/wallet/refill/refill.dart';
import 'package:indigo24/pages/wallet/transfers/transfer_list.dart';
import 'package:indigo24/pages/wallet/withdraw/withdraw.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/circle.dart';
import 'package:indigo24/widgets/keyboard.dart';
import 'package:indigo24/widgets/pin_code.dart';
import 'package:polygon_clipper/polygon_border.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;

class MyBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ClampingScrollPhysics();
}

class WalletTab extends StatefulWidget {
  @override
  _WalletTabState createState() => _WalletTabState();
}

double _amount = double.parse(user.balance);

class _WalletTabState extends State<WalletTab> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  bool isAuthenticated = false;

  double _blockedAmount = 0;
  String _symbol;
  String _tengeSymbol = '₸';
  static double _realAmount = 0;
  double _globalCoef = 1;
  double _tengeCoef = 1;
  double _euroCoef = 0;
  double _rubleCoef = 0;
  double _dollarCoef = 0;
  var withPin;
  var api = Api();

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
            title: title,
            withPin: withPin,
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: cancelButton,
            deleteButton: Text(
              '${localization.delete}',
              style: const TextStyle(fontSize: 16, color: blackPurpleColor),
              semanticsLabel: '${localization.delete}',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: milkWhiteColor,
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
          ),
        ));
  }

  String temp = '';

  _onPasscodeEntered(String enteredPasscode) {
    if (user.pin == 'waiting' && temp == enteredPasscode) {
      print('creating');
      api.createPin(enteredPasscode);
      Navigator.pop(context);
    }
    if ('${user.pin}'.toString() == 'waiting' && temp != enteredPasscode) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('${localization.error}'),
            content: Text('${localization.incorrectPin}'),
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
    if ('${user.pin}' == 'false') {
      user.pin = 'waiting';
      temp = enteredPasscode;
      print('first set pin $temp');
    }

    bool isValid = '${user.pin}' == enteredPasscode;
    if (isValid) {
      Future.delayed(const Duration(milliseconds: 250), () {
        print(' is really valid ');
        _verificationNotifier.add(isValid);
        setState(() {
          this.isAuthenticated = isValid;
        });
        Navigator.pop(context);
      });
    } else {
      _verificationNotifier.add(isValid);
    }
    // if (!isValid){
    // return showDialog<void>(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return CupertinoAlertDialog(
    //       title: Text('${localization.error}'),
    //       content: Text('${localization.incorrectPin}'),
    //       actions: <Widget>[
    //         CupertinoDialogAction(
    //           child: Text('Ok'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
    // }
  }

  _onPasscodeCancelled() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => Tabs(),
      ),
      (r) => false,
    );
  }

  @override
  void dispose() {
    api.getBalance();
    _verificationNotifier.close();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
  }

  @override
  void initState() {
    api.getBalance();
    if ('${user.pin}'.toString() == 'false') {
      withPin = false;
    }
    Timer.run(() {
      withPin == false
          ? _showLockScreen(context, '${localization.createPin}',
              withPin: withPin,
              opaque: false,
              cancelButton: Text('${localization.cancel}',
                  style: const TextStyle(fontSize: 16, color: blackPurpleColor),
                  semanticsLabel: '${localization.cancel}'))
          : _showLockScreen(context, '${localization.enterPin}',
              opaque: false,
              cancelButton: Text('${localization.cancel}',
                  style: const TextStyle(fontSize: 16, color: blackPurpleColor),
                  semanticsLabel: '${localization.cancel}'));
    });

    _symbol = '₸';
    _realAmount = double.parse(user.balance);
    _blockedAmount = double.parse(user.balanceInBlock);
    api.getExchangeRate().then((v) {
      if (v['message'] == 'Not authenticated' &&
          v['success'].toString() == 'false') {
        logOut(context);
        return true;
      } else {
        var ex = v["exchangeRates"];
        _euroCoef = double.parse(ex['EUR']);
        _rubleCoef = double.parse(ex['RUB']);
        _dollarCoef = double.parse(ex['USD']);
        return false;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _amount = _realAmount / _globalCoef;
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          child: AppBar(
            centerTitle: true,
            brightness: Brightness.dark,
          ),
          preferredSize: Size.fromHeight(0.0),
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: SingleChildScrollView(
            child: Container(
              child: Stack(
                children: <Widget>[
                  Image.asset(
                    'assets/images/walletBackground.png',
                    fit: BoxFit.fill,
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10),
                        Text('${localization.wallet}',
                            style: fS26(c: 'ffffff')),
                        _devider(),
                        _balance(),
                        SizedBox(height: 10),
                        _balanceAmount(),
                        _exchangeButtons(),
                        _symbol == _tengeSymbol
                            ? Container(
                                width: size.width,
                                color: darkPrimaryColor,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  '',
                                ),
                              )
                            : _exchangeCurrency(size),
                        _blockedBalance(size),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.only(
                            left: size.width * 0.05,
                            right: size.width * 0.05,
                            top: 20,
                          ),
                          child: Column(
                            children: <Widget>[
                              _payInOut(size),
                              SizedBox(height: 20),
                              _payments(size),
                              SizedBox(height: 20),
                              _transfer(size),
                              SizedBox(height: 20),
                              historyBalance(size),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _exchangeCurrency(size) {
    String tempSymbol = '$_symbol';
    String tempExchangeRate = '$_globalCoef';
    return Container(
      width: size.width,
      color: darkPrimaryColor,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            tempSymbol == '\$'
                ? '$tempSymbol 1 = $tempExchangeRate '
                : '1 $tempSymbol = $tempExchangeRate ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
          ),
          Image(
            image: AssetImage("assets/images/tenge.png"),
            height: 12,
            width: 12,
          ),
        ],
      ),
    );
  }

  Container historyBalance(Size size) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: -2,
            offset: Offset(0.0, 0.0))
      ]),
      child: ButtonTheme(
        minWidth: size.width * 0.8,
        height: 70,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BalanceHistoryPage()))
                .whenComplete(() async {
              await api.getBalance();
              setState(() {
                // _amount = double.parse(user.balance);
                _realAmount = double.parse(user.balance);
                _blockedAmount = double.parse(user.balanceInBlock);
              });
            });
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/images/balanceHistory.png"),
                  height: 40,
                  width: 40,
                ),
                Text(
                  '${localization.historyBalance}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                ),
                Container(width: 10),
              ],
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

  Container _transfer(Size size) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: -2,
            offset: Offset(0.0, 0.0))
      ]),
      child: ButtonTheme(
        minWidth: size.width * 0.8,
        height: 70,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TransferListPage()))
                .whenComplete(() async {
              await api.getBalance();
              setState(() {
                // _amount = double.parse(user.balance);
                _realAmount = double.parse(user.balance);
                _blockedAmount = double.parse(user.balanceInBlock);
              });
            });
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/images/transfers.png"),
                  height: 40,
                ),
                Text(
                  '${localization.transfers}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                ),
                Container(width: 10),
              ],
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

  Container _payments(Size size) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: -2,
            offset: Offset(0.0, 0.0))
      ]),
      child: ButtonTheme(
        height: 70,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentsCategoryPage()))
                .whenComplete(() async {
              await api.getBalance();
              setState(() {
                // _amount = double.parse(user.balance);
                _realAmount = double.parse(user.balance);
                _blockedAmount = double.parse(user.balanceInBlock);
              });
            });
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/images/payments.png"),
                  height: 40,
                ),
                Text(
                  '${localization.payments}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                ),
                Container(width: 10),
              ],
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

  Container _devider() {
    return Container(
      height: 0.6,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: brightGreyColor,
    );
  }

  Text _balance() {
    return Text(
      '${localization.balance}',
      style: fS18(c: 'ffffff'),
    );
  }

  Widget _balanceAmount() {
    if (_symbol == '${String.fromCharCodes(Runes('\u0024'))}')
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            image: AssetImage("assets/images/dollar.png"),
            height: 25,
            width: 25,
          ),
          Text(
            '${_amount.toStringAsFixed(2)}',
            style: fS26(c: 'ffffff'),
          ),
        ],
      );

    if (_symbol == '${String.fromCharCodes(Runes('\u20B8'))}')
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${_amount.toStringAsFixed(2)}',
            style: fS26(c: 'ffffff'),
          ),
          Image(
            image: AssetImage("assets/images/tenge.png"),
            height: 25,
            width: 25,
          ),
        ],
      );

    if (_symbol == '${String.fromCharCodes(Runes('\u20BD'))}')
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${_amount.toStringAsFixed(2)}',
            style: fS26(c: 'ffffff'),
          ),
          Image(
            image: AssetImage("assets/images/ruble.png"),
            height: 25,
            width: 25,
          ),
        ],
      );

    if (_symbol == '${String.fromCharCodes(Runes('\u20AC'))}')
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${_amount.toStringAsFixed(2)}',
            style: fS26(c: 'ffffff'),
          ),
          Image(
            image: AssetImage("assets/images/euro.png"),
            height: 25,
            width: 25,
          ),
        ],
      );
    return Text(
      '${_amount.toStringAsFixed(2)} $_symbol',
      style: fS26(c: 'ffffff'),
    );
  }

  Container _blockedBalance(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      color: primaryColor,
      width: size.width,
      child: Column(
        children: <Widget>[
          Text('${localization.balanceInBlock}', style: fS18w200(c: 'ffffff')),
          Container(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('${_blockedAmount.toStringAsFixed(2)}',
                  style: fS26w200(c: 'ffffff')),
              Image(
                image: AssetImage("assets/images/tenge.png"),
                height: 24,
                width: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row _payInOut(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: -2,
                offset: Offset(0.0, 0.0))
          ]),
          child: ButtonTheme(
            minWidth: size.width * 0.42,
            height: 50,
            child: RaisedButton(
              onPressed: () {
                print('пополнить is pressed');
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => RefillPage()))
                    .whenComplete(() async {
                  await api.getBalance();
                  setState(() {
                    // _amount = double.parse(user.balance);
                    _realAmount = double.parse(user.balance);
                    _blockedAmount = double.parse(user.balanceInBlock);
                  });
                });
              },
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  '${localization.refill}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              color: whiteColor,
              textColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: -2,
                offset: Offset(0.0, 0.0))
          ]),
          child: ButtonTheme(
            minWidth: size.width * 0.42,
            height: 50,
            child: RaisedButton(
              onPressed: () {
                print('вывести is pressed');
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => WithdrawPage()))
                    .whenComplete(() async {
                  await api.getBalance();
                  setState(() {
                    // _amount = double.parse(user.balance);
                    _realAmount = double.parse(user.balance);
                    _blockedAmount = double.parse(user.balanceInBlock);
                  });
                });
              },
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  '${localization.withdraw}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              color: whiteColor,
              textColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row _exchangeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: ShapeDecoration(
              color: primaryColor2,
              shape: PolygonBorder(
                sides: 8,
                borderRadius: 8.0,
                border: BorderSide(
                  color: brightBlue,
                  width: 3,
                ),
              ),
            ),
            child: Image(
              image: AssetImage("assets/images/tenge.png"),
              height: 15,
              width: 15,
            ),
          ),
          onTap: () {
            setState(() {
              _amount = _realAmount / _tengeCoef;
              _amount = num.parse(_amount.toStringAsFixed(3));
              _symbol = '${String.fromCharCodes(Runes('\u20B8'))}';
              _globalCoef = _tengeCoef;
            });
          },
        ),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: ShapeDecoration(
              color: primaryColor2,
              shape: PolygonBorder(
                sides: 8,
                borderRadius: 8.0,
                border: BorderSide(
                  color: brightBlue,
                  width: 3,
                ),
              ),
            ),
            child: Image(
              image: AssetImage("assets/images/ruble.png"),
              height: 15,
              width: 15,
            ),
          ),
          onTap: () {
            setState(() {
              _amount = _realAmount / _rubleCoef;
              _amount = num.parse(_amount.toStringAsFixed(3));
              _symbol = '${String.fromCharCodes(Runes('\u20BD'))}';
              _globalCoef = _rubleCoef;
            });
          },
        ),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: ShapeDecoration(
              color: primaryColor2,
              shape: PolygonBorder(
                sides: 8,
                borderRadius: 8.0,
                border: BorderSide(
                  color: brightBlue,
                  width: 3,
                ),
              ),
            ),
            child: Image(
              image: AssetImage("assets/images/dollar.png"),
              height: 15,
              width: 15,
            ),
          ),
          onTap: () {
            setState(() {
              _amount = _realAmount / _dollarCoef;
              _amount = num.parse(_amount.toStringAsFixed(3));
              _symbol = '${String.fromCharCodes(Runes('\u0024'))}';
              _globalCoef = _dollarCoef;
            });
          },
        ),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: ShapeDecoration(
              color: primaryColor2,
              shape: PolygonBorder(
                sides: 8,
                borderRadius: 8.0,
                border: BorderSide(
                  color: brightBlue,
                  width: 3,
                ),
              ),
            ),
            child: Image(
              image: AssetImage("assets/images/euro.png"),
              height: 15,
              width: 15,
            ),
          ),
          onTap: () {
            setState(() {
              _amount = _realAmount / _euroCoef;
              _amount = num.parse(_amount.toStringAsFixed(3));
              _symbol = '${String.fromCharCodes(Runes('\u20AC'))}';
              _globalCoef = _euroCoef;
            });
          },
        ),
      ],
    );
  }
}
