import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/main.dart';
import 'dart:convert';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'phone_confirm.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  var api = Api();
  TextEditingController loginController;
  TextEditingController passwordController;
  var countryId = 0;
  var country;
  var countries = new List<Country>();
  var _countries;
  var phonePrefix = '77';
  var smsCode = 4040;
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
    return Container(
      child: ListView(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _space(200),
                Container(
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
                                Text("${localization.phoneNumber}",
                                    style: TextStyle(
                                        color: Color(0xff0543B8), fontSize: 16))
                              ],
                            ),
                            TextField(
                              controller: loginController,
                              decoration: InputDecoration(
                                  prefixText: "+" + phonePrefix,
                                  hintText: "XX XXX XX XX"),
                            ),
                          ],
                        ),
                      ),
                      _space(70),
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
                            await api.checkPhone(phonePrefix + loginController.text).then((r) async {
                              if (true) {
                                await api.sendSms(phonePrefix + loginController.text).then((r) {
                                  if (true) {
                                    //@TODO
                                    print('REGISTRATION TODO');
                                    print('REGISTRATION TODO');
                                    print('REGISTRATION TODO');
                                    print('REGISTRATION TODO');
                                    print('REGISTRATION TODO');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PhoneConfirmPage(
                                          smsCode,
                                          phonePrefix + loginController.text,
                                        ),
                                      ),
                                    );
                                  } else {
                                    _showError(context, r['message']);
                                  }
                                });
                              }
                            });
                          },
                        ),
                      ),
                      _space(10),
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
