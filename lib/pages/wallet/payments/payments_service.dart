import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/services/api.dart';

import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/widgets/circle.dart';
import 'package:indigo24/widgets/keyboard.dart';
import 'package:indigo24/widgets/pin_code.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PaymentsServicePage extends StatefulWidget {
  final String _logo;
  final int serviceID;
  final String title;

  PaymentsServicePage(this.serviceID, this._logo, this.title);

  @override
  _PaymentsServicePageState createState() => _PaymentsServicePageState();
}

class _PaymentsServicePageState extends State<PaymentsServicePage> {
  Api api = Api();
  
  showAlertDialog(BuildContext context, String type, String message, {bool withPop})  {
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
        // type == '1' 
        // ? Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => PaymentHistoryPage()),(r) => false) 
        // : 
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        if(withPop != null){
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        } else{
          Navigator.pop(context);
        }

      },
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        print('showed dialog');
        return ConstrainedBox( 
          constraints: BoxConstraints(maxHeight: 1.0),
          child: CupertinoAlertDialog(
            title: Text(type == '0' ? "${localization.attention}" : type == '1' ? '${localization.success}' : '${localization.error}' ),
            content: Text(message),
            actions: [
              okButton,
            ],
          ),
        );
      },
    );
  }
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();
  bool isAuthenticated = false;

  final receiverController = TextEditingController();
  final sumController = TextEditingController();
  var loginFormatter;

    _showLockScreen(BuildContext context, String title,
      {
      bool withPin,
      bool opaque,
      CircleUIConfig circleUIConfig,
      KeyboardUIConfig keyboardUIConfig,
      Widget cancelButton,
      List<String> digits}) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) => PasscodeScreen(
            withPin: withPin,
            title: '$title',
            passwordEnteredCallback: _onPasscodeEntered,
            cancelButton: cancelButton,
            deleteButton: Text(
              'Delete',
              style: const TextStyle(fontSize: 16, color: Color(0xFF001D52)),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Color(0xFFF7F7F7),
            cancelCallback: _onPasscodeCancelled,
            digits: digits,
          ),
        ));
  }
  
    _onPasscodeEntered(String enteredPasscode) {
    print('user pin is ${user.pin}');
    if('${user.pin}'.toString() == 'false'){
      Navigator.maybePop(context);
      Navigator.maybePop(context);
      print('set pin');
      api.createPin(enteredPasscode);
    }

    bool isValid = '${user.pin}' == enteredPasscode;
    _verificationNotifier.add(isValid);
    if (isValid) {
      print(' is really valid ');
      api.payService(widget.serviceID,'${receiverController.text.replaceAll(' ','').replaceAll('+','')}',sumController.text).then((services) {
        if (services['message'] == 'Not authenticated' && services['success'].toString() == 'false') {
          logOut(context);
          return services;
        } else {
            if(services['success'].toString() == 'false') 
              showAlertDialog(context, '0', services['message']); 
            else {
                showAlertDialog(context, '1', services['message']);
                api.getBalance().then((result){
                  setState(() {
                  });
                });
              }
          return services;
        }
      });
      setState(() {
        this.isAuthenticated = isValid;
      });
    }
 
  }

  _onPasscodeCancelled() {
    Navigator.pop(context);
  }
  var temp;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: FutureBuilder(
            future: api.getService(widget.serviceID).then((getServiceResult) {
              getServiceResult['result'].forEach((element){
                print('forEach element ${element['name']}');
                if('${element['name']}' == 'account'){
                  print(element);
                  accountMask = element['mask'];
                  if(element['mask'] == ' '){
                    print('if');
                    // temp = 'false';
                    // loginFormatter = MaskTextInputFormatter(filter: { "*" : RegExp(r'[0-9]') });
                  } else{
                    print('else else');
                    loginFormatter = MaskTextInputFormatter(mask: '${element['mask']}', filter: { "*" : RegExp(r'[0-9]') });
                  }
                }
              });              
              return getServiceResult;
            }),
            builder: (context, snapshot) {
              return snapshot.hasData ? 
                GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Image.asset(
                            'assets/images/background_little.png',
                            fit: BoxFit.fill,
                          ),
                          Column(
                            children: <Widget>[
                              AppBar(
                                centerTitle: true,
                                title: Text("${localization.payments}"),
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
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          padding: EdgeInsets.only(left: 20, top: 20),
                          child: Text('${widget.title}', maxLines: 3, style: TextStyle(fontSize: 16, color: Color(0xFF001D52)))
                        ),
                        mainPaymentsDetailMobile(snapshot.data),
                        SizedBox(height: 10,),
                        Center(child: Text('${localization.minAmount} ${snapshot.data['service']['min']} KZT', style: TextStyle(color: Color(0xFF001D52)))),
                        Center(child: Text('${localization.maxAmount} ${snapshot.data['service']['max']} KZT', style: TextStyle(color: Color(0xFF001D52)))),
                        Center(child: Text('${localization.commission} ${snapshot.data['service']['commission']}%', style: TextStyle(color: Color(0xFF001D52)))),
                        transferButton(snapshot),
                        SizedBox(height: 10,)
                    ],
                  ),
                ),
              ) : Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
  Container transferButton(snapshot) {
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
            if(receiverController.text.isNotEmpty & sumController.text.isNotEmpty){
              RegExp exp = new RegExp(r"^7[0-9]{10}$");
              String str = "${receiverController.text.replaceAll(' ','').replaceAll('+','')}";
              bool matches = exp.hasMatch(str);
              print(matches);
              if(int.parse(sumController.text) >= snapshot.data['service']['min']){
                if(int.parse(sumController.text) <= snapshot.data['service']['max']){
                  if(matches){
                    await _showLockScreen(context,'${localization.enterPin}',opaque: false, cancelButton: Text('Cancel', style: const TextStyle(fontSize: 16, color: Color(0xFF001D52)), semanticsLabel: 'Cancel'));
                  } else{
                    showAlertDialog(context, '0', 'Введите корректный номер аккаунта');
                  }
                } else{
                  showAlertDialog(context, '0', 'Введите сумму ниже максимальной отметки');
                }
              }
              else{
                showAlertDialog(context, '0', 'Введите сумму выше минимальной отметки');
              }
            }
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
  String accountMask = '';
  Container mainPaymentsDetailMobile(snapshot) {
    return Container(
      height: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        inputFormatters: temp == 'false' ? [
                          LengthLimitingTextInputFormatter(25),
                        ] : [
                          loginFormatter,  
                          LengthLimitingTextInputFormatter(25),
                        ] ,
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
                    inputFormatters: [
                          BlacklistingTextInputFormatter(new RegExp(r"^(?!(0))$")),
                    ],
                    onChanged: (value){
                      if(sumController.text[0] == '0'){
                        sumController.clear();
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
