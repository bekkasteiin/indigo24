import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:indigo24/pages/wallet/refill/refill_web.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';

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
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: IndigoAppBarWidget(
          title: Text(
            '${localization.refill}',
            style: TextStyle(
              color: blackPurpleColor,
              fontWeight: FontWeight.w400,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  Center(
                    child: Text(
                      '${localization.commission} $refillCommission%',
                    ),
                  ),
                  Center(
                    child: Text(
                      '${localization.minAmount} $refillMin KZT',
                    ),
                  ),
                  Center(
                    child: Text(
                      '${localization.minCommission} $refillMinCommission KZT',
                    ),
                  ),
                  Center(
                    child: Text(
                      '${localization.maxAmount} $refillMax KZT',
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly,
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
                  Center(
                    child: Text('${localization.commission} $_commission KZT'),
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
                                Widget okButton = CupertinoDialogAction(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                );
                                CupertinoAlertDialog alert =
                                    CupertinoAlertDialog(
                                  title: Text("${localization.attention}"),
                                  content: Text('${refillResult['message']}'),
                                  actions: [
                                    okButton,
                                  ],
                                );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert;
                                  },
                                );
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
                        color: Color(0xFFFFFFFF),
                        textColor: Color(0xFF001D52),
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
            _preloader ? Center(child: CircularProgressIndicator()) : Center()
          ],
        ),
      ),
    );
  }
}
