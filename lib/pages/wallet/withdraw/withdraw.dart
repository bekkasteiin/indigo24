import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/wallet/withdraw/withdraw_web.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/services/user.dart' as user;

class WithdrawPage extends StatefulWidget {
  final provider;

  const WithdrawPage(this.provider);

  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  bool _preloader = false;
  bool _checked = false;
  bool showError = false;
  bool showHintError = false;

  String _commission = '0';

  TextEditingController _amountController;

  Api _api;

  @override
  void initState() {
    super.initState();
    _api = Api();

    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _api.getBalance();
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
        color: Colors.white,
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
                            image:
                                AssetImage("assets/images/wallet_header.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            IndigoAppBarWidget(
                              centerTitle: true,
                              title: Text(
                                localization.withdraw,
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
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(withdrawMax.length)
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration.collapsed(
                            hintText: localization.amount,
                            hintStyle: TextStyle(
                              color: showHintError ? redColor : greyColor,
                            ),
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
                          '${localization.commission} ${widget.provider['commission']}%',
                        ),
                      ),
                      Center(
                        child: Text(
                          '${localization.commission} $_commission KZT',
                        ),
                      ),
                      Center(
                        child: Text(
                          '${localization.minCommission} ${widget.provider['min_commission']} KZT',
                        ),
                      ),
                      Center(
                        child: Text(
                          '${localization.minAmount} ${widget.provider['min']} KZT',
                        ),
                      ),
                      Center(
                        child: Text(
                          '${localization.maxAmount} ${widget.provider['max']} KZT',
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              localization.withdrawTerm,
                              style: TextStyle(
                                fontSize: 10,
                                color: showError ? redColor : primaryColor,
                              ),
                            ),
                            onChanged: (bool value) {
                              setState(() {
                                _checked = !_checked;
                              });
                            },
                            value: _checked,
                          ),
                        ),
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
                              if (_checked) {
                                setState(() {
                                  showError = false;
                                });
                                if (_amountController.text.isNotEmpty) {
                                  setState(() {
                                    showHintError = false;
                                  });
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);

                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }

                                  setState(() {
                                    _preloader = true;
                                  });

                                  _api
                                      .withdraw(widget.provider['url'],
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
                                          builder: (context) => WithdrawWebView(
                                            url: withdrawResult['result']
                                                ['redirectURL'],
                                          ),
                                        ),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            CustomDialog(
                                          description:
                                              '${withdrawResult['message']}',
                                          yesCallBack: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      );
                                    }
                                  });
                                } else {
                                  setState(() {
                                    showHintError = true;
                                  });
                                }
                              } else {
                                setState(() {
                                  showError = true;
                                });
                              }
                            },
                            child: Container(
                              height: 50,
                              width: 200,
                              child: Center(
                                child: Text(
                                  '${localization.withdraw}',
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
