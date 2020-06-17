// home: TimerPage()


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'dart:convert';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'login.dart';
import 'phone_confirm.dart';

class RestorePasswordPage extends StatefulWidget {
  @override
  _RestorePasswordPageState createState() => _RestorePasswordPageState();
}

class _RestorePasswordPageState extends State<RestorePasswordPage> {
  var api = Api();
  TextEditingController loginController;
  TextEditingController passwordController;
  var countryId = 0;
  var country;
  var countries = new List<Country>();
  var _countries;
  var phonePrefix = '77';
  var smsCode = 0;
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

  Future<void> _showError(BuildContext context, m, type) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: type == 0 ? Text('Ошибка') : Text('Успешно'),
          content: Text(m),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Ok'),
              onPressed: () {
              Navigator.of(context).pop();
               if(type == 1) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()),(r) => false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            backgroundColor: Colors.white, 
            brightness: Brightness.light,
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
  var _selectedCountry;
  
  Future<void> changeCountry() async {
    _selectedCountry = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Countries(_countries)),
    );

    if (_selectedCountry != null)
      setState(() {
        _currentCountry = _selectedCountry['title'];
        phonePrefix = _selectedCountry['prefix'];
      });
  }
    Widget _buildForeground() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
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
                    _space(30),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Row(
                        children: <Widget>[
                          InkWell(
                            child: Ink(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text('$_currentCountry ',style: TextStyle(color: Color(0xFF001D52), fontSize: 18)),
                                  SizedBox(width: 10,),
                                  Container(
                                    child: Image(
                                      width: 15,
                                      height: 15,
                                      image: AssetImage(
                                        'assets/images/dropDown.png',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: changeCountry,
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
                                      color: Color(0xFF001D52), fontSize: 16))
                            ],
                          ),
                          Stack(
                            alignment: Alignment.centerLeft,
                            children: <Widget>[
                              Text(
                                '+$phonePrefix',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                              ),
                              TextField(
                                controller: loginController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: Colors.black, fontSize: 15
                                ),
                                decoration: InputDecoration(
                                  focusColor: Colors.black,
                                  fillColor: Colors.black,
                                  hoverColor: Colors.black,
                                  prefixText: '1$phonePrefix ',
                                  prefixStyle:
                                      TextStyle(color: Colors.transparent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _space(30),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ProgressButton(
                        defaultWidget: Text("${localization.next}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w300)),
                        progressWidget: CircularProgressIndicator(),
                        borderRadius: 10.0,
                        color: Color(0xFF0543B8),
                        onPressed: () async {
                        await api.restorePassword(phonePrefix + loginController.text).then((restorePasswordResponse) async {
                          // print('phone check result $checkPhoneResult');
                          print('empty check Registration $restorePasswordResponse');
                           if(restorePasswordResponse['success'] == true){
                             _showError(context, restorePasswordResponse['message'], 1);
                          } else{
                            _showError(context, restorePasswordResponse['message'], 0);
                          }
                        });
                      },
                      ),
                    ),
                    _space(50),
                  ],
                ),
              ),
            )
          ],
        ),
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
