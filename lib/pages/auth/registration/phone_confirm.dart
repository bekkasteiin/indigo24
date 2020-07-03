import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'user_registration.dart';
import 'package:indigo24/services/localization.dart' as localization;

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
  String smsError = "";
  @override
  void initState() {
    super.initState();
    smsController = new TextEditingController();
    passwordController = new TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<void> showError(BuildContext context, m) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('${localization.error}'),
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
                    image: introBackgroundProvider,
                    fit: BoxFit.cover),
              )),
              Center(child: _buildForeground())
            ],
          ),
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
                SizedBox(height: 50),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("${localization.keyFromSms}",
                              style: TextStyle(
                                  color: Color(0xFF001D52), fontSize: 16))
                        ],
                      ),
                      TextField(
                        controller: smsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: ""),
                      ),
                      Text('$smsError', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 10), overflow: TextOverflow.ellipsis,),
                    ],
                  ),
                ),
                _space(15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    '${localization.weSentToEmail}',
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
                  child: ProgressButton(
                    defaultWidget: Text("${localization.next}",
                        style: TextStyle(color: Colors.white, fontSize: 22)),
                    progressWidget: CircularProgressIndicator(),
                    borderRadius: 10.0,
                    color: Color(0xff0543B8),
                    onPressed: () async {
                      //@TODO REMOVE CONDITION
                      if(smsController.text.isNotEmpty){
                        await api.checkSms(widget.phone, smsController.text).then((checkSmsResponse) async {
                          print('this is checkSmsResponse $checkSmsResponse');
                          if(checkSmsResponse['success'] == true){
                            setState(() {
                              smsError = "";
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserRegistrationPage(widget.phone),
                              ),
                            );
                          } else{
                            setState(() {
                              smsError = checkSmsResponse['message'];
                            });
                          }
                          // if (r != true) {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) =>
                          //           UserRegistrationPage(widget.phone),
                          //     ),
                          //   );
                          // } else {
                          //   _showError(context, '$r');
                          // }
                        });
                      }
                      else{
                        setState(() {
                            smsError = '${localization.enterSmsCode}';
                          });
                      }
                    },
                  ),
                ),
                SizedBox(height: 50),
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
