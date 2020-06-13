import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/pages/chat_list.dart';
import 'package:indigo24/pages/intro.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:url_launcher/url_launcher.dart';

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
      api.uploadAvatar(_image.path).then((r) async {
        if (r["success"]) {
          await SharedPreferencesHelper.setString('avatar', '${r["fileName"]}');
          setState(() {
            user.avatar = r["fileName"];
          });
        }
      });
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

  Widget _buildStatItem(String label, String count) {
    TextStyle _statLabelTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w200,
    );

    TextStyle _statCountTextStyle = TextStyle(
      color: Colors.black54,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count,
          style: _statCountTextStyle,
        ),
        Text(
          label,
          style: _statLabelTextStyle,
        ),
      ],
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
          Text("Email"),
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
          Text("НОМЕР ТЕЛЕФОНА"),
          SizedBox(height: 5),
          Text('${user.phone}',
              textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildCountySection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("СТРАНА"),
          SizedBox(height: 5),
          Text("Казахстан",
              textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildCitySection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("ГОРОД"),
          SizedBox(height: 5),
          Text("Алматы",
              textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildWhateverSection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("WHATEVER", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 5),
          Text("Whatever",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18, color: Colors.grey)),
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

  Widget _buildGetInTouch(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        "Get in Touch with ${_fullName.split(" ")[0]},",
        style: TextStyle(fontFamily: 'Roboto', fontSize: 16.0),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () => print("followed"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: Color(0xFF404A5C),
                ),
                child: Center(
                  child: Text(
                    "FOLLOW",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: InkWell(
              onTap: () => print("Message"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "MESSAGE",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
                            onTap: () async{
                              if (await canLaunch('https://indigo24.userecho.com/')) {
                                await launch(
                                  'https://indigo24.userecho.com/',
                                  forceSafariVC: false,
                                  forceWebView: false,
                                  headers: <String, String>{'my_header_key': 'my_header_value'},
                                );
                              } else {
                                throw 'Could not launch https://indigo24.userecho.com/';
                              }
                            },
                            child: Ink(
                              child: Text("СЛУЖБА ПОДДЕРЖКИ",
                                  style: TextStyle(color: Colors.grey)),
                            )),
                      ),
                      SizedBox(width: 10),
                    ],
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
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => IntroPage()),
                                (r) => false);
                          },
                          child: Ink(
                            child: Text("Выйти",
                                style: TextStyle(color: Colors.white, fontSize: 18)),
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
