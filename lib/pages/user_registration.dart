import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/pages/login.dart';
import 'package:indigo24/services/api.dart';

class UserRegistrationPage extends StatefulWidget {
  final phone;
  UserRegistrationPage(this.phone);
  @override
  _UserRegistrationPageState createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  var api = Api();
  TextEditingController nameController;
  TextEditingController lastNameController;
  TextEditingController emailController;
  TextEditingController passwordController;
  TextEditingController passwordController2;

  bool _obscureText = true;
  bool _obscureText2 = true;
  var password;
  @override
  void initState() {
    super.initState();
    nameController = new TextEditingController();
    emailController = new TextEditingController();
    lastNameController = new TextEditingController();
    passwordController = new TextEditingController();
    passwordController2 = new TextEditingController();
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
          content: Text('$m'),
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
                          Text("Имя",
                              style: TextStyle(
                                  color: Color(0xff0543B8), fontSize: 16))
                        ],
                      ),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(hintText: ""),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("Фамилия",
                              style: TextStyle(
                                  color: Color(0xff0543B8), fontSize: 16))
                        ],
                      ),
                      TextField(
                        controller: lastNameController,
                        decoration: InputDecoration(hintText: ""),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("Email",
                              style: TextStyle(
                                  color: Color(0xff0543B8), fontSize: 16))
                        ],
                      ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(hintText: ""),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: <Widget>[
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
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("Пароль",
                              style: TextStyle(
                                  color: Color(0xff0543B8), fontSize: 16))
                        ],
                      ),
                      TextField(
                        controller: passwordController2,
                        obscureText: _obscureText2,
                        decoration: InputDecoration(
                          hintText: '•••••••',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureText2 = !_obscureText2;
                              });
                            },
                            child: Icon(
                              _obscureText2
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              semanticLabel: _obscureText2
                                  ? 'show password'
                                  : 'hide password',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _space(15),
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
                      if (passwordController.text == passwordController2.text) {
                        password = passwordController.text;
                        await api.register("${widget.phone}", "${nameController.text + ' ' + lastNameController.text}", "$password", "$emailController.text").then((r) {
                          if(true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          }
                        });
                      } else {
                        _showError(context, 'Пароль не совпадает');
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
