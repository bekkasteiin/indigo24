import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';

import 'user_registration.dart';

class PhoneConfirmPage extends StatefulWidget {
  final smsCode;
  final phone;

  const PhoneConfirmPage(this.smsCode, this.phone);

  @override
  _PhoneConfirmPageState createState() => _PhoneConfirmPageState();
}

class _PhoneConfirmPageState extends State<PhoneConfirmPage> {
  var api = Api();
  TextEditingController smsController;
  TextEditingController passwordController;
  var client = new http.Client();

  @override
  void initState() {
    super.initState();
    smsController = new TextEditingController();
    passwordController = new TextEditingController();
  }

  checkSms(code) async {
    try {
      var response = await client.post(
        'https://api.indigo24.xyz/api/v2.1/check/sms',
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: "phone=${widget.phone}&code=$code",
      );
      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        print(result);
        if (result['success'] == true) {
          // smsCode
          return true;
        } else {
          _showError(context, result['message']);
          return false;
        }
      } else {
        return false;
      }
    } catch (_) {
      print(_);
      return "disconnect";
    }
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<void> _showError(BuildContext context, m) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(m),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            backgroundColor: Colors.white, // status bar color
            brightness: Brightness.light, // status bar brightness
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background_login.png"),
                  fit: BoxFit.cover),
            )),
            _buildForeground()
          ],
        ));
  }

  Widget _buildForeground() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            // height: MediaQuery.of(context).size.height*0.4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5.0),
                topLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("Код из SMS",
                              style: TextStyle(
                                  color: Color(0xff0543B8), fontSize: 16))
                        ],
                      ),
                      TextField(
                        controller: smsController,
                        decoration: InputDecoration(hintText: ""),
                      ),
                    ],
                  ),
                ),
                _space(15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Мы отправили на Ваш номер SMS ключ, который поступит в течение 10 секунд',
                    style: TextStyle(
                      color: Color(0xff898DA5),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  // decoration: BoxDecoration(
                  //   color: Color(0xff0543B8),
                  //   borderRadius: BorderRadius.only(
                  //     topRight: Radius.circular(10.0),
                  //     topLeft: Radius.circular(10.0),
                  //     bottomRight: Radius.circular(10.0),
                  //     bottomLeft: Radius.circular(10.0),
                  //   ),
                  // ),
                  child: ProgressButton(
                    defaultWidget: Text("Далее",
                        style: TextStyle(color: Colors.white, fontSize: 22)),
                    progressWidget: CircularProgressIndicator(),
                    borderRadius: 10.0,
                    color: Color(0xff0543B8),
                    onPressed: () async {
                      //@TODO REMOVE CONDITION
                      if (!await checkSms(smsController.text)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UserRegistrationPage(widget.phone)),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        )
      ],
    );
  }

  _space(double h) {
    return Container(
      height: h,
    );
  }
}

class Country {
  int id;
  String title;
  String phonePrefix;
  String code;

  Country(int id, String name, String phonePrefix, String code) {
    this.id = id;
    this.title = name;
    this.phonePrefix = phonePrefix;
    this.code = code;
  }

  Country.fromJson(Map json)
      : id = json['id'],
        title = json['name'],
        phonePrefix = json['phonePrefix'],
        code = json['code'];

  Map toJson() {
    return {'id': id, 'title': title, 'phonePrefix': phonePrefix, 'code': code};
  }
}
