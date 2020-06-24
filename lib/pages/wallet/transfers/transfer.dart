import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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


class TransferPage extends StatefulWidget {
  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  Api api = Api();

  showAlertDialog(BuildContext context, String type, String message) {
    // set up the button
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
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

    // show the dialog
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
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/background_little.png',
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        child: AppBar(
                          centerTitle: true,
                          title: Text("${localization.toIndigo24Client}"),
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
                  SizedBox(height: 10,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
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
        "Клиенту Indigo24",
        style: TextStyle(
          color: Color(0xFF001D52),
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();
  bool checked = false;
  _onPasscodeEntered(String enteredPasscode) {


    bool isValid = '${user.pin}' == enteredPasscode;
    _verificationNotifier.add(isValid);
    if(enteredPasscode == user.pin){
      Navigator.maybePop(context);
      Navigator.maybePop(context);
      if(receiverController.text.isNotEmpty && sumController.text.isNotEmpty){
          api.checkPhoneForSendMoney(receiverController.text).then((result) {
            print('transfer result $result');
            if (result['message'] == 'Not authenticated' && result['success'].toString() == 'false') {
              logOut(context);
              return result;
            } else {
              if (result["success"].toString() == 'true') {
                api.doTransfer(result["toID"], sumController.text).then((res) {
                  if(res['success'].toString() == 'false') 
                    showAlertDialog(context, '0', res['message']); 
                  else{
                    showAlertDialog(context, '1', res['message']);
                    api.getBalance().then((result){
                      setState(() {
                      });
                    });
                  }
                });
              } else{
                showAlertDialog(context, '0', result['message']);
              }
              return result;
            }
          });
      } else{
        showAlertDialog(context, '0', 'Заполните все поля');
      }
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
            title: '$title',
            withPin: withPin,
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
            _showLockScreen(
              context,
              '${localization.enterPin}',
              opaque: false,
              cancelButton: Text('Cancel',style: const TextStyle(fontSize: 16, color: Color(0xFF001D52)),semanticsLabel: 'Cancel'));
          },
          child: Container(
            height: 50,
            width: 200,
            child: Center(
              child: Text(
                '${localization.transfer}',
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
              InkWell(
                child: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://media.indigo24.com/avatars/noAvatar.png",
                    ),
                  ),
                ),
                onTap: () {
                  print('transfer avatar is pressed');
                },
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
                    decoration: InputDecoration.collapsed(
                        hintText: '${localization.amount}'),
                    style: TextStyle(fontSize: 20),
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

  final amountController = TextEditingController();
}