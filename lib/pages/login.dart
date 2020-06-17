import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/restore_password.dart';
import 'dart:convert';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';
import 'package:indigo24/services/push.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var api = Api();
  TextEditingController loginController;
  TextEditingController passwordController;
  bool _obscureText = true;
  var singInResult;
  var countryId = 0;
  var country;
  var countries = new List<Country>();
  var _countries;
  var phonePrefix = '77';
  List _titles = [];
  String _currentCountry = "Казахстан";
  String loginError = "";
  _getCountries() async {
    await api.getCountries().then((response) {
      setState(() {
        print("MY RESPONSE $response");
        Iterable list = response['countries'];
        List<dynamic> responseJson = response['countries'].toList();
        countries = list.map((model) => Country.fromJson(model)).toList();
        _countries = jsonDecode(jsonEncode(responseJson));
        for (var i = 0; i < _countries.length; i++) {
          _titles.add(_countries[i]['title']);
        }
        country = _countries[countryId];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
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


  

  Future<void> _showError(BuildContext context, m) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Ошибка'),
          content: Text(m),
          actions: <Widget>[
            CupertinoDialogAction(
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
                    _space(10),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Row(
                        children: <Widget>[
                          InkWell(
                            child: Ink(
                              child: Row(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          _space(30),
                          Row(
                            children: <Widget>[
                              Text("${localization.password}",
                                  style: TextStyle(
                                      color: Color(0xFF001D52), fontSize: 16))
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
                                  child: Container(
                                          padding: EdgeInsets.symmetric( horizontal: 10),
                                          child: Image(
                                            image: AssetImage(
                                              _obscureText ? 'assets/images/eyeClose.png' : 'assets/images/eyeOpen.png',
                                            ),
                                            height: 20,
                                            width: 20,
                                          ),
                                        ),
                                        ),
                            ),
                          ),
                          _space(10),
                          Text('$loginError', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 12), overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                    ),
                    _space(15),
                    FlatButton(
                      child: Text(
                        '${localization.forgotPassword}',
                        style: TextStyle(color: Color(0xFF444444)),
                      ),
                      onPressed: (){
                        Navigator.push(context,MaterialPageRoute(builder: (context) => RestorePasswordPage()));
                      },
                    ),
                    _space(20),
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
                          FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
                          String token = await _firebaseMessaging.getToken();
                            await api.signIn("$phonePrefix${loginController.text}", passwordController.text, token).then((response) async {
                              singInResult = response;
                              print('Response of sing in $response');
                              if('${response['success']}' == 'true'){
                                print('Second response $response');
                                  await api.getBalance();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => Tabs(key: tabPageKey,)),(r) => false,
                                  );
                              }
                              else{
                                print("this is else $singInResult");
                                setState(() {
                                  loginError = singInResult["message"];
                                });
                             }
                             print('this is below if');


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

  _space(double h) {
    return Container(
      height: h,
    );
  }

}

class Countries extends StatelessWidget {
  final countries;
  Countries(this.countries);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        centerTitle: true,
        brightness: Brightness.light,
        title: Text(
          "Страна",
          style: TextStyle(
            color: Color(0xFF001D52),
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ListView.separated(
            itemCount: countries.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                child: Container(
                  height: 20,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    '${countries[index]['title']}',
                    style: TextStyle(
                      color: Color(0xFF001D52),
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                  ),
                ),
                onTap: () {
                  print('${countries[index]['title']}');
                  Navigator.of(context).pop(countries[index]);
                },
              );
            },
            separatorBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(left: 20),
                height: 0.2,
                color: Colors.black,
              );
            },
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
