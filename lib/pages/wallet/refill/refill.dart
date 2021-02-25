import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:indigo24/pages/wallet/refill/refill_web.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/services/user.dart' as user;

class RefillPage extends StatefulWidget {
  final provider;

  const RefillPage(this.provider);
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
      child: Container(
        color: whiteColor,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: milkWhiteColor,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("${assetsPath}wallet_header.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            IndigoAppBarWidget(
                              centerTitle: true,
                              title: Text(
                                Localization.language.refill,
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
                                        EdgeInsets.only(left: 20, right: 10),
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
                                                "${assetsPath}tenge.png",
                                              ),
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
                      Container(
                        color: whiteColor,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(refillMax.length)
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration.collapsed(
                            hintText: '${Localization.language.amount}',
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
                                      widget.provider['max']) {
                                    setState(() {
                                      _commission = (int.parse(text) *
                                              widget.provider['commission'] /
                                              100)
                                          .toStringAsFixed(2);
                                    });
                                  }
                                }
                              }
                              if (double.parse(_commission) <=
                                  widget.provider['min_commission']) {
                                setState(() {
                                  _commission =
                                      '${widget.provider['min_commission']}';
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
                          '${Localization.language.commission} ${widget.provider['commission']}%',
                        ),
                      ),
                      Center(
                        child: Text(
                          '${Localization.language.commission} $_commission KZT',
                        ),
                      ),
                      Center(
                        child: Text(
                          '${Localization.language.minCommission} ${widget.provider['min_commission']} KZT',
                        ),
                      ),
                      Center(
                        child: Text(
                          '${Localization.language.minAmount} ${widget.provider['min']} KZT',
                        ),
                      ),
                      Center(
                        child: Text(
                          '${Localization.language.maxAmount} ${widget.provider['max']} KZT',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: blackColor,
                              blurRadius: 10.0,
                              spreadRadius: -10,
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
                                    .refill(widget.provider['url'],
                                        _amountController.text)
                                    .then((withdrawResult) {
                                  setState(() {
                                    _preloader = false;
                                  });
                                  if (withdrawResult['success'].toString() ==
                                      'true') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RefillWebView(
                                          url: withdrawResult['result']
                                              ['redirectURL'],
                                        ),
                                      ),
                                    );
                                  } else {
                                    showIndigoDialog(
                                      context: context,
                                      builder: CustomDialog(
                                        description:
                                            '${withdrawResult['message']}',
                                        yesCallBack: () {
                                          Navigator.pop(context);
                                        },
                                      ),
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
                                  '${Localization.language.refill}',
                                  style: TextStyle(
                                      color: primaryColor,
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
