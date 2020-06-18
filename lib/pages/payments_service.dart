import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';

import '../services/api.dart';
import '../style/fonts.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PaymentsServicePage extends StatefulWidget {
  String _logo;
  int serviceID;
  String title;

  PaymentsServicePage(this.serviceID, this._logo, this.title);

  @override
  _PaymentsServicePageState createState() => _PaymentsServicePageState();
}

class _PaymentsServicePageState extends State<PaymentsServicePage> {
  Api api = Api();
  
  showAlertDialog(BuildContext context, String type, String message) {
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
        // type == '1' 
        // ? Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => PaymentHistoryPage()),(r) => false) 
        // : 
        Navigator.pop(context);
      },
    );

    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text(type == '0' ? "Внимание" : type == '1' ? 'Успешно' : 'Ошибка' ),
      content: Text(message),
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

  final receiverController = TextEditingController();
  final sumController = TextEditingController();
  var loginFormatter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: FutureBuilder(
            future: api.getService(widget.serviceID).then((getServiceResult) {
              getServiceResult['result'].forEach((element){
                if(element['name'] == 'account'){
                  accauntMask = element['mask'];
                  loginFormatter = MaskTextInputFormatter(mask: '${element['mask']}', filter: { "*" : RegExp(r'[0-9]') });
                }
              });
              return getServiceResult;
            }),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return snapshot.hasData ? Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/background_little.png',
                      ),
                      Positioned(
                        child: AppBar(
                          title: Text("${widget.title}"),
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
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 45, left: 0, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 0.6,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              color: Color(0xFFD1E1FF),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 30, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 15),
                                  Text(
                                    '${localization.walletBalance}',
                                    style: fS14(c: 'FFFFFF'),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '${user.balance} ₸',
                                    style: fS18(c: 'FFFFFF'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                    mainPaymentsDetailMobile(snapshot.data),
                    transferButton(),
                ],
              ) : Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
  Container transferButton() {
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
            api.payService(
              widget.serviceID,
              '${receiverController.text.replaceAll(' ','').replaceAll('+','')}',
              sumController.text,
            ).then((services) {
              if (services['message'] == 'Not authenticated' && services['success'].toString() == 'false') {
                logOut(context);
                return services;
              } else {
                  if(services['success'].toString() == 'false') 
                    showAlertDialog(context, '0', services['message']); 
                  else
                    {
                      showAlertDialog(context, '1', services['message']);
                      api.getBalance().then((result){
                        setState(() {
                        });
                      });
                    }
                return services;
              }
            });
          },
          child: Container(
            height: 50,
            width: 200,
            child: Center(
              child: Text(
                '${localization.pay}',
                style: TextStyle(color: Color(0xFF0543B8), fontWeight: FontWeight.w800),
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
  String accauntMask = '';
  Container mainPaymentsDetailMobile(snapshot) {
    return Container(
      height: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${localization.minAmount} ${snapshot['service']['min']} KZT', style: TextStyle(color: Color(0xFF001D52))),
                    Text('${localization.maxAmount} ${snapshot['service']['max']} KZT', style: TextStyle(color: Color(0xFF001D52))),
                    Text('${localization.commission} ${snapshot['service']['commission']}%', style: TextStyle(color: Color(0xFF001D52))),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 1.0,
            color: Colors.grey,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          loginFormatter,  
                          LengthLimitingTextInputFormatter(25),
                        ],
                        decoration: InputDecoration.collapsed(
                          hintText: '${localization.phoneNumber}',
                        ),
                        controller: receiverController,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                child: Image.network('${widget._logo}', width: 40.0),
              ),
            ],
          ),
          Container(
            height: 1.0,
            color: Colors.grey,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: sumController,
                    decoration: InputDecoration.collapsed(hintText: '${localization.amount}'),
                    style: TextStyle(fontSize: 20),
                    validator: (value) {
                      if (value.isEmpty) {
                        print('empty');
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
