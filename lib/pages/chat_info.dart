import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/pages/intro.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indigo24/services/user.dart' as user;

class ChatProfileInfo extends StatefulWidget {
  final chatName;
  final chatAvatar;
  final chatMembers;
  ChatProfileInfo({this.chatName, this.chatAvatar, this.chatMembers});
  @override
  _ChatProfileInfoState createState() => _ChatProfileInfoState();
}

class _ChatProfileInfoState extends State<ChatProfileInfo> {
  String _chatTitle;

  File _image;
  @override
  void initState() {
    _chatTitle = '${widget.chatName}';
    super.initState();
  }

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
      // onTap: () => PlatformActionSheet().displaySheet(
      //     context: context,
      //     message: Text("Выберите опцию"),
      //     actions: [
      //       ActionSheetAction(
      //         text: "Сфотографировать",
      //         onPressed: () {
      //           getImage(ImageSource.camera);
      //           Navigator.pop(context);
      //         },
      //         hasArrow: true,
      //       ),
      //       ActionSheetAction(
      //         text: "Выбрать из галереи",
      //         onPressed: () {
      //           getImage(ImageSource.gallery);
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ActionSheetAction(
      //         text: "Назад",
      //         onPressed: () => Navigator.pop(context),
      //         isCancel: true,
      //         defaultAction: true,
      //       )
      //     ]),
      child: Center(
        child: Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://indigo24.xyz/uploads/avatars/noAvatar.png'),
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

  Widget _buildChatName() {
    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
    );

    return Text(
      _chatTitle,
      style: _nameTextStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              _buildCoverImage(screenSize),
              Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text('$_chatTitle', style: fS26(c: 'ffffff')),
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        color: Colors.white,
                        onPressed: (){},
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildProfileImage(),
                    ],
                  ),
                  _buildChatName(),
                  SizedBox(height: 10),
                  _buildChatName(),
                  Text('grustno')
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
