import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat/chat.dart';
import 'package:indigo24/pages/chat/chat_contacts.dart';
import 'package:indigo24/pages/settings/settings_main.dart';
import 'package:indigo24/widgets/photo.dart';
import 'package:photo_view/photo_view.dart';
import 'package:indigo24/services/localization.dart' as localization;


class ChatUserProfilePage extends StatefulWidget {
  final member;
  final hiddenId;
  ChatUserProfilePage(this.member, this.hiddenId);
  @override
  _ChatUserProfileStatePage createState() => _ChatUserProfileStatePage();
}

class _ChatUserProfileStatePage extends State<ChatUserProfilePage> {
  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }



  bool isInMyPhoneBook = false;

  @override
  void initState() {
    contacts.forEach((element) {
      if(element['phone'].toString() == widget.member['phone'].toString()){
        isInMyPhoneBook = true;
      }
    });
    super.initState();
  }

  var percent = "0 %";
  double uploadPercent = 0.0;
  bool isUploading = false;


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
      onTap: () {
        final act = CupertinoActionSheet(
    title: Text('Выберите опцию'),
    // message: Text('Which option?'),
    actions: <Widget>[
      CupertinoActionSheetAction(
        child: Text('Посмотреть'),
        onPressed: () {
          print("посмотреть");
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FullScreenWrapper(
                  imageProvider: CachedNetworkImageProvider("${widget.member['avatar_url']}${widget.member['avatar']}"),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained*3,
                  backgroundDecoration: BoxDecoration(
                    color: Colors.transparent
                  ),
                )));
        },
      ),
      // CupertinoActionSheetAction(
      //   child: Text('Перейти в чат с ${widget.member['user_name']}'),
      //   onPressed: () {
      //     // Navigator.pop(context);
      //     // TODO check user online
      //     // Navigator.push(context,MaterialPageRoute(builder: (context) => ChatPage(name, chatID, userIds: widget.member['user_id'], avatar: widget.member['avatar'], avatarUrl: widget.member['avatar_url'],)));
      //   },
      // ),
      CupertinoActionSheetAction(
        child: Text('Что-то еще'),
        onPressed: () {
          // Navigator.pop(context);
        },
      )
    ],
    cancelButton: CupertinoActionSheetAction(
      child: Text('Назад'),
      onPressed: () {
        Navigator.pop(context);
      },
    ));
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => act);
    },
      child: Center(
        child: Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                  '${widget.member['avatar_url']}${widget.member['avatar']}'),
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
      '${widget.member['user_name']}',
      style: _nameTextStyle,
    );
  }



  Widget _buildEmailSection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("${localization.email}"),
          SizedBox(height: 5),
          Text('${widget.member['email']}'),
          SizedBox(height: 5)
        ],
      ),
    );
  }

  Widget _buildPhoneSection(Size screenSize) {
    if(isInMyPhoneBook)
      return Container(
        width: screenSize.width / 1.3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("${localization.phoneNumber}"),
            SizedBox(height: 5),
            Text('${widget.member['phone']}',
                textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
            SizedBox(height: 5),
          ],
        ),
      );
    else
      return Container();
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
    return Container(
      color: Colors.white,
      child: SafeArea(
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
                      Column(
                        children: <Widget>[
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
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(5),
                        child: Image(
                          image: AssetImage(
                            'assets/images/backWhite.png',
                          ),
                        ),
                      ),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
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
      ),
    );
  }
}

