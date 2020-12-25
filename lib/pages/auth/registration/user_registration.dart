import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/pages/auth/login/login.dart';
import 'package:indigo24/services/api/http/api.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/document/pdf_viewer.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/services/localization/localization.dart';
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
          backgroundColor: whiteColor,
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
                    color: whiteColor,
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
                                color: redColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            IndigoAuthTitle(title: Localization.language.name),
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
                                  color: redColor,
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
                            IndigoAuthTitle(
                                title: Localization.language.surname),
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
                                color: redColor,
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
                            IndigoAuthTitle(title: Localization.language.email),
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
                                color: redColor,
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
                            IndigoAuthTitle(
                                title: Localization.language.password),
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
                                      color: redColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                            Text(
                              '$firstPasswordError',
                              style: TextStyle(
                                color: redColor,
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
                            IndigoAuthTitle(
                                title: Localization.language.password),
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
                                color: redColor,
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
                          "${Localization.language.terms}",
                          style: TextStyle(color: primaryColor),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewer(
                                'assets/terms.pdf',
                                text: Localization.language.terms,
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
                            color: transparentColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    child: Text(
                                      "${Localization.language.iAgree}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: primaryColor,
                                      ),
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
                            showIndigoDialog(
                              context: context,
                              builder: CustomDialog(
                                description:
                                    "${Localization.language.confidentionalAgreement}",
                                yesCallBack: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                          child: Container(
                            color: transparentColor,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.help,
                                  color: primaryColor,
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  child: FittedBox(
                                    child: Text(
                                      "${Localization.language.infoAboutConfidentional}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ProgressButton(
                          defaultWidget: Text(
                            "${Localization.language.next}",
                            style: TextStyle(
                              color: whiteColor,
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
                                            showIndigoDialog(
                                              context: context,
                                              builder: CustomDialog(
                                                description:
                                                    "${registerResponse['message']}",
                                                yesCallBack: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
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
                                            '${Localization.language.passwordNotMatch}';
                                        secondPasswordError =
                                            '${Localization.language.passwordNotMatch}';
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      globalError =
                                          '${Localization.language.fillAllFields}';
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

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_progress_button/flutter_progress_button.dart';
// import 'package:indigo24/pages/auth/login/login.dart';
// import 'package:indigo24/services/api/http/api.dart';
// import 'package:indigo24/widgets/document/pdf_viewer.dart';
// import 'package:indigo24/style/colors.dart';
// import 'package:indigo24/widgets/alerts/indigo_alert.dart';
// import 'package:indigo24/widgets/backgrounds.dart';
// import 'package:indigo24/services/Localization.language.dart'  ;
// import 'package:indigo24/widgets/indigo_ui_kit/indigo_auth_title.dart';

// class UserRegistrationPage extends StatefulWidget {
//   final phone;
//   UserRegistrationPage(this.phone);
//   @override
//   _UserRegistrationPageState createState() => _UserRegistrationPageState();
// }

// class _UserRegistrationPageState extends State<UserRegistrationPage> {
//   Api _api = Api();

//   List<Map<String, dynamic>> _controllers = [];
//   bool _confirm = false;
//   var password;

//   List<Map<String, dynamic>> passwordValidation = [
//     {
//       'title': 'Пароль должен содержать не менее 8 символов.',
//       'regExp': r'^.{8,}$',
//       'valid': false,
//       'value': true,
//     },
//     {
//       'title': 'Пароль должен содержать не более 20 символов.',
//       'regExp': r'^.{1,20}$',
//       'valid': false,
//       'value': true,
//     },
//     {
//       'title': 'Пароль должен содержать минимум 1 заглавную букву.',
//       'regExp': r'[A-Z]{1}',
//       'valid': false,
//       'value': true,
//     },
//     {
//       'title': 'Пароль должен содержать минимум 1 цифру.',
//       'regExp': r'[0-9]{1}',
//       'valid': false,
//       'value': true,
//     },
//     {
//       'title': 'Пароль должен содержать минимум 1 специальный символ.',
//       'regExp': r'[!@#$%^&*(),.?":{}~|<>;=_~+-]',
//       'valid': false,
//       'value': true,
//     },
//     {
//       'title': 'Пароль НЕ должен содержать пробел.',
//       'regExp': r'\s',
//       'valid': false,
//       'value': false,
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     Iterable controllers = [
//       {
//         'controller': TextEditingController(),
//         'title': Localization.language.name,
//         'validate': false,
//         'errors': [],
//         'obscureText': false,
//         'hided': false,
//       },
//       {
//         'controller': TextEditingController(),
//         'title': Localization.language.surname,
//         'validate': false,
//         'errors': [],
//         'obscureText': false,
//         'hided': false,
//       },
//       {
//         'controller': TextEditingController(),
//         'title': Localization.language.email,
//         'validate': false,
//         'errors': [],
//         'obscureText': false,
//         'hided': false,
//       },
//       {
//         'controller': TextEditingController(),
//         'title': Localization.language.password,
//         'validate': true,
//         'errors': [],
//         'obscureText': true,
//         'hided': true,
//       },
//       {
//         'controller': TextEditingController(),
//         'title': Localization.language.password,
//         'validate': false,
//         'errors': [],
//         'obscureText': true,
//         'hided': true,
//       },
//     ];
//     _controllers.addAll(controllers);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controllers.forEach((element) {
//       element['controller'].dispose();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(0.0),
//         child: AppBar(
//           centerTitle: true,
//           backgroundColor: whiteColor,
//           brightness: Brightness.light,
//         ),
//       ),
//       body: GestureDetector(
//         onTap: () {
//           FocusScopeNode currentFocus = FocusScope.of(context);
//           if (!currentFocus.hasPrimaryFocus) {
//             currentFocus.unfocus();
//           }
//         },
//         child: Stack(
//           children: <Widget>[
//             Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                     image: introBackgroundProvider, fit: BoxFit.cover),
//               ),
//             ),
//             _buildForeground()
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildForeground() {
//     return Center(
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 15),
//               child: Center(
//                 child: Container(
//                   width: MediaQuery.of(context).size.width * 0.9,
//                   decoration: BoxDecoration(
//                     color: whiteColor,
//                     borderRadius: BorderRadius.only(
//                       topRight: Radius.circular(5.0),
//                       topLeft: Radius.circular(5.0),
//                       bottomRight: Radius.circular(5.0),
//                       bottomLeft: Radius.circular(5.0),
//                     ),
//                   ),
//                   child: Column(
//                     children: <Widget>[
//                       for (int i = 0; i < _controllers.length; i++)
//                         Column(
//                           children: [
//                             _space(15),
//                             Padding(
//                               padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   IndigoAuthTitle(
//                                     title: _controllers[i]['title'],
//                                   ),
//                                   TextField(
//                                     controller: _controllers[i]['controller'],
//                                     style: TextStyle(
//                                       color: blackPurpleColor,
//                                       fontSize: 16,
//                                     ),
//                                     onChanged: (value) {
//                                       _controllers[i]['errors'] = [];

//                                       if (_controllers[i]['validate'])
//                                         for (var validation
//                                             in passwordValidation) {
//                                           TextEditingController _controller =
//                                               _controllers[i]['controller'];
//                                           RegExp reg =
//                                               RegExp(validation['regExp']);
//                                           if (validation['value']) {
//                                             if (reg
//                                                 .hasMatch(_controller.text)) {
//                                               setState(() {
//                                                 validation['valid'] = true;
//                                               });
//                                             } else {
//                                               _controllers[i]['errors']
//                                                   .add(validation['title']);
//                                               setState(() {
//                                                 validation['valid'] = false;
//                                               });
//                                             }
//                                           } else {
//                                             print(value);

//                                             if (!reg
//                                                 .hasMatch(_controller.text)) {
//                                               setState(() {
//                                                 validation['valid'] = true;
//                                               });
//                                             } else {
//                                               setState(() {
//                                                 validation['valid'] = false;
//                                               });
//                                             }
//                                           }
//                                         }
//                                     },
//                                     obscureText: _controllers[i]['hided'],
//                                     decoration: _controllers[i]['obscureText']
//                                         ? InputDecoration(
//                                             hintText: '********',
//                                             hintStyle:
//                                                 TextStyle(color: greyColor),
//                                             suffixIcon: GestureDetector(
//                                               onTap: () {
//                                                 setState(() {
//                                                   _controllers[i]['hided'] =
//                                                       !_controllers[i]['hided'];
//                                                 });
//                                               },
//                                               child: Icon(
//                                                 _controllers[i]['hided']
//                                                     ? Icons.visibility_off
//                                                     : Icons.visibility,
//                                               ),
//                                             ),
//                                           )
//                                         : InputDecoration(
//                                             hintText: _controllers[i]['title'],
//                                             hintStyle:
//                                                 TextStyle(color: greyColor),
//                                           ),
//                                   ),
//                                   for (int j = 0;
//                                       j < _controllers[i]['errors'].length;
//                                       j++)
//                                     Text(_controllers[i]['errors'][j]),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       _space(15),
//                       FlatButton(
//                         child: Text(
//                           "${Localization.language.terms}",
//                           style: TextStyle(color: primaryColor),
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PDFViewer(
//                                 'assets/terms.pdf',
//                                 text: Localization.language.terms,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _confirm = !_confirm;
//                             });
//                           },
//                           child: Container(
//                             color: transparentColor,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Flexible(
//                                   child: FittedBox(
//                                     child: Text(
//                                       "${Localization.language.iAgree}",
//                                       overflow: TextOverflow.ellipsis,
//                                       maxLines: 1,
//                                       style: TextStyle(
//                                         color: primaryColor,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Checkbox(
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _confirm = !_confirm;
//                                     });
//                                   },
//                                   value: _confirm,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: GestureDetector(
//                           onTap: () {
//                             showIndigoDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return CustomDialog(
//                                   description:
//                                       "${Localization.language.confidentionalAgreement}",
//                                   yesCallBack: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 );
//                               },
//                             );
//                           },
//                           child: Container(
//                             color: transparentColor,
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.help,
//                                   color: primaryColor,
//                                 ),
//                                 SizedBox(width: 5),
//                                 Flexible(
//                                   child: FittedBox(
//                                     child: Text(
//                                       "${Localization.language.infoAboutConfidentional}",
//                                       overflow: TextOverflow.ellipsis,
//                                       maxLines: 1,
//                                       style: TextStyle(
//                                         color: primaryColor,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 25),
//                       Container(
//                         width: MediaQuery.of(context).size.width * 0.5,
//                         child: ProgressButton(
//                           defaultWidget: Text(
//                             "${Localization.language.next}",
//                             style: TextStyle(
//                               color: whiteColor,
//                               fontSize: 22,
//                               fontWeight: FontWeight.w300,
//                             ),
//                           ),
//                           progressWidget: CircularProgressIndicator(),
//                           borderRadius: 10.0,
//                           color: primaryColor,
//                           onPressed: !_confirm
//                               ? null
//                               : () async {
//                                   // _controllers.forEach((element) { return element['controller'].text.isNotEmpty;})
//                                   if (true) {

//                                     await _api
//                                         .register("${widget.phone}",
//                                             "name last ", "$password", "email")
//                                         .then((registerResponse) {
//                                       if (registerResponse['success'] == true) {
//                                         Navigator.of(context)
//                                             .pushAndRemoveUntil(
//                                           MaterialPageRoute(
//                                             builder: (context) => LoginPage(),
//                                           ),
//                                           (r) => false,
//                                         );

//                                       } else if (registerResponse['message'] !=
//                                           null) {
//                                         showIndigoDialog(
//                                           context: context,
//                                           builder: (BuildContext context) {
//                                             return CustomDialog(
//                                               description:
//                                                   "${registerResponse['message']}",
//                                               yesCallBack: () {
//                                                 Navigator.of(context).pop();
//                                               },
//                                             );
//                                           },
//                                         );
//                                       } else {
//                                         setState(() {
//                                           registerResponse.keys;
//                                           _controllers.where((element) => element['title'] == '')
//                                           firstPasswordError =
//                                               '${registerResponse['message']['password'] == null ? '' : registerResponse['message']['password']}';
//                                           secondPasswordError =
//                                               '${registerResponse['message']['password'] == null ? '' : registerResponse['message']['password']}';
//                                           emailError =
//                                               '${registerResponse['message']['email'] == null ? '' : registerResponse['message']['email']}';
//                                         });
//                                       }
//                                     });
//                                   }
//                                 },
//                         ),
//                       ),
//                       SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   _space(double h) {
//     return Container(
//       height: h,
//     );
//   }
// }
