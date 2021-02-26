import 'package:indigo24/pages/wallet/refill/refill_list.dart';
import 'package:indigo24/services/constants.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/wallet/balance_history/balance_history.dart';
import 'package:indigo24/pages/wallet/payments/paymnets_category/payments_category.dart';
import 'package:indigo24/pages/wallet/transfers/transfer_list.dart';
import 'package:indigo24/pages/wallet/wallet/symbol/symbol_interface.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_logout.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/pin/pin_code.dart';
import 'package:polygon_clipper/polygon_border.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization/localization.dart';

import 'package:indigo24/pages/tabs/tabs.dart';
import '../withdraw/withdraw_list.dart';
import 'symbol_impl/dollar_symbol.dart';
import 'symbol_impl/euro_symbol.dart';
import 'symbol_impl/ruble_symbol.dart';
import 'symbol_impl/tenge_symbol.dart';
import 'package:indigo24/pages/wallet/wallet/symbol/symbol_enum.dart';

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
double _alfaAmount = double.parse(user.balanceACB);
dynamic userAsiaBalance = user.balance;

class _WalletTabState extends State<WalletTab> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  bool _needToPreloade = false;
  bool _withPin;

  double _blockedAmount = 0;
  double _realAmount = 0;
  double _alfaRealAmount = 0;

  SymbolInterface globalSymbol = TengeSymbol();
  SymbolInterface euroSymbol = EuroSymbol();
  SymbolInterface tengeSymbol = TengeSymbol();
  SymbolInterface dollarSymbol = DollarSymbol();
  SymbolInterface rubleSymbol = RubleSymbol();

  String _tempPasscode = '';

  Api _api = Api();

  @override
  void initState() {
    _api.getBalance();
    if ('${user.pin}'.toString() == 'false') {
      _withPin = false;
    }
    Timer.run(() {
      _withPin == false
          ? _showLockScreen(
              context,
              '${Localization.language.createPin}',
              withPin: _withPin,
            )
          : _showLockScreen(
              context,
              '${Localization.language.enterPin}',
            );
    });

    _realAmount = double.parse(user.balance);
    _alfaRealAmount = double.parse(user.balanceACB);
    _blockedAmount = double.parse(user.balanceInBlock);
    _api.getExchangeRate().then((v) {
      if (v['message'] == 'Not authenticated' &&
          v['success'].toString() == 'false') {
        logOut(context);
        return true;
      } else {
        var ex = v["exchangeRates"];
        euroSymbol = EuroSymbol(coef: double.parse(ex['EUR']));
        tengeSymbol = TengeSymbol(coef: 1.0);
        dollarSymbol = DollarSymbol(coef: double.parse(ex['USD']));
        rubleSymbol = RubleSymbol(coef: double.parse(ex['RUB']));
        return false;
      }
    });
    super.initState();
  }

  void dispose() {
    _api.getBalance();
    _verificationNotifier.close();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
  }

  _showLockScreen(BuildContext context, String title, {bool withPin}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
          title: title,
          withPin: withPin,
          passwordEnteredCallback: _onPasscodeEntered,
          shouldTriggerVerification: _verificationNotifier.stream,
          backgroundColor: milkWhiteColor,
          cancelCallback: _onPasscodeCancelled,
        ),
      ),
    );
  }

  _onPasscodeEntered(String enteredPasscode) {
    if (user.pin == 'waiting' && _tempPasscode == enteredPasscode) {
      _api.createPin(enteredPasscode);
      Navigator.pop(context);
    }
    if ('${user.pin}'.toString() == 'waiting' &&
        _tempPasscode != enteredPasscode) {
      return showIndigoDialog(
        context: context,
        builder: CustomDialog(
          description: Localization.language.incorrectPin,
          yesCallBack: () {
            Navigator.pop(context);
          },
        ),
      );
    }
    if ('${user.pin}' == 'false') {
      user.pin = 'waiting';
      _tempPasscode = enteredPasscode;
    }

    bool isValid = '${user.pin}' == enteredPasscode;

    if (isValid) {
      Future.delayed(const Duration(milliseconds: 250), () {
        _verificationNotifier.add(isValid);
        Navigator.pop(context);
      });
    } else {
      _verificationNotifier.add(isValid);
    }
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
  Widget build(BuildContext context) {
    _amount = _realAmount / globalSymbol.coef;
    _alfaAmount = _alfaRealAmount / globalSymbol.coef;
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _needToPreloade = true;
          });
          await _api.getBalance().then((result) {
            setState(() {
              _needToPreloade = false;
            });
          });
          setState(() {
            _realAmount = double.parse(user.balance);
            _blockedAmount = double.parse(user.balanceInBlock);
          });
        },
        child: Scaffold(
          backgroundColor: whiteColor,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            child: AppBar(
              centerTitle: true,
              brightness: Brightness.dark,
            ),
            preferredSize: Size.fromHeight(0.0),
          ),
          body: Stack(
            children: <Widget>[
              ScrollConfiguration(
                behavior: MyBehavior(),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("${assetsPath}wallet_header.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Stack(
                              children: [
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    '${Localization.language.wallet}',
                                    style: fS26(c: 'ffffff'),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 0.6,
                              margin: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              color: brightGreyColor,
                            ),
                            _balance(),
                            Text(
                              '${Localization.language.alfaBank}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            _balanceAmount(true),
                            _exchangeButtons(),
                            SizedBox(height: 10),
                            globalSymbol.type == Symbol.tenge
                                ? Container(
                                    width: size.width,
                                    height: 30,
                                    color: darkPrimaryColor,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      '',
                                    ),
                                  )
                                : _exchangeCurrency(size),
                          ],
                        ),
                      ),
                      _blockedBalance(size),
                      Container(
                        width: size.width,
                        color: darkPrimaryColor,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            _balance(),
                            Text(
                              '${Localization.language.asiaCreditBank}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            _balanceAmount(false),
                          ],
                        ),
                      ),
                      Container(
                        color: whiteColor,
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
                            _historyBalance(size),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _needToPreloade
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(),
            ],
          ),
        ),
      ),
    );
  }

  Container _exchangeCurrency(size) {
    String tempExchangeRate = '${globalSymbol.coef}';
    return Container(
      width: size.width,
      color: darkPrimaryColor,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 20,
            child: FittedBox(
              child: Text(
                globalSymbol.type == Symbol.dollar ? ' ' : '1',
                style:
                    TextStyle(color: whiteColor, fontWeight: FontWeight.w300),
              ),
            ),
          ),
          Container(
            height: 15,
            child: FittedBox(
              child: Image(
                image: AssetImage("$assetsPath${globalSymbol.symbolTitle}.png"),
                height: 15,
                width: 15,
              ),
            ),
          ),
          Container(
            height: 20,
            child: FittedBox(
              child: Text(
                globalSymbol.type == Symbol.dollar ? '1' : ' ',
                style:
                    TextStyle(color: whiteColor, fontWeight: FontWeight.w300),
              ),
            ),
          ),
          Container(
            height: 20,
            child: FittedBox(
              child: Text(
                '= $tempExchangeRate ',
                style:
                    TextStyle(color: whiteColor, fontWeight: FontWeight.w300),
              ),
            ),
          ),
          Image(
            image: AssetImage("${assetsPath}tenge.png"),
            height: 15,
            width: 15,
          ),
        ],
      ),
    );
  }

  Container _historyBalance(Size size) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: blackColor,
            blurRadius: 10.0,
            spreadRadius: -10,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: ButtonTheme(
        minWidth: size.width * 0.8,
        height: 70,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BalanceHistoryPage(),
              ),
            ).whenComplete(() async {
              await _api.getBalance();
              setState(() {
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
                  image: AssetImage("${assetsPath}balanceHistory.png"),
                  height: 40,
                  width: 40,
                ),
                Text(
                  '${Localization.language.historyBalance}',
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
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: blackColor,
            blurRadius: 10.0,
            spreadRadius: -10,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: ButtonTheme(
        minWidth: size.width * 0.8,
        height: 70,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TransferListPage()))
                .whenComplete(() async {
              await _api.getBalance();
              setState(() {
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
                  image: AssetImage("${assetsPath}transfers.png"),
                  height: 40,
                ),
                Text(
                  '${Localization.language.transfers}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
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
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: blackColor,
            blurRadius: 10.0,
            spreadRadius: -10,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: ButtonTheme(
        height: 70,
        child: RaisedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentsCategoryPage(),
              ),
            ).whenComplete(() async {
              await _api.getBalance();
              setState(() {
                // _amount = double.parse(user.balance);
                _realAmount = double.parse(user.balance);
                _alfaAmount = double.parse(user.balanceACB);
                _blockedAmount = double.parse(user.balanceInBlock);
              });
            });
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image(
                  image: AssetImage("${assetsPath}payments.png"),
                  height: 40,
                ),
                Text(
                  '${Localization.language.payments}',
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

  Text _balance() {
    return Text(
      '${Localization.language.eMoneyBalance}',
      style: fS18(c: 'ffffff'),
    );
  }

  Widget _balanceAmount(bool main) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '${main ? _amount.toStringAsFixed(2) : _alfaAmount.toStringAsFixed(2)}',
          style: fS26(c: 'ffffff'),
        ),
        Image(
          image: AssetImage("$assetsPath${globalSymbol.symbolTitle}.png"),
          height: 25,
          width: 25,
        ),
      ],
    );
  }

  Container _blockedBalance(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
        ),
      ),
      width: size.width,
      child: Column(
        children: <Widget>[
          Text(
            '${Localization.language.balanceInBlock}',
            style: fS18w200(c: 'ffffff'),
          ),
          Container(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${_blockedAmount.toStringAsFixed(2)}',
                style: fS26w200(c: 'ffffff'),
              ),
              Image(
                image: AssetImage("${assetsPath}tenge.png"),
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
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: blackColor,
                blurRadius: 10.0,
                spreadRadius: -10,
                offset: Offset(0.0, 0.0),
              )
            ],
          ),
          child: ButtonTheme(
            minWidth: size.width * 0.42,
            height: 50,
            child: RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RefillListPage(),
                  ),
                ).whenComplete(() async {
                  await _api.getBalance();
                  setState(() {
                    _realAmount = double.parse(user.balance);
                    _alfaAmount = double.parse(user.balanceACB);

                    _blockedAmount = double.parse(user.balanceInBlock);
                  });
                });
              },
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  '${Localization.language.refill}'.toUpperCase(),
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
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: blackColor,
                blurRadius: 10.0,
                spreadRadius: -10,
                offset: Offset(0.0, 0.0),
              )
            ],
          ),
          child: ButtonTheme(
            minWidth: size.width * 0.42,
            height: 50,
            child: RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WithdrawListPage(),
                  ),
                ).whenComplete(() async {
                  await _api.getBalance();
                  setState(() {
                    // _amount = double.parse(user.balance);
                    _realAmount = double.parse(user.balance);
                    _alfaAmount = double.parse(user.balanceACB);

                    _blockedAmount = double.parse(user.balanceInBlock);
                  });
                });
              },
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  '${Localization.language.withdraw}'.toUpperCase(),
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
        symbolBuilder(tengeSymbol),
        symbolBuilder(rubleSymbol),
        symbolBuilder(dollarSymbol),
        symbolBuilder(euroSymbol),
      ],
    );
  }

  symbolBuilder(SymbolInterface symbol) {
    return GestureDetector(
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
          image: AssetImage("$assetsPath${symbol.symbolTitle}.png"),
          height: 15,
          width: 15,
        ),
      ),
      onTap: () {
        setState(() {
          _amount = num.parse((_realAmount / symbol.coef).toStringAsFixed(2));
          _alfaAmount =
              num.parse((_alfaRealAmount / symbol.coef).toStringAsFixed(2));

          globalSymbol = symbol;
        });
      },
    );
  }
}
