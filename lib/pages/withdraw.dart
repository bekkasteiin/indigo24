import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;

class WithdrawPage extends StatefulWidget {
  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {

  final amountController = TextEditingController();

  Api api = Api();

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
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
          "${localization.withdraw}",
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
          Center(child: Text('${localization.commission} 2.8%')),
          Center(child: Text('${localization.minAmount} 1000 KZT')),
          Center(child: Text('${localization.minCommission} 350 KZT')),
          Center(child: Text('${localization.maxAmount} 1000000 KZT')),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration.collapsed(
                hintText: '${localization.amount}',
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
                  '${localization.withdraw}',
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
