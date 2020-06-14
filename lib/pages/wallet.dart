import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/refill.dart';
import 'package:indigo24/pages/withdraw.dart';
import 'package:indigo24/services/api.dart';
import 'package:polygon_clipper/polygon_border.dart';
import '../style/fonts.dart';
import 'payments_category.dart';
import 'transfer_list.dart';
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

class _WalletTabState extends State<WalletTab> {
  double _amount;
  double _blockedAmount = 0;
  String _symbol;
  double _realAmount = 0;
  double _tengeCoef = 1;
  double _euroCoef = 0;
  double _rubleCoef = 0;
  double _dollarCoef = 0;

  var api = Api();

  @override
  void initState() {
    _symbol = '₸';
    _realAmount = double.parse(user.balance);
    _blockedAmount = double.parse(user.balanceInBlock);
    _amount = _realAmount;
    api.getExchangeRate().then((v) {
      var ex = v["exchangeRates"];
      _euroCoef = double.parse(ex['EUR']);
      _rubleCoef = double.parse(ex['RUB']);
      _dollarCoef = double.parse(ex['USD']);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          child: AppBar(
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
                  Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text('${localization.wallet}', style: fS26(c: 'ffffff')),
                      _devider(),
                      _balance(),
                      SizedBox(height: 10),
                      _balanceAmount(),
                      _exchangeButtons(),
                      _blockedBalance(size),
                      SizedBox(height: 20),
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Column(
                          children: <Widget>[
                            _payInOut(size),
                            SizedBox(height: 20),
                            _payments(size),
                            SizedBox(height: 20),
                            _transfer(size),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransferListPage()),
            );
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

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
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
              MaterialPageRoute(builder: (context) => PaymentsCategoryPage()),
            );
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

  Container _devider() {
    return Container(
      height: 0.6,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: Color(0xFFD1E1FF),
    );
  }

  Text _balance() {
    return Text(
      '${localization.balance}',
      style: fS18(c: 'ffffff'),
    );
  }

  Text _balanceAmount() {
    if (_symbol == '\$')
      return Text(
        '$_symbol ${_amount.toStringAsFixed(2)}',
        style: fS26(c: 'ffffff'),
      );
    return Text(
      '${_amount.toStringAsFixed(2)} $_symbol',
      style: fS26(c: 'ffffff'),
    );
  }

  Container _blockedBalance(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      color: Color(0xFF0543B8),
      width: size.width,
      child: Column(
        children: <Widget>[
          Text('${localization.balanceInBlock}', style: fS18w200(c: 'ffffff')),
          Container(height: 5),
          Text('${_blockedAmount.toStringAsFixed(2)} ₸',
              style: fS26w200(c: 'ffffff')),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RefillPage()),
                );
              },
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  '${localization.refill}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              color: Color(0xFFFFFFFF),
              textColor: Color(0xFF0543B8),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WithdrawPage()),
                );
              },
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  '${localization.withdraw}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              color: Color(0xFFFFFFFF),
              textColor: Color(0xFF0543B8),
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
              color: Color(0xFF1C4D9B),
              shape: PolygonBorder(
                sides: 8,
                borderRadius: 8.0,
                border: BorderSide(
                  color: Color(0xFF4E74B1),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              '₸',
              style: fS20(c: 'FFFFFF'),
            ),
          ),
          onTap: () {
            setState(() {
              _amount = _realAmount / _tengeCoef;
              _amount = num.parse(_amount.toStringAsFixed(3));
              _symbol = '₸';
            });
          },
        ),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: ShapeDecoration(
              color: Color(0xFF1C4D9B),
              shape: PolygonBorder(
                sides: 8,
                borderRadius: 8.0,
                border: BorderSide(
                  color: Color(0xFF4E74B1),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              '₽',
              style: fS20(c: 'FFFFFF'),
            ),
          ),
          onTap: () {
            setState(() {
              _amount = _realAmount / _rubleCoef;
              _amount = num.parse(_amount.toStringAsFixed(3));
              _symbol = '₽';
            });
          },
        ),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: ShapeDecoration(
              color: Color(0xFF1C4D9B),
              shape: PolygonBorder(
                sides: 8,
                borderRadius: 8.0,
                border: BorderSide(
                  color: Color(0xFF4E74B1),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              '\$',
              style: fS20(c: 'FFFFFF'),
            ),
          ),
          onTap: () {
            setState(() {
              _amount = _realAmount / _dollarCoef;
              _amount = num.parse(_amount.toStringAsFixed(3));
              _symbol = '\$';
            });
          },
        ),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(15.0),
            decoration: ShapeDecoration(
              color: Color(0xFF1C4D9B),
              shape: PolygonBorder(
                sides: 8,
                borderRadius: 8.0,
                border: BorderSide(
                  color: Color(0xFF4E74B1),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              '€',
              style: fS20(c: 'FFFFFF'),
            ),
          ),
          onTap: () {
            setState(() {
              _amount = _realAmount / _euroCoef;
              _amount = num.parse(_amount.toStringAsFixed(3));
              _symbol = '€';
            });
          },
        ),
      ],
    );
  }
}
