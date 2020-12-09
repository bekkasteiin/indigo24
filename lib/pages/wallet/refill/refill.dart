import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:indigo24/pages/wallet/refill/refill_web.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';
import 'package:indigo24/services/user.dart' as user;

class RefillPage extends StatefulWidget {
  @override
  _RefillPageState createState() => _RefillPageState();
}

class _RefillPageState extends State<RefillPage> {
  bool _preloader;

  String _commission;

  Api _api;

  final FlutterWebviewPlugin flutterWebViewPlugin = FlutterWebviewPlugin();

  TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _preloader = false;
    _commission = '0';
    _api = Api();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _api.getBalance();
    _amountController.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: milkWhiteColor,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
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
                                title: Text(
                                  localization.refill,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 0.6,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      color: brightGreyColor,
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 30, right: 10),
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
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(refillMax.length)
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration.collapsed(
                            hintText: '${localization.amount}',
                          ),
                          style: TextStyle(fontSize: 20),
                          controller: _amountController,
                          onChanged: (String text) async {
                            if (_amountController.text.isNotEmpty) {
                              if (int.parse(_amountController.text) > 0) {
                                if (int.parse(_amountController.text) < 1000) {
                                  setState(() {
                                    _commission = '0';
                                  });
                                } else {
                                  if (double.parse(text) <=
                                      double.parse(refillMax)) {
                                    setState(() {
                                      _commission = (int.parse(text) *
                                              double.parse(refillCommission) /
                                              100)
                                          .toStringAsFixed(2);
                                    });
                                  }
                                }
                              }
                              if (double.parse(_commission) <=
                                  double.parse(refillMinCommission)) {
                                setState(() {
                                  _commission = '$refillMinCommission';
                                });
                              }
                            } else {
                              setState(() {
                                _commission = '0';
                              });
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      Center(
                        child: Text(
                          '${localization.commission} $refillCommission%',
                        ),
                      ),
                      Center(
                        child:
                            Text('${localization.commission} $_commission KZT'),
                      ),
                      Center(
                        child: Text(
                          '${localization.minCommission} $refillMinCommission KZT',
                        ),
                      ),
                      Center(
                        child: Text(
                          '${localization.minAmount} $refillMin KZT',
                        ),
                      ),
                      Center(
                        child: Text(
                          '${localization.maxAmount} $refillMax KZT',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      Container(
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
                              if (_amountController.text.isNotEmpty) {
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                setState(() {
                                  _preloader = true;
                                });
                                _api
                                    .refill(_amountController.text)
                                    .then((refillResult) {
                                  setState(() {
                                    _preloader = false;
                                  });
                                  if (refillResult['success'].toString() ==
                                      'true') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RefillWebView(
                                          url: refillResult['redirectURL'],
                                        ),
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialog(
                                            description:
                                                "${refillResult['message']}",
                                            yesCallBack: () {
                                              Navigator.pop(context);
                                            },
                                          );
                                        });
                                  }
                                });
                              }
                            },
                            child: Container(
                              height: 50,
                              width: 200,
                              child: Center(
                                child: Text(
                                  '${localization.refill}',
                                  style: TextStyle(
                                      color: Color(0xFF0543B8),
                                      fontWeight: FontWeight.w800),
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
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
                _preloader
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Center(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
