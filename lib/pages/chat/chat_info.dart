import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/chat/chat_members_selection.dart';
import 'package:indigo24/pages/chat/chat_user_profile.dart';
import 'package:indigo24/pages/wallet/wallet.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;


class ChatProfileInfo extends StatefulWidget {
  final chatName;
  final chatAvatar;
  final chatId;
  final chatType;

  ChatProfileInfo(
      {this.chatType, this.chatId, this.chatName, this.chatAvatar});
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
    ChatRoom.shared.chatMembers(widget.chatId);
    chatTitleController.text = '${widget.chatName}';
    super.initState();
    memberCount = 0;



  }

  final picker = ImagePicker();
  var api = Api();

  listen() {
    ChatRoom.shared.onChatInfoChange.listen((e) {
      print("CHAT INFO EVENT");
      print(e.json);
      var cmd = e.json['cmd'];
      var message = e.json['data'];

      switch (cmd) {
        case "chat:members":
          setState(() {
            memberCount = 0;
            membersList = message;
            if(membersList.isNotEmpty){
              membersList.forEach((member){
                if(member['user_id'].toString() == '${user.id}'){
                  myPrivilege = member['role'].toString();
                }
                if(member['online'] == 'online'){
                  memberCount++;
                }
              });
            }
          });
          break;
        case "chat:members:privileges":
          ChatRoom.shared.chatMembers(widget.chatId);
          break;
        case "chat:members:delete":
          ChatRoom.shared.chatMembers(widget.chatId);
          break;
        case "chat:member:leave":
          print('isLeaved is true');
          Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Tabs()),(r) => false);
          break;
        default:
          print(message);
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
      onTap: () {
        if(widget.chatType == 1){
          // if(myPrivilege){
          //   // action()
          //   // action(widget.chatId, membersList[i]);
          // }
        } else{
          membersList.forEach((element){
           
          });
        }

        // Navigator.push(context,MaterialPageRoute(builder: (context) => ChatUserProfilePage(membersList[0])));
      },
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
            // image: DecorationImage(
            //   image: NetworkImage(
                  // widget.chatAvatar==null?'https://indigo24.xyz/uploads/avatars/noAvatar.png':
                  // 'https://indigo24.xyz/uploads/avatars/${widget.chatAvatar}'),
            //   fit: BoxFit.cover,
            // ),
            borderRadius: BorderRadius.circular(80.0),
            border: Border.all(
              color: Color(0xFF001D52),
              width: 5.0,
            ),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: widget.chatAvatar==null?
                'https://indigo24.xyz/uploads/avatars/noAvatar.png'
                :
                'https://indigo24.xyz/uploads/avatars/${widget.chatAvatar}',
              errorWidget: (context, url, error) => CachedNetworkImage(
                imageUrl: "https://indigo24.xyz/uploads/avatars/noAvatar.png",
              ),
            ),
          ),
        ),
      ),
    );
  }

  adminAction(chatId, member){
    final act = CupertinoActionSheet(
    title: Text('Выберите вариант'),
    actions: <Widget>[
      CupertinoActionSheetAction(
        child: Text('Профиль'),
        onPressed: () {
          Navigator.pop(context);
          ChatRoom.shared.cabinetController.close();
          ChatRoom.shared.setCabinetInfoStream();
          Navigator.push(context,MaterialPageRoute(builder: (context) => ChatUserProfilePage(
            member,
            name: member['user_name'],
            phone: member['phone'],
            email: member['email'],
            image: member['avatar_url']+member['avatar'],
          ))).whenComplete(() {
            ChatRoom.shared.closeCabinetInfoStream();
          });
        },
      ),
      member['role'] == '2' ? CupertinoActionSheetAction(
        isDestructiveAction: true,
        child: Text('Удалить'),
        onPressed: () {
          ChatRoom.shared.deleteChatMember(chatId, member['user_id']);
          Navigator.pop(context);
        },
      ) : Center()
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
  }

  memberAction(member){
    final act = CupertinoActionSheet(
    title: Text('Выберите вариант'),
    actions: <Widget>[
      CupertinoActionSheetAction(
        child: Text('Профиль'),
        onPressed: () {
          Navigator.pop(context);
          ChatRoom.shared.cabinetController.close();
          ChatRoom.shared.setCabinetInfoStream();
          Navigator.push(context,MaterialPageRoute(builder: (context) => ChatUserProfilePage(
            member,
            name: member['user_name'],
            phone: member['phone'],
            email: member['email'],
            image: member['avatar_url']+member['avatar'],
          ))).whenComplete(() {
            ChatRoom.shared.closeCabinetInfoStream();
          });
        },
      ),
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
  }

  addMembers(chatId){
  final act = CupertinoActionSheet(
    title: Text('Выберите вариант'),
    actions: <Widget>[
      myPrivilege == '0' ? CupertinoActionSheetAction(
        child: Text('Добавить в группу'),
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(context,MaterialPageRoute(builder: (context) => ChatMembersSelection(chatId, membersList))).whenComplete(() {
            ChatRoom.shared.contactController.close();
            ChatRoom.shared.closeContactsStream();
            ChatRoom.shared.chatMembers(widget.chatId);
          });
        },
      ) : Container(),
      CupertinoActionSheetAction(
        isDestructiveAction: true,
        child: Text('Покинуть беседу'),
        onPressed: () {
          Widget okButton = CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text("Да"),
            onPressed: () {
              Navigator.pop(context);
              ChatRoom.shared.leaveChat(widget.chatId);
            },
          );
          Widget noButton = CupertinoDialogAction(
            child: Text("Нет"),
            onPressed: () {
              Navigator.pop(context);
            },
          );
          CupertinoAlertDialog alert = CupertinoAlertDialog(
            title: Text("Внимание"),
            content: Text('Вы точно хотите покинуть беседу?'),
            actions: [
              noButton,
              okButton,
            ],
          );
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        },
      ),
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
  }

  action(chatId, member){
    final act = CupertinoActionSheet(
    title: Text('Выберите вариант'),
    actions: <Widget>[
      CupertinoActionSheetAction(
        child: Text('Профиль'),
        onPressed: () {
          Navigator.pop(context);
          ChatRoom.shared.cabinetController.close();
          ChatRoom.shared.setCabinetInfoStream();
          Navigator.push(context,MaterialPageRoute(builder: (context) => ChatUserProfilePage(
            member,
            name: member['user_name'],
            phone: member['phone'],
            email: member['email'],
            image: member['avatar_url']+member['avatar'],
          ))).whenComplete(() {
            ChatRoom.shared.closeCabinetInfoStream();
          });
        },
      ),
      CupertinoActionSheetAction(
        child: member['role'] == '2' ? Text('Назначить администратором') : member['role'] ==  '1' ? Text('Сделать участником') : Text(''),
        onPressed: () {
           switch (member['role']) {
            case '2':
              print('toAdmin');
              ChatRoom.shared.changePrivileges(chatId, member['user_id'], 1);
              break;
            case '1':
              print('toMember');
              ChatRoom.shared.changePrivileges(chatId, member['user_id'], 2);
              break;
             default:
           }
          ChatRoom.shared.chatMembers(widget.chatId);
          Navigator.pop(context);
        },
      ),
      CupertinoActionSheetAction(
        isDestructiveAction: true,
        child: Text('Удалить'),
        onPressed: () {
          ChatRoom.shared.deleteChatMember(chatId, member['user_id']);
          Navigator.pop(context);
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
  }

  TextEditingController chatTitleController = TextEditingController();
  int memberCount = 0;
  String myPrivilege = '';
  bool isEditing = false;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
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
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isEditing = !isEditing;
                              });
                            },
                            child: isEditing ? Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: chatTitleController,
                                    style: fS26(c: 'ffffff'),
                                    onSubmitted: (value){
                                      ChatRoom.shared.changeChatName(widget.chatId, value);
                                    },
                                    decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
                                    ),
                                  ),
                                ),
                                Icon(Icons.edit, color: Colors.white)
                              ],
                            ) : Text('$_chatTitle', style: fS26(c: 'ffffff'), maxLines: 1, overflow: TextOverflow.ellipsis,)
                            )
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert),
                          color: Colors.white,
                          onPressed: () {
                            widget.chatType == 1 
                            ? addMembers(widget.chatId) 
                            : print('Change this action to private functions'); // TODO
                            // ChatRoom.shared.addMembers(widget.chatId, )
                          },
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
                    widget.chatType == 1
                    ? Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 20),
                      child: Text(
                        '${localization.members}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : Container(),
                    widget.chatType == 1
                    ? Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 20),
                      child: Text(
                        '$memberCount online',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : Center(),
                    SizedBox(height: 10),
                    membersList.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        :
                        widget.chatType == 0 ?
                        Center(
                          child: Text("Статус", style: TextStyle(
                            fontSize: 24,
                            // fontFamily: ""
                          )),
                        )
                        : Flexible(
                            child: ScrollConfiguration(
                              behavior: MyBehavior(),
                              child: ListView.builder(
                                itemCount: membersList.length,
                                itemBuilder: (context, i) {
                                  // print(membersList[i]);
                                  return ListTile(
                                    
                                    onTap: () {
                                      if(membersList[i]['user_id'].toString() == '${user.id}'){
                                        print(membersList[i]['user_id'].toString() == '${user.id}');
                                        // memberAction(membersList[i]);
                                      } else{
                                        switch (myPrivilege) {
                                          case '0':
                                              print('ownerAction');
                                              action(widget.chatId, membersList[i]);
                                            break;
                                          case '1':
                                              print('adminAction');
                                              adminAction(widget.chatId, membersList[i]);
                                            break;
                                          case '2':
                                              print('memberAction');
                                              memberAction(membersList[i]);
                                            break;
                                          default:
                                        }
                                      }



                                      // ChatRoom.shared.checkUserOnline(ids);
                                      // ChatRoom.shared
                                      //     .getMessages(membersList[i]['id']);
                                    },
                                    leading: Container(
                                      height: 42,
                                      width: 42,
                                      child: Stack(
                                        children: <Widget>[
                                          CircleAvatar(
                                              backgroundImage: (membersList[i]["avatar"] == null ||
                                                      membersList[i]["avatar"] == '' ||
                                                      membersList[i]["avatar"] == false)
                                                  ? CachedNetworkImageProvider(
                                                      "https://indigo24.xyz/uploads/avatars/noAvatar.png")
                                                  : 
                                                  CachedNetworkImageProvider(
                                                      'https://indigo24.xyz/uploads/avatars/${membersList[i]["avatar"]}'),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: (membersList[i]["avatar"] == null ||
                                                      membersList[i]["avatar"] == '' ||
                                                      membersList[i]["avatar"] == false)?
                                                      "https://indigo24.xyz/uploads/avatars/noAvatar.png"
                                                      :
                                                      'https://indigo24.xyz/uploads/avatars/${membersList[i]["avatar"]}',
                                                errorWidget: (context, url, error) => CachedNetworkImage(
                                                  imageUrl: "https://indigo24.xyz/uploads/avatars/noAvatar.png",
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration:  BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: membersList[i]['online'] == 'online' ? Colors.white: Colors.transparent
                                                ),
                                              child: Container(
                                                decoration:  BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: membersList[i]['online'] == 'online' ? Color(0xFF00cc00) : Colors.transparent
                                                ),
                                                height: 15, 
                                                width: 15, 
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    title: Text("${membersList[i]["user_name"]}"),
                                    subtitle: memberName(membersList[i])
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text memberName(member) {
    switch ('${member["role"]}') {
      case '0':
        return Text('${localization.creator}');
        break;
      case '1':
        return Text('Администратор');
        break;
      case '2':
        return Text('${localization.member}');
        break;
      default:
        return Text('hi');
    }
  } 
}
