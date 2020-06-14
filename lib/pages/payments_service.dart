import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api.dart';
import '../style/fonts.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;

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
  var _balance;
  String _logo;
  showAlertDialog(BuildContext context, String message) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Внимание"),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Column(
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
              mainPaymentsDetailMobile(),
              transferButton(),
            ],
          ),
        ),
      ),
    );
  }
  Container transferButton() {
    return Container(
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
                offset: Offset(0.0, 0.0))
          ]),
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: ButtonTheme(
        minWidth: double.infinity,
        height: 100.0,
        child: FlatButton(
          onPressed: () async {
            api
                .payService(
              widget.serviceID,
              receiverController.text,
              sumController.text,
            )
                .then((services) {
              print('ho $services');
              return services;
            });
          },
          child: Text(
            '${localization.pay}',
            style: TextStyle(
                color: Color(0xFF0543B8), fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Container mainPaymentsDetailMobile() {
    return Container(
      height: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
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
