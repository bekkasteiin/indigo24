import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api.dart';
import '../style/fonts.dart';
import 'package:indigo24/services/user.dart' as user;

class TransferPage extends StatefulWidget {
  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  Api api = Api();
  String _balance = "";

  showAlertDialog(BuildContext context, String message) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Ошибка"),
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
        child: Scaffold(
          body: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Image.asset(
                    'assets/images/background_little.png',
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    child: AppBar(
                      title: Text("Клиенту Indigo24"),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 45, left: 20, right: 20),
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
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 15),
                              Text(
                                'Баланс кошелька',
                                style: fS14(c: 'FFFFFF'),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${user.balance}',
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

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
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

  Container transferButton() {
    return Container(
      height: 50,
      width: 200,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
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
            api.checkPhoneForSendMoney(receiverController.text).then((result) {
              print('to id ${result["toID"]}, ${sumController.text}');
              if(result["success"]){
                api.doTransfer(result["toID"], sumController.text).then((res){
                  print("sending $res");
                });
              }
              return result;
            });
          },
          child: Text(
            'Перевести',
            style: TextStyle(
                color: Color(0xFF0543B8), fontWeight: FontWeight.w600),
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
                          hintText: 'Телефон получателя',
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
                child: Image.network(
                    'https://media.indigo24.com/avatars/noAvatar.png',
                    width: 40.0),
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
                    decoration: InputDecoration.collapsed(hintText: 'Сумма'),
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

  final amountController = TextEditingController();

  Widget mainScreen(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          mainPaymentIndigoPurse(),
          SizedBox(
            height: 10,
          ),
          mainPaymentsDetailMobile(),
          _transferButton(),
        ],
      ),
    );
  }

  Container _transferButton() {
    return Container(
      height: 50,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        //@BOXSHADOW
        // boxShadow: const [
        //   BoxShadow(blurRadius: 3),
        // ],
      ),
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: ButtonTheme(
        minWidth: double.infinity,
        child: FlatButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () async {
            api.checkPhoneForSendMoney(receiverController.text);
          },
          child: Text(
            'Перевести',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Container mainPaymentIndigoPurse() {
    return Container(
      height: 80,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 50,
                        // child: Image.asset(
                        //   'assets/logoPurple.png',
                        //   width: 50.0,
                        // ),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        child: Text(
                          "Indigo кошелек",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Container(
                        child: Text(
                          "$_balance ₸",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        //@BOXSHADOW
        // boxShadow: const [
        //   BoxShadow(
        //     blurRadius: 3,
        //     color: const Color.fromARGB(130, 140, 140, 140),
        //   ),
        // ],
      ),
      padding: EdgeInsets.only(left: 20, right: 20),
      margin: EdgeInsets.only(left: 20, right: 20),
    );
  }
}
