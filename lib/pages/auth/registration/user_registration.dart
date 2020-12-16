import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/pages/auth/login/login.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/widgets/document/pdf_viewer.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/widgets/indigo_ui_kit/indigo_auth_title.dart';

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

  List<Map<String, dynamic>> passwordValidation = [
    {
      'title': 'Пароль должен содержать не менее 8 символов.',
      'regExp': r'^.{8,}$',
      'valid': false,
      'value': true,
    },
    {
      'title': 'Пароль должен содержать не более 20 символов.',
      'regExp': r'^.{1,20}$',
      'valid': false,
      'value': true,
    },
    {
      'title': 'Пароль должен содержать минимум 1 заглавную букву.',
      'regExp': r'[A-Z]{1}',
      'valid': false,
      'value': true,
    },
    {
      'title': 'Пароль должен содержать минимум 1 цифру.',
      'regExp': r'[0-9]{1}',
      'valid': false,
      'value': true,
    },
    {
      'title': 'Пароль должен содержать минимум 1 специальный символ.',
      'regExp': r'[!@#$%^&*(),.?":{}~|<>;=_~+-]',
      'valid': false,
      'value': true,
    },
    {
      'title': 'Пароль НЕ должен содержать пробел.',
      'regExp': r'\s',
      'valid': false,
      'value': false,
    },
  ];
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Center(
                child: Container(
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
                      _space(15),
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
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            IndigoAuthTitle(title: localization.name),
                            TextField(
                              controller: _nameController,
                              style: TextStyle(
                                color: blackPurpleColor,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: "",
                                hintStyle: TextStyle(color: greyColor),
                              ),
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
                      _space(15),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            IndigoAuthTitle(title: localization.surname),
                            TextField(
                              controller: _lastNameController,
                              style: TextStyle(
                                color: blackPurpleColor,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: "",
                                hintStyle: TextStyle(color: greyColor),
                              ),
                            ),
                            Text(
                              '$lastnameError',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _space(15),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            IndigoAuthTitle(title: localization.email),
                            TextField(
                              style: TextStyle(
                                color: blackPurpleColor,
                                fontSize: 16,
                              ),
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: "",
                                hintStyle: TextStyle(color: greyColor),
                              ),
                            ),
                            Text(
                              '$emailError',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _space(15),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            IndigoAuthTitle(title: localization.password),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              style: TextStyle(
                                color: blackPurpleColor,
                                fontSize: 16,
                              ),
                              onChanged: (value) {
                                for (var validation in passwordValidation) {
                                  RegExp reg = RegExp(validation['regExp']);
                                  if (validation['value']) {
                                    if (reg
                                        .hasMatch(_passwordController.text)) {
                                      setState(() {
                                        validation['valid'] = true;
                                      });
                                    } else {
                                      setState(() {
                                        validation['valid'] = false;
                                      });
                                    }
                                  } else {
                                    if (!reg
                                        .hasMatch(_passwordController.text)) {
                                      setState(() {
                                        validation['valid'] = true;
                                      });
                                    } else {
                                      setState(() {
                                        validation['valid'] = false;
                                      });
                                    }
                                  }
                                }
                              },
                              decoration: InputDecoration(
                                hintText: '********',
                                hintStyle: TextStyle(color: greyColor),
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
                            if (_passwordController.text.isNotEmpty)
                              for (var validation in passwordValidation)
                                if (validation['valid'] == false)
                                  Text(
                                    validation['title'],
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                            Text(
                              '$firstPasswordError',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _space(15),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            IndigoAuthTitle(title: localization.password),
                            TextField(
                              controller: _passwordController2,
                              style: TextStyle(
                                color: blackPurpleColor,
                                fontSize: 16,
                              ),
                              obscureText: _obscureText2,
                              decoration: InputDecoration(
                                hintText: '********',
                                hintStyle: TextStyle(color: greyColor),
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
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '$secondPasswordError',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
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
                              builder: (context) => PDFViewer(
                                'assets/terms.pdf',
                                text: localization.terms,
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _confirm = !_confirm;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    "${localization.iAgree}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  onChanged: (value) {
                                    setState(() {
                                      _confirm = !_confirm;
                                    });
                                  },
                                  value: _confirm,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _confirm = !_confirm;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.help,
                                      color: primaryColor,
                                    ),
                                    Text(
                                      "${localization.iAgree}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w300,
                            ),
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

                                      bool ready = true;
                                      for (var validation
                                          in passwordValidation) {
                                        RegExp regExp =
                                            RegExp(validation['regExp']);
                                        if (validation['value']) {
                                          if (regExp.hasMatch(
                                              _passwordController.text)) {
                                            validation['valid'] = true;
                                          } else {
                                            ready = false;
                                          }
                                        } else {
                                          if (!regExp.hasMatch(
                                              _passwordController.text)) {
                                          } else {
                                            validation['valid'] = true;
                                          }
                                        }
                                      }

                                      if (ready) {
                                        await _api
                                            .register(
                                                "${widget.phone}",
                                                "${_nameController.text + ' ' + _lastNameController.text}",
                                                "$password",
                                                "${_emailController.text}")
                                            .then((registerResponse) {
                                          if (registerResponse['success'] ==
                                              true) {
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginPage(),
                                              ),
                                              (r) => false,
                                            );

                                            setState(() {
                                              firstPasswordError = '';
                                              emailError = '';
                                            });
                                          } else if (registerResponse[
                                                  'message'] !=
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
                                      } else {}
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
                                    });
                                  }
                                },
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
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
