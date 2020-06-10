import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var api = Api();
  TextEditingController loginController;
  TextEditingController passwordController;
  bool _obscureText = true;
  var client = new http.Client();

  var countryId = 0;
  var country;
  var countries = new List<Country>();
  var _countries;
  var phonePrefix = '77';
  List _titles = [];
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentCountry = "Казахстан";

  _getCountries() async {
    await api.getCountries().then((response) {
      setState(() {
        Iterable list = response['countries'];
        List<dynamic> responseJson = response['countries'].toList();
        countries = list.map((model) => Country.fromJson(model)).toList();
        _countries = jsonDecode(jsonEncode(responseJson));
        for (var i = 0; i < _countries.length; i++) {
          _titles.add(_countries[i]['title']);
        }
        country = _countries[countryId];
        _dropDownMenuItems = getDropDownMenuItems(_titles);
        _currentCountry = _titles[0];
      });
    });
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List titles) {
    List<DropdownMenuItem<String>> items = new List();
    for (var i = 0; i < titles.length; i++) {
      items.add(
          new DropdownMenuItem(value: titles[i], child: new Text(titles[i])));
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    loginController = new TextEditingController();
    passwordController = new TextEditingController();
    _getCountries();
  }

  signIn() async {
    try {
      var response = await client.post(
        'https://api.indigo24.xyz/api/v2.1/check/authentication',
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body:
            "phone=$phonePrefix${loginController.text}&password=${passwordController.text}",
      );
      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        print(result);
        if (result['success'] == true) {
          SharedPreferencesHelper.setString('customerID', '${result['ID']}');
          SharedPreferencesHelper.setString(
              'phone', '+$phonePrefix${loginController.text}');
          SharedPreferencesHelper.setString('name', '${result['name']}');
          SharedPreferencesHelper.setString('email', '${result['email']}');
          SharedPreferencesHelper.setString('avatar', '${result['avatar']}');
          SharedPreferencesHelper.setString('unique', '${result['unique']}');
          return true;
        } else {
          _showError(context, result["message"]);
        }
      } else {
        return false;
      }
    } catch (_) {
      print(_);
      return "disconnect";
    }
  }

  getBalance() async {
    String customerID = await SharedPreferencesHelper.getCustomerID();
    String unique = await SharedPreferencesHelper.getUnique();
    try {
      var response = await client.post(
        'https://api.indigo24.xyz/api/v2.1/get/balance',
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: "customerID=${customerID}&unique=${unique}",
      );
      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['success'] == true) {
          SharedPreferencesHelper.setString(
              'balance', '${result['result']['balance']}');
          SharedPreferencesHelper.setString(
              'balanceInBlock', '${result['result']['balanceInBlock']}');
          return true;
        }
      } else {
        return false;
      }
    } catch (_) {
      return "disconnect";
    }
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
    return Container(
      child: ListView(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _space(
                  MediaQuery.of(context).size.height * 0.2,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
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
                      _space(10),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(
                          children: <Widget>[
                            DropdownButton(
                              value: _currentCountry,
                              items: _dropDownMenuItems,
                              onChanged: changedDropDownItem,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text("Номер телефона",
                                    style: TextStyle(
                                        color: Color(0xff0543B8), fontSize: 16))
                              ],
                            ),
                            TextField(
                              keyboardType: TextInputType.number,
                              controller: loginController,
                              decoration: InputDecoration(
                                  prefixText: "+" + phonePrefix,
                                  hintText: "xx xxx xx xx"),
                            ),
                            Row(
                              children: <Widget>[
                                Text("Пароль",
                                    style: TextStyle(
                                        color: Color(0xff0543B8), fontSize: 16))
                              ],
                            ),
                            TextField(
                              controller: passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                hintText: '•••••••',
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  child: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    semanticLabel: _obscureText
                                        ? 'show password'
                                        : 'hide password',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _space(70),
                      Text(
                        'ЗАБЫЛИ ПАРОЛЬ?',
                        style: TextStyle(color: Color(0xff898DA5)),
                      ),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22)),
                          progressWidget: CircularProgressIndicator(),
                          borderRadius: 10.0,
                          color: Color(0xff0543B8),
                          onPressed: () async {
                            if (await signIn() == true) {
                              await getBalance();
                              return () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => Tabs()),
                                    (r) => false);
                              };
                            }
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void changedDropDownItem(String selectedCountry) {
    print("Selected county $selectedCountry, we are going to refresh the UI");
    print("TEST $_countries");
    for (var i = 0; i < _countries.length; i++) {
      if (_countries[i]['title'] == selectedCountry) {
        countryId = i;
        phonePrefix = _countries[countryId]['prefix'];
      }
    }
    setState(() {
      _currentCountry = selectedCountry;
    });
    print("Current country is $_currentCountry and prefix $phonePrefix");
  }

  _space(double h) {
    return Container(
      height: h,
    );
  }

  _signInButton(Size size) {
    return ButtonTheme(
      minWidth: size.width * 0.45,
      height: 60,
      child: RaisedButton(
        onPressed: () {
          print('Login is pressed');
        },
        child: const Text(
          'Далее',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
        ),
        color: Color(0xFFFFFFFF),
        textColor: Color(0xFF001D52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
      ),
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
