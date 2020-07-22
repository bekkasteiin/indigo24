import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/pages/auth/login/login.dart';
import 'package:indigo24/pages/chat/chat_page_view_test.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/services/localization.dart' as localization;

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
  bool confirm = false;
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
        return CupertinoAlertDialog(
          title: Text('${localization.error}'),
          content: Text('$m'),
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

  bool isNameValid = true;
  bool isLastnameValid = true;
  bool isEmailValid = true;
  bool isFirstPasswordValid = true;
  bool isSecondPasswordValid = true;

  String globalError = "";
  String nameError = "";
  String lastnameError = "";
  String emailError = "";
  String firstPasswordError = "";
  String secondPasswordError = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white, // status bar color
            brightness: Brightness.light, // status bar brightness
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Stack(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                image: DecorationImage(
                    image: introBackgroundProvider, fit: BoxFit.cover),
              )),
              _buildForeground()
            ],
          ),
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
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '$globalError',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Имя",
                                  style: TextStyle(
                                      color: Color(0xff0543B8), fontSize: 16)),
                              SizedBox(
                                width: 20,
                              ),
                              isNameValid == true
                                  ? Center()
                                  : Container(
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      width: 15,
                                    ),
                            ],
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(hintText: ""),
                          ),
                          Text(
                            '$nameError',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("${localization.surname}",
                                  style: TextStyle(
                                      color: Color(0xff0543B8), fontSize: 16)),
                              SizedBox(
                                width: 20,
                              ),
                              isLastnameValid == true
                                  ? Center()
                                  : Container(
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      width: 15,
                                    ),
                            ],
                          ),
                          TextField(
                            controller: lastNameController,
                            decoration: InputDecoration(hintText: ""),
                          ),
                          Text(
                            '$lastnameError',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("Email",
                                  style: TextStyle(
                                      color: Color(0xff0543B8), fontSize: 16)),
                              SizedBox(
                                width: 20,
                              ),
                              isEmailValid == true
                                  ? Center()
                                  : Container(
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      width: 15,
                                    ),
                            ],
                          ),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(hintText: ""),
                          ),
                          Text(
                            '$emailError',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("${localization.password}",
                                  style: TextStyle(
                                      color: Color(0xff0543B8), fontSize: 16)),
                              SizedBox(
                                width: 20,
                              ),
                              isFirstPasswordValid == true
                                  ? Center()
                                  : Container(
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      width: 15,
                                    ),
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
                          Text(
                            '$firstPasswordError',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("${localization.password}",
                                  style: TextStyle(
                                      color: Color(0xff0543B8), fontSize: 16)),
                              SizedBox(
                                width: 20,
                              ),
                              isSecondPasswordValid == true
                                  ? Center()
                                  : Container(
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      width: 15,
                                    ),
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
                          Text(
                            '$secondPasswordError',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _space(15),
                    FlatButton(
                      child: Text(
                        "${localization.terms}",
                        style: TextStyle(color: Color(0xff0543B8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PDFViewer('assets/terms.pdf')));
                      },
                    ),
                    _space(15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "${localization.iAgree}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Checkbox(
                            onChanged: (value) {
                              setState(() {
                                confirm = value;
                              });
                            },
                            value: confirm,
                          )
                        ],
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
                        defaultWidget: Text("${localization.next}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 22)),
                        progressWidget: CircularProgressIndicator(),
                        borderRadius: 10.0,
                        color: Color(0xff0543B8),
                        onPressed: !confirm
                            ? null
                            : () async {
                                if (passwordController.text.isNotEmpty &&
                                    passwordController2.text.isNotEmpty &&
                                    nameController.text.isNotEmpty &&
                                    lastNameController.text.isNotEmpty &&
                                    emailController.text.isNotEmpty) {
                                  setState(() {
                                    globalError = '';
                                  });
                                  print('is not empty ');
                                  if (passwordController.text ==
                                      passwordController2.text) {
                                    password = passwordController.text;
                                    setState(() {
                                      secondPasswordError = '';
                                      emailError = '';
                                      nameError = '';
                                      lastnameError = '';
                                      firstPasswordError = '';
                                      emailError = '';
                                    });
                                    await api
                                        .register(
                                            "${widget.phone}",
                                            "${nameController.text + ' ' + lastNameController.text}",
                                            "$password",
                                            "${emailController.text}")
                                        .then((registerResponse) {
                                      print(
                                          'this is register result $registerResponse');
                                      if (registerResponse['success'] == true) {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginPage()),
                                                (r) => false);
                                        setState(() {
                                          firstPasswordError = '';
                                          emailError = '';
                                        });
                                      } else if (registerResponse['message'] !=
                                          null) {
                                        _showError(context,
                                            registerResponse['message']);
                                      } else {
                                        setState(() {
                                          firstPasswordError =
                                              '${registerResponse['message']['password'] == null ? '' : registerResponse['message']['password']}';
                                          secondPasswordError =
                                              '${registerResponse['message']['password'] == null ? '' : registerResponse['message']['password']}';
                                          emailError =
                                              '${registerResponse['message']['email'] == null ? '' : registerResponse['message']['email']}';
                                        });
                                      }
                                    });
                                  } else {
                                    print('different passwords');
                                    setState(() {
                                      firstPasswordError =
                                          '${localization.passwordNotMatch}';
                                      secondPasswordError =
                                          '${localization.passwordNotMatch}';
                                    });
                                  }
                                } else {
                                  print('empty');
                                  setState(() {
                                    globalError =
                                        '${localization.fillAllFields}';
                                    // Заполните все нужные поля';
                                  });
                                }
                              },
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
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
