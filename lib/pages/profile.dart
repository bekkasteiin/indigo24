import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/intro.dart';
import 'package:indigo24/pages/settings/settings_main.dart';
import 'package:indigo24/pages/settings/settings_notifications_main.dart';
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
      height: 120,
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
              image: CachedNetworkImageProvider(
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
    print(screenSize);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                height: screenSize.height * 0.82,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(height: 160),
                        _buildPhoneSection(screenSize),
                        _buildSeparator(screenSize),
                        SizedBox(height: 10),
                        _buildEmailSection(screenSize),
                        _buildSeparator(screenSize),
                      ],
                    ),
                    

                    // SizedBox(height: screenSize.height*0.2),
                    // SizedBox(height: 20),
                    
                    // LANGUAGE
                    // Container(
                    //   padding: EdgeInsets.symmetric(horizontal: 10),
                    //   decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.all(
                    //         Radius.circular(16.0),
                    //       )),
                    //   child: DropdownButtonHideUnderline(
                    //     child: DropdownButton(
                    //       hint: Text("${localization.currentLanguage}",
                    //           style: TextStyle(color: Color(0xFF001D52))),
                    //       // value: _valFriends,
                    //       items: localization.languages.map((value) {
                    //         return DropdownMenuItem(
                    //           child: Text('${value['title']}',
                    //               style: TextStyle(color: Color(0xFF001D52))),
                    //           value: value,
                    //         );
                    //       }).toList(),
                    //       onChanged: (value) {
                    //         // MyApp.tabPageKey.currentState.tabController.animateTo(0);
                    //         tabPageKey.currentState.setState(() {});
                    //         print('${value['title']}');
                    //         setState(() {
                    //         });
                    //         localization.setLanguage(value['code']);
                    //       },
                    //     ),
                    //   ),
                    // ),

                    Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom:10),
                          child: Row(
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
                        ),
                        Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                spreadRadius: -2,
                                offset: Offset(0.0, 0.0))
                          ]),
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width * 0.42,
                            height: 50,
                            child: RaisedButton(
                              onPressed: () async {
                                print('exit is pressed');
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => CustomDialog(
                                        title: null,
                                        description:
                                            "Уверены, что хотите выйти?",
                                        buttonText: "Okay",
                                        image: CachedNetworkImage(imageUrl: 'https://indigo24.xyz/uploads/avatars/${user.avatar}'),
                                      ),
                                );
                                // SharedPreferences preferences =
                                //       await SharedPreferences.getInstance();
                                //   preferences.setString('phone', 'null');
                                //   Navigator.of(context).pushAndRemoveUntil(
                                //       MaterialPageRoute(
                                //           builder: (context) => IntroPage()),
                                //       (r) => false);
                              },
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  '${localization.exit}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              color: Color(0xFFFFFFFF),
                              textColor: Color(0xFF0543B8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(height: 20)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildCoverImage(screenSize),
            Column(
              children: <Widget>[
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () async {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsMainPage()));
                          },
                          child: Ink(
                            child: Image.asset("assets/images/settings.png", width: 35,),
                            // child: Text("${localization.exit}",
                            //     style: TextStyle(
                            //         color: Colors.white, fontSize: 18)),
                          )),
                    ),
                    SizedBox(width: 15),
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




class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final CachedNetworkImage image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Consts.padding),
      ),      
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
  return Stack(
    children: <Widget>[
        //...bottom card part,
        Container(
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  // top: Consts.avatarRadius + Consts.padding,
                  top: Consts.padding+24,
                  bottom: Consts.padding,
                  left: Consts.padding,
                  right: Consts.padding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // To make the card compact
                  children: <Widget>[
                    title!=null?Text(
                      title,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ):Container(),
                    // SizedBox(height: 16.0),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF001D52)
                      ),
                    ),
                    SizedBox(height: 24.0),
                  ],
                ),
              ),

              Container(
                decoration:  BoxDecoration(
                  color: Color(0xff001D52),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(Consts.padding), bottomRight: Radius.circular(Consts.padding)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        onPressed: () async{
                          Navigator.of(context).pop(); // To close the dialog
                          var preferences =await SharedPreferences.getInstance();
                          preferences.setString('phone', 'null');
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => IntroPage()),(r) => false);
                        },
                        child: Container(
                          height: 50,
                          child: Center(child: Text("ДА", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)))
                        ),
                      ),
                    ),
                    Container(width: 1, height: 50, color: Colors.white),
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Container(
                          height: 50,
                          child: Center(child: Text("НЕТ", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)))
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        //...top circlular image part,
        // Positioned(
        //   left: Consts.padding,
        //   right: Consts.padding,
        //   child: CircleAvatar(
        //     backgroundColor: Colors.transparent,
        //     radius: Consts.avatarRadius,
        //     child: ClipOval(child: image),
        //   ),
        // ),
      ],
    );
  }

}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}