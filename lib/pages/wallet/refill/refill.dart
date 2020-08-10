import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';

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
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(10),
              child: Image(
                image: AssetImage(
                  'assets/images/back.png',
                ),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          brightness: Brightness.light,
          title: Text(
            "${localization.refill}",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
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
                    child:
                        Text('${localization.commission} $refillCommission%'),
                  ),
                  Center(
                    child: Text('${localization.minAmount} $refillMin KZT'),
                  ),
                  Center(
                    child: Text(
                      '${localization.minCommission} $refillMinCommission KZT',
                    ),
                  ),
                  Center(
                    child: Text('${localization.maxAmount} $refillMax KZT'),
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
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          spreadRadius: -2,
                          offset: Offset(0.0, 0.0),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 20, bottom: 10),
                    child: ButtonTheme(
                      minWidth: double.infinity,
                      height: 100.0,
                      child: FlatButton(
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
                                    builder: (context) => buildWebviewScaffold(
                                      refillResult['redirectURL'],
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
                        child: Text(
                          '${localization.refill}',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            _preloader
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Center()
          ],
        ),
      ),
    );
  }

  WillPopScope buildWebviewScaffold(url) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(10),
              child: Image(
                image: AssetImage(
                  'assets/images/back.png',
                ),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          brightness: Brightness.light,
          title: Text(
            "${localization.refill}",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: WebviewScaffold(
            url: '$url',
            withZoom: true,
            withLocalStorage: true,
            hidden: false,
            initialChild: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
