import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api.dart';
import 'package:http/http.dart' as http;

class WithdrawPage extends StatefulWidget {
  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  var client = new http.Client();

  final amountController = TextEditingController();

  Api api = Api();

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        brightness: Brightness.light,
        title: Text(
          "Вывод средств",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          Center(child: Text('Комиссия 2.8%')),
          Center(child: Text('Минимальная сумма 1000 KZT')),
          Center(child: Text('Минимальная комиссия 350 KZT')),
          Center(child: Text('Максимальная сумма 1000000 KZT')),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration.collapsed(
                hintText: 'Введите сумму',
              ),
              style: TextStyle(fontSize: 20),
              controller: amountController,
              onChanged: (String text) async {},
            ),
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
                      offset: Offset(0.0, 0.0))
                ]),
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 20, bottom: 10),
            child: ButtonTheme(
              minWidth: double.infinity,
              height: 100.0,
              child: FlatButton(
                onPressed: () async {
                  api.withdraw(amountController.text);
                },
                child: Text(
                  'Вывести',
                  style: TextStyle(
                      color: Color(0xFF0543B8), fontWeight: FontWeight.w800),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
