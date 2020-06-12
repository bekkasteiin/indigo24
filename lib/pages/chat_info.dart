import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/pages/intro.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:indigo24/services/user.dart' as user;

class ChatProfileInfo extends StatefulWidget {
  final chatName;
  final chatAvatar;
  final chatMembers;
  final chatId;
  ChatProfileInfo(
      {this.chatId, this.chatName, this.chatAvatar, this.chatMembers});
  @override
  _ChatProfileInfoState createState() => _ChatProfileInfoState();
}

class _ChatProfileInfoState extends State<ChatProfileInfo> {
  List membersList = [];
  String _chatTitle;

  File _image;
  @override
  void initState() {
    _chatTitle = '${widget.chatName}';
    listen();
    ChatRoom.shared.chatMembers(13, widget.chatId);
    super.initState();
  }

  final picker = ImagePicker();
  var api = Api();

  listen() {
    ChatRoom.shared.onChatInfoChange.listen((e) {
      print("CHAT INFO EVENT");
      // print(e.json);
      var cmd = e.json['cmd'];
      var message = e.json['data'];

      switch (cmd) {
        case "chat:members":
          setState(() {
            membersList = message;
          });
          break;
        default:
          print(message);
          print('no');
          print('no');
          print(cmd);
          print('no');
          print('no');
          print('no');
          print('no');
          print('no');
      }
    });
  }

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

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
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
                        onPressed: () {},
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
                  SizedBox(height: 10),
                  Row(children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Text(
                        'Участники',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: 10),
                  membersList.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : Flexible(
                          child: ListView.builder(
                            itemCount: membersList.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, i) {
                              // print(membersList[i]);
                              return Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                // actions: <Widget>[
                                //   IconSlideAction(
                                //     caption: 'Archive',
                                //     color: Colors.blue,
                                //     icon: Icons.archive,
                                //   ),
                                //   IconSlideAction(
                                //     caption: 'Share',
                                //     color: Colors.indigo,
                                //     icon: Icons.share,
                                //   ),
                                // ],
                                secondaryActions: <Widget>[
                                  // IconSlideAction(
                                  //   caption: 'More',
                                  //   color: Colors.black45,
                                  //   icon: Icons.more_horiz,
                                  // ),
                                  IconSlideAction(
                                    caption: 'Удалить',
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    onTap: () {
                                      ChatRoom.shared.deleteMembers(
                                          '${widget.chatId}',
                                          membersList[i]['user_id']);
                                      setState(() {
                                        membersList.remove(i);
                                      });
                                    },
                                  ),
                                ],
                                child: ListTile(
                                  onTap: () {
                                    // ChatRoom.shared.checkUserOnline(ids);
                                    // ChatRoom.shared
                                    //     .getMessages(membersList[i]['id']);
                                  },
                                  leading: CircleAvatar(
                                      backgroundImage: (membersList[i]
                                                      ["avatar"] ==
                                                  null ||
                                              membersList[i]["avatar"] == '' ||
                                              membersList[i]["avatar"] == false)
                                          ? CachedNetworkImageProvider(
                                              "https://media.indigo24.com/avatars/noAvatar.png")
                                          : CachedNetworkImageProvider(
                                              'https://indigo24.xyz/uploads/avatars/${membersList[i]["avatar"]}')),
                                  title: Text("${membersList[i]["user_name"]}"),
                                ),
                              );
                            },
                          ),
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
