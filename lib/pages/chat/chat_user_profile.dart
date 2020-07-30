import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat/chat.dart';
import 'package:indigo24/pages/chat/chat_contacts.dart';
import 'package:indigo24/pages/chat/chat_list.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/photo.dart';
import 'package:photo_view/photo_view.dart';
import 'package:indigo24/services/localization.dart' as localization;

class ChatUserProfilePage extends StatefulWidget {
  final phone;
  final email;
  final image;
  final member;
  final name;
  ChatUserProfilePage(this.member,
      {this.name, this.phone, this.email, this.image});

  @override
  _ChatUserProfileStatePage createState() => _ChatUserProfileStatePage();
}

class _ChatUserProfileStatePage extends State<ChatUserProfilePage> {
  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    ChatRoom.shared.closeCabinetInfoStream();
  }

  bool isInMyPhoneBook = false;

  @override
  void initState() {
    contacts.forEach((element) {
      if (element['phone'].toString() == widget.phone.toString()) {
        print(widget.phone);
        print(element['phone'].toString());
        isInMyPhoneBook = true;
      }
    });
    super.initState();

    listen();
  }

  listen() {
    ChatRoom.shared.onCabinetInfoChange.listen((e) {
      print("CHAT USER INFO EVENT");
      print(e.json);
      var cmd = e.json['cmd'];
      var message = e.json['data'];

      switch (cmd) {
        case "user:check":
          if (e.json['data']['chat_id'].toString() != 'false' &&
              e.json['data']['status'].toString() == 'true') {
            ChatRoom.shared.setCabinetStream();
            ChatRoom.shared.getMessages('${e.json['data']['chat_id']}');

            print("USER CHECK DATA: ${e.json['data']}");
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                      '${e.json['data']['name']}', e.json['data']['chat_id'],
                      memberCount: 2,
                      userIds: e.json['data']['user_id'],
                      avatar: '${e.json['data']['avatar']}',
                      avatarUrl: '${e.json['data']['avatar_url']}')),
            ).whenComplete(() {
              // this is bool for check load more is needed or not
              globalBoolForForceGetChat = false;
              ChatRoom.shared.forceGetChat();
              ChatRoom.shared.closeCabinetStream();
            });
          } else if (e.json['data']['status'].toString() == 'true') {
            print('____________________');
            print('else if e.jsonDataStatus == true');
            print({e.json['data']['user_id']});
            print({e.json['data']['user_id']});
            print({e.json['data']['user_id']});
            print({e.json['data']['user_id']});
            print({e.json['data']['user_id']});
            print({e.json['data']['user_id']});
            print('____________________');
            ChatRoom.shared.setCabinetStream();
            ChatRoom.shared.cabinetCreate("${e.json['data']['user_id']}", 0);
          }
          break;
        default:
          print(message);
          print('chat user profile');
          print(cmd);
          print('chat user profile');
          print('chat user profile');
          print('chat user profile');
          print('chat user profile');
          print('chat user profile');
      }
    });
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
            title: Text('${localization.selectOption}'),
            // message: Text('Which option?'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text('${localization.watch}'),
                onPressed: () {
                  print("посмотреть ${widget.image}");
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullScreenWrapper(
                                imageProvider: CachedNetworkImageProvider(
                                    "${widget.image}"),
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: PhotoViewComputedScale.contained * 3,
                                backgroundDecoration:
                                    BoxDecoration(color: Colors.transparent),
                              )));
                },
              ),
              // CupertinoActionSheetAction(
              //   child: Text('Перейти в чат с ${widget.member['user_name']}'),
              //   onPressed: () {
              //     // Navigator.pop(context);
              //     // Navigator.push(context,MaterialPageRoute(builder: (context) => ChatPage(name, chatID, userIds: widget.member['user_id'], avatar: widget.member['avatar'], avatarUrl: widget.member['avatar_url'],)));
              //   },
              // ),
              CupertinoActionSheetAction(
                child: Text('${localization.goToChat}'),
                onPressed: () {
                  print(widget.phone);
                  ChatRoom.shared.setContactsStream();
                  ChatRoom.shared.userCheck(widget.phone);
                  // Navigator.pop(context);
                },
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('${localization.back}'),
              onPressed: () {
                Navigator.pop(context);
              },
            ));
        showCupertinoModalPopup(
            context: context, builder: (BuildContext context) => act);
      },
      child: Center(
        child: Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider('${widget.image}'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(80.0),
            border: Border.all(
              color: blackPurpleColor,
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
      '${widget.name}',
      style: _nameTextStyle,
    );
  }

  Widget buildEmailSection(Size screenSize) {
    return Container(
      width: screenSize.width / 1.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("${localization.email}"),
          SizedBox(height: 5),
          Text('${widget.email}'),
          SizedBox(height: 5)
        ],
      ),
    );
  }

  Widget _buildPhoneSection(Size screenSize) {
    if (isInMyPhoneBook)
      return Column(
        children: <Widget>[
          Container(
            width: screenSize.width / 1.3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("${localization.phoneNumber}"),
                SizedBox(height: 5),
                Text('${widget.phone}',
                    textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
                SizedBox(height: 5),
              ],
            ),
          ),
          _buildSeparator(screenSize),
          SizedBox(height: 10),
        ],
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
                          // _buildEmailSection(screenSize),
                          // _buildSeparator(screenSize),
                        ],
                      ),
                      Column(
                        children: <Widget>[Container(height: 20)],
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
