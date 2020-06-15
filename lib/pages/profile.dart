import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/intro.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:url_launcher/url_launcher.dart';
import 'package:indigo24/services/localization.dart' as localization;

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  final String _fullName = '${user.name}';

  File _image;

  final picker = ImagePicker();
  var api = Api();

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      if(_image != null){
        api.uploadAvatar(_image.path).then((r) async {
          if (r['message'] == 'Not authenticated' && r['success'].toString() == 'false') {
            logOut(context);
            return r;
          } else {
            if (r["success"]) {
              await SharedPreferencesHelper.setString(
                  'avatar', '${r["fileName"]}');
              setState(() {
                user.avatar = r["fileName"];
              });
            } else {
              print("error");
            }
            return r;
          }
        });
      }
    }
  }

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/cover.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return InkWell(
      onTap: () => PlatformActionSheet().displaySheet(
          context: context,
          message: Text("Выберите опцию"),
          actions: [
            ActionSheetAction(
              text: "Сфотографировать",
              onPressed: () {
                getImage(ImageSource.camera);
                Navigator.pop(context);
              },
              hasArrow: true,
            ),
            ActionSheetAction(
              text: "Выбрать из галереи",
              onPressed: () {
                getImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ActionSheetAction(
              text: "Назад",
              onPressed: () => Navigator.pop(context),
              isCancel: true,
              defaultAction: true,
            )
          ]),
      child: Center(
        child: Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://indigo24.xyz/uploads/avatars/${user.avatar}'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(80.0),
            border: Border.all(
              color: Color(0xFF001D52),
              width: 5.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
    );

    return Text(
      _fullName,
      style: _nameTextStyle,
    );
  }


  TextEditingController emailController =
      new TextEditingController(text: '${user.email}');

  Widget _buildEmailSection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("${localization.email}"),
          SizedBox(height: 5),
          Text('${user.email}'),
          // TextField(
          //   decoration: null,
          //   controller: emailController,
          // ),
          SizedBox(height: 5)
        ],
      ),
    );
  }

  Widget _buildPhoneSection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("${localization.phoneNumber}"),
          SizedBox(height: 5),
          Text('${user.phone}',
              textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      height: 0.5,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 130),
                  // _buildFullName(),
                  // _buildStatus(context),
                  // _buildStatContainer(),
                  // _buildBio(context),
                  // _buildSeparator(screenSize),
                  // SizedBox(height: 10.0),
                  // _buildGetInTouch(context),
                  // SizedBox(height: 8.0),
                  // _buildButtons(),

                  SizedBox(height: 10),
                  _buildPhoneSection(screenSize),
                  _buildSeparator(screenSize),
                  SizedBox(height: 10),
                  _buildEmailSection(screenSize),
                  _buildSeparator(screenSize),
                  // SizedBox(height: 10),
                  // _buildCountySection(screenSize),
                  // _buildSeparator(screenSize),
                  // SizedBox(height: 10),
                  // _buildCitySection(screenSize),
                  // _buildSeparator(screenSize),

                  // SizedBox(height: 10),
                  // _buildWhateverSection(screenSize),
                  // _buildSeparator(screenSize),
                  // SizedBox(height: 10),
                  // _buildWhateverSection(screenSize),
                  // _buildSeparator(screenSize),

                  SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: () async {
                              if (await canLaunch(
                                  'https://indigo24.userecho.com/')) {
                                await launch(
                                  'https://indigo24.userecho.com/',
                                  forceSafariVC: false,
                                  forceWebView: false,
                                  headers: <String, String>{
                                    'my_header_key': 'my_header_value'
                                  },
                                );
                              } else {
                                throw 'Could not launch https://indigo24.userecho.com/';
                              }
                            },
                            child: Ink(
                              child: Text("${localization.support}",
                                  style: TextStyle(color: Colors.grey)),
                            )),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        )),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: Text("${localization.currentLanguage}",
                            style: TextStyle(color: Color(0xFF001D52))),
                        // value: _valFriends,
                        items: localization.languages.map((value) {
                          return DropdownMenuItem(
                            child: Text('${value['title']}',
                                style: TextStyle(color: Color(0xFF001D52))),
                            value: value,
                          );
                        }).toList(),
                        onChanged: (value) {
                          // MyApp.tabPageKey.currentState.tabController.animateTo(0);
                          tabPageKey.currentState.setState(() {});
                          print('${value['title']}');
                          setState(() {
                          });
                          localization.setLanguage(value['code']);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildCoverImage(screenSize),
            Column(
              children: <Widget>[
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () async {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            preferences.setString('phone', 'null');
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => IntroPage()),
                                (r) => false);
                          },
                          child: Ink(
                            child: Text("${localization.exit}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          )),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 10),
                    _buildProfileImage(),
                    SizedBox(width: 10),
                    _buildFullName(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// {id: 1, avatar: 0b8f520924a21d5c2bab.jpg, name: Aibek Q, type: 0,
// members_count: 2, unread_messages: 0, phone: 77077655990, another_user_id: 45069,
// last_message: {id: message:45069:25, avatar: , user_name: , text: ггг, time: 1592028962}}
