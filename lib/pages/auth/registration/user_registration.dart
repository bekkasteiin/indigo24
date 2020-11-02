import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/chat/ui/new_chat/chat_pages/chat_page_view_test.dart';
import 'package:indigo24/pages/auth/login/login.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/services/localization.dart' as localization;

class UserRegistrationPage extends StatefulWidget {
  final phone;
  UserRegistrationPage(this.phone);
  @override
  _UserRegistrationPageState createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  Api _api = Api();
  TextEditingController _nameController;
  TextEditingController _lastNameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _passwordController2;

  bool _obscureText = true;
  bool _obscureText2 = true;
  bool _confirm = false;
  var password;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _lastNameController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordController2 = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordController2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
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
      ),
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
                                      color: primaryColor, fontSize: 16)),
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
                            controller: _nameController,
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
                                      color: primaryColor, fontSize: 16)),
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
                            controller: _lastNameController,
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
                                      color: primaryColor, fontSize: 16)),
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
                            controller: _emailController,
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
                                      color: primaryColor, fontSize: 16)),
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
                            controller: _passwordController,
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
                                      color: primaryColor, fontSize: 16)),
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
                            controller: _passwordController2,
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
                        style: TextStyle(color: primaryColor),
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
                              "Я принимаю соглашение",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Checkbox(
                            onChanged: (value) {
                              setState(() {
                                _confirm = value;
                              });
                            },
                            value: _confirm,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      // decoration: BoxDecoration(
                      //   color: primaryColor,
                      //   borderRadius: BorderRadius.only(
                      //     topRight: Radius.circular(10.0),
                      //     topLeft: Radius.circular(10.0),
                      //     bottomRight: Radius.circular(10.0),
                      //     bottomLeft: Radius.circular(10.0),
                      //   ),
                      // ),
                      child: ProgressButton(
                        defaultWidget: Text(
                          "${localization.next}",
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        progressWidget: CircularProgressIndicator(),
                        borderRadius: 10.0,
                        color: primaryColor,
                        onPressed: !_confirm
                            ? null
                            : () async {
                                if (_passwordController.text.isNotEmpty &&
                                    _passwordController2.text.isNotEmpty &&
                                    _nameController.text.isNotEmpty &&
                                    _lastNameController.text.isNotEmpty &&
                                    _emailController.text.isNotEmpty) {
                                  setState(() {
                                    globalError = '';
                                  });
                                  if (_passwordController.text ==
                                      _passwordController2.text) {
                                    password = _passwordController.text;
                                    setState(() {
                                      secondPasswordError = '';
                                      emailError = '';
                                      nameError = '';
                                      lastnameError = '';
                                      firstPasswordError = '';
                                      emailError = '';
                                    });
                                    await _api
                                        .register(
                                            "${widget.phone}",
                                            "${_nameController.text + ' ' + _lastNameController.text}",
                                            "$password",
                                            "${_emailController.text}")
                                        .then((registerResponse) {
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
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CustomDialog(
                                              description:
                                                  "${registerResponse['message']}",
                                              yesCallBack: () {
                                                Navigator.of(context).pop();
                                              },
                                            );
                                          },
                                        );
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
                                    setState(() {
                                      firstPasswordError =
                                          '${localization.passwordNotMatch}';
                                      secondPasswordError =
                                          '${localization.passwordNotMatch}';
                                    });
                                  }
                                } else {
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
