import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/chat/chat_members_selection.dart';
import 'package:indigo24/pages/chat/chat_user_profile.dart';
import 'package:indigo24/pages/chat/ui/new_chat/chat.dart';
import 'package:indigo24/pages/wallet/wallet.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/helper.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/photo.dart';
import 'package:indigo24/widgets/progress_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'chat.dart';
import 'chat_list.dart';

class ChatProfileInfo extends StatefulWidget {
  final chatName;
  final chatAvatar;
  final chatId;
  final chatType;
  final memberCount;
  final anotherUserPhone;
  final phone;
  ChatProfileInfo({
    this.chatType,
    this.anotherUserPhone,
    this.phone,
    this.chatId,
    this.chatName,
    this.chatAvatar,
    this.memberCount,
  });
  @override
  _ChatProfileInfoState createState() => _ChatProfileInfoState();
}

class _ChatProfileInfoState extends State<ChatProfileInfo> {
  bool _isEditing;

  int _onlineCount;
  int _membersCount;
  int _chatMembersPage;

  String _chatTitle;
  String _myPrivilege;

  List _membersList;
  List _actualMembersList;

  TextEditingController _chatTitleController;
  TextEditingController _searchController;

  File _image;
  ImagePicker _picker;
  Api _api;

  RefreshController _refreshController;
  String chatAvatar;
  @override
  void initState() {
    // print('chatName ${widget.chatName}');
    // print('chatAvatar ${widget.chatAvatar}');
    // print('chatId ${widget.chatId}');
    // print('chatType ${widget.chatType}');
    // print('memberCount ${widget.memberCount}');
    if (widget.chatAvatar != null) chatAvatar = widget.chatAvatar;
    _isEditing = false;

    _chatMembersPage = 1;
    _onlineCount = 0;

    _myPrivilege = '';

    _membersList = [];
    _actualMembersList = [];

    _picker = ImagePicker();

    _api = Api();

    _chatTitleController = TextEditingController();
    _searchController = TextEditingController();
    _refreshController = RefreshController(initialRefresh: false);

    _membersCount = widget.memberCount;

    _chatTitle = '${widget.chatName}';
    _listen();
    ChatRoom.shared.chatMembers(widget.chatId, page: _chatMembersPage);
    if (widget.chatName.length > 2) {
      _chatTitleController.text =
          '${_chatTitle[0].toUpperCase()}${_chatTitle.substring(1)}';
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  _listen() {
    ChatRoom.shared.onChatInfoChange.listen((e) {
      print("CHAT INFO EVENT ${e.json}");
      var cmd = e.json['cmd'];
      var message = e.json['data'];
      if (ModalRoute.of(context).isCurrent) {
        switch (cmd) {
          case "chat:members":
            setState(() {
              _onlineCount = 0;
              if (_chatMembersPage.toString() == '1') {
                _membersList = message;
                _actualMembersList = message;
              } else {
                _membersList.addAll(message);
                _actualMembersList.addAll(message);
              }
              if (_membersList.isNotEmpty) {
                _membersList.forEach((member) {
                  if (member['user_id'].toString() == '${user.id}') {
                    print(
                        'setting member user id == user.id to ${member['role']}');
                    _myPrivilege = member['role'].toString();
                  }
                  if (member['online'] == 'online') {
                    _onlineCount++;
                  }
                });
              }
            });
            break;
          case "chat:members:privileges":
            ChatRoom.shared.chatMembers(widget.chatId);
            break;
          case "chat:member:search":
            setState(() {
              _actualMembersList = [];
              if (message.isNotEmpty) {
                _actualMembersList.addAll(message);
              }
              if (_searchController.text.isEmpty) {
                _actualMembersList.addAll(_membersList);
              }
            });
            break;
          case "chat:members:delete":
            ChatRoom.shared.chatMembers(widget.chatId);
            break;
          case "set:group:avatar":
            setState(() {
              chatAvatar = message['avatar'].replaceAll('AxB', '200x200');
            });
            break;
          case "chat:member:leave":
            print('isLeaved is true');
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Tabs()), (r) => false);
            break;
          case "user:check":
            if (e.json['data']['chat_id'].toString() != 'false' &&
                e.json['data']['status'].toString() == 'true') {
              // ChatRoom.shared.setChatStream();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    chatName: '${e.json['data']['name']}',
                    chatId: int.parse(e.json['data']['chat_id'].toString()),
                    userIds: e.json['data']['user_id'].toString(),
                    chatType: 0,
                    avatar: '${e.json['data']['avatar']}',
                    avatarUrl: '${e.json['data']['avatar_url']}',
                  ),
                ),
              ).whenComplete(() {});
            } else if (e.json['data']['status'].toString() == 'true') {
              print('____________________');
              print('else if e.jsonDataStatus == true');
              print({e.json['data']['user_id']});
              print('____________________');
              // ChatRoom.shared.setChatStream();
              ChatRoom.shared.cabinetCreate("${e.json['data']['user_id']}", 0);
            }
            break;
          default:
            print('Default of chat info $message');
        }
      }
    });
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    print("_onRefresh");
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (_actualMembersList.length % 20 == 0) {
      _chatMembersPage++;
      if (mounted)
        setState(() {
          print("_onLoading chat members with page $_chatMembersPage");
          ChatRoom.shared.chatMembers(widget.chatId, page: _chatMembersPage);
        });
      _refreshController.loadComplete();
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

  Dio dio;
  var percent = "0 %";
  double uploadPercent = 0.0;
  bool isUploading = false;
  Response response;
  ProgressBar sendingMsgProgressBar;
  BaseOptions options = new BaseOptions(
    baseUrl: "$baseUrl",
    connectTimeout: 60000,
    receiveTimeout: 60000,
  );
  final picker = ImagePicker();

  uploadAvatar(_path) async {
    sendingMsgProgressBar = ProgressBar();
    dio = new Dio(options);

    try {
      FormData formData = FormData.fromMap({
        "user_id": "${user.id}",
        "userToken": "${user.unique}",
        "file": await MultipartFile.fromFile(_path),
        'group': 1,
      });
      print("Uploading avatar with data ${formData.fields}");

      // _sendingMsgProgressBar.show(context, "");

      response = await dio.post(
        "$mediaChat",
        data: formData,
        onSendProgress: (int sent, int total) {
          String p = (sent / total * 100).toStringAsFixed(2);

          setState(() {
            isUploading = true;
            uploadPercent = sent / total;
            percent = "$p %";
          });
          print("$percent");
        },
        onReceiveProgress: (count, total) {
          setState(() {
            isUploading = false;
            uploadPercent = 0.0;
            percent = "0 %";
          });
        },
      );
      print("Getting response from avatar upload ${response.data}");
      // _sendingMsgProgressBar.hide();

      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.statusCode);
      } else {
        print(e.request);
        print(e.message);
      }
    }
  }

  showAlertDialog(BuildContext context, String message) {
    Widget okButton = CupertinoDialogAction(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("${localization.error}"),
      content: Text(message),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
      source: imageSource,
    );
    final dir = await getTemporaryDirectory();

    final targetPath = dir.absolute.path + "/temp.jpg";

    if (pickedFile != null) {
      File compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
      );
      File test = File(pickedFile.path);
      compressedImage.length().then((value) => print(value));
      print("Picked file ${test.lengthSync()}");
      setState(() {
        _image = compressedImage;
        // _image = File(pickedFile.path);
      });
      if (_image != null) {
        uploadAvatar(_image.path).then((r) async {
          print('this is $r');
          if (r['message'] == 'Not authenticated' &&
              r['success'].toString() == 'false') {
            logOut(context);
            return r;
          } else {
            if (r["success"]) {
              print("changing avatar is ${r["file_name"]}");
              ChatRoom.shared.setGroupAvatar(
                  int.parse(widget.chatId.toString()), r["file_name"]);
            } else {
              showAlertDialog(context, "${r["message"]}");
              print("error");
            }
            return r;
          }
        });
      }
    }
  }

  buildProfileImageAction() {
    final act = CupertinoActionSheet(
      title: Text('${localization.selectOption}'),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('${localization.watch}'),
          onPressed: () async {
            Navigator.pop(context);
            var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenWrapper(
                  imageProvider: CachedNetworkImageProvider(
                      "${widget.chatType.toString() == '1' ? groupAvatarUrl : avatarUrl}${chatAvatar.toString().replaceAll('AxB', '200x200')}"),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 3,
                  backgroundDecoration:
                      BoxDecoration(color: Colors.transparent),
                ),
              ),
            );
            setState(() {
              chatAvatar = result;
            });
          },
        ),
        CupertinoActionSheetAction(
          child: Text('${localization.camera}'),
          onPressed: () {
            getImage(ImageSource.camera);
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: Text('${localization.gallery}'),
          onPressed: () {
            getImage(ImageSource.gallery);
            Navigator.pop(context);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('${localization.back}'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => act,
    );
  }

  Widget _buildProfileImage() {
    return InkWell(
      onTap: () {
        if (widget.chatType == 1) {
          if (_myPrivilege == '$ownerRole' || _myPrivilege == '$adminRole')
            buildProfileImageAction();
        } else {
          dynamic newMember = {'phone': widget.phone};
          _memberAction(newMember);
        }
      },
      child: Center(
        child: Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(80.0),
            border: Border.all(
              color: blackPurpleColor,
              width: 5.0,
            ),
          ),
          child: ClipOval(
            child: Center(
              child:
                  // '${widget.chatType}' == '1'
                  // ? Stack(
                  //     children: <Widget>[
                  //       Flexible(
                  //         child: Container(
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //       GridView.count(
                  //         crossAxisCount: 2,
                  //         physics: NeverScrollableScrollPhysics(),
                  //         children: List.generate(_membersList.length, (index) {
                  //           return Image.network(
                  //               '${_membersList[index]['avatar_url']}${_membersList[index]["avatar"].toString().replaceAll("AxB", "200x200")}');
                  //         }),
                  //       ),
                  //     ],
                  //   )
                  // :
                  Container(
                height: 100,
                width: 100,
                color: greyColor,
                child: widget.chatType.toString() == '1'
                    ? CachedNetworkImage(
                        imageUrl: chatAvatar != null
                            ? '$groupAvatarUrl${chatAvatar}'
                            : '${avatarUrl}noAvatar.png',
                      )
                    : CachedNetworkImage(
                        imageUrl: chatAvatar != null
                            ? '$chatAvatar'
                            : '${avatarUrl}noAvatar.png',
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _adminAction(chatId, member) {
    final act = CupertinoActionSheet(
      title: Text('${localization.selectOption}'),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('${localization.watch}'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenWrapper(
                  imageProvider: CachedNetworkImageProvider(
                      "${widget.chatType.toString() == '1' ? groupAvatarUrl : avatarUrl}${chatAvatar.toString().replaceAll('AxB', '200x200')}"),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 3,
                  backgroundDecoration:
                      BoxDecoration(color: Colors.transparent),
                ),
              ),
            );
          },
        ),
        CupertinoActionSheetAction(
          child: Text('${localization.goToChat}'),
          onPressed: () {
            ChatRoom.shared.userCheck(member['phone']);
            Navigator.pop(context);
          },
        ),
        // CupertinoActionSheetAction(
        //   child: Text('${localization.profile}'),
        //   onPressed: () {
        //     Navigator.pop(context);
        //     ChatRoom.shared.chatController.close();
        //     ChatRoom.shared.setChatUserProfileInfoStream();
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => ChatUserProfilePage(
        //           member,
        //           name: member['user_name'],
        //           phone: member['phone'],
        //           email: member['email'],
        //           image: member['avatar_url'] + member['avatar'],
        //         ),
        //       ),
        //     ).whenComplete(
        //       () {
        //         ChatRoom.shared.closeCabinetInfoStream();
        //       },
        //     );
        //   },
        // ),
        member['role'] == '$memberRole'
            ? CupertinoActionSheetAction(
                isDestructiveAction: true,
                child: Text('${localization.delete}'),
                onPressed: () {
                  setState(() {
                    _membersCount -= 1;
                  });
                  ChatRoom.shared.deleteChatMember(chatId, member['user_id']);
                  Navigator.pop(context);
                },
              )
            : Center()
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('${localization.back}'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => act,
    );
  }

  _memberAction(member) {
    final act = CupertinoActionSheet(
      title: Text('${localization.selectOption}'),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('${localization.watch}'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenWrapper(
                  imageProvider: CachedNetworkImageProvider(
                      "${widget.chatType.toString() == '1' ? groupAvatarUrl : avatarUrl}${chatAvatar.toString().replaceAll('AxB', '200x200')}"),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 3,
                  backgroundDecoration:
                      BoxDecoration(color: Colors.transparent),
                ),
              ),
            );
          },
        ),
        CupertinoActionSheetAction(
          child: Text('${localization.goToChat}'),
          onPressed: () {
            ChatRoom.shared.userCheck(member['phone']);
            Navigator.pop(context);
          },
        ),
        // CupertinoActionSheetAction(
        //   child: Text('${localization.profile}'),
        //   onPressed: () {
        //     Navigator.pop(context);
        //     ChatRoom.shared.chatController.close();
        //     ChatRoom.shared.setChatUserProfileInfoStream();
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => ChatUserProfilePage(
        //           member,
        //           name: member['user_name'],
        //           phone: member['phone'],
        //           email: member['email'],
        //           image: member['avatar_url'] + member['avatar'],
        //         ),
        //       ),
        //     ).whenComplete(
        //       () {
        //         ChatRoom.shared.closeCabinetInfoStream();
        //       },
        //     );
        //   },
        // ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('${localization.back}'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => act,
    );
  }

  _addMembers(chatId) {
    final act = CupertinoActionSheet(
        title: Text('${localization.selectOption}'),
        actions: <Widget>[
          _myPrivilege == '$ownerRole' || _myPrivilege == '$adminRole'
              ? CupertinoActionSheetAction(
                  child: Text('${localization.addToGroup}'),
                  onPressed: () {
                    Navigator.pop(context);
                    ChatRoom.shared.closeChatInfoStream();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatMembersSelection(chatId, _membersList),
                      ),
                    ).whenComplete(() {
                      ChatRoom.shared.closeContactsStream();
                      ChatRoom.shared.chatMembers(widget.chatId);
                    });
                  },
                )
              : Container(),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: Text('${localization.exitGroup}'),
            onPressed: () {
              Widget okButton = CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text("${localization.yes}"),
                onPressed: () {
                  Navigator.pop(context);
                  ChatRoom.shared.leaveChat(widget.chatId);
                },
              );
              Widget noButton = CupertinoDialogAction(
                child: Text("${localization.no}"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              CupertinoAlertDialog alert = CupertinoAlertDialog(
                title: Text("${localization.attention}"),
                content: Text('${localization.sureExitGroup}'),
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
          child: Text('${localization.back}'),
          onPressed: () {
            Navigator.pop(context);
          },
        ));
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
  }

  _action(chatId, member) {
    final act = CupertinoActionSheet(
      title: Text('${localization.selectOption}'),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('${localization.watch}'),
          onPressed: () {
            Navigator.pop(context);
            print('$avatarUrl$chatAvatar');
            print('$avatarUrl$chatAvatar');
            print('$avatarUrl$chatAvatar');
            print('$avatarUrl$chatAvatar');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenWrapper(
                  imageProvider: CachedNetworkImageProvider(
                      "$avatarUrl${chatAvatar.toString().replaceAll('AxB', '200x200')}"),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 3,
                  backgroundDecoration:
                      BoxDecoration(color: Colors.transparent),
                ),
              ),
            );
          },
        ),
        CupertinoActionSheetAction(
          child: Text('${localization.goToChat}'),
          onPressed: () {
            ChatRoom.shared.userCheck(member['phone']);
            Navigator.pop(context);
          },
        ),
        // CupertinoActionSheetAction(
        //   child: Text('${localization.watch}'),
        //   onPressed: () {
        //     Navigator.pop(context);
        //     ChatRoom.shared.chatController.close();
        //     ChatRoom.shared.setChatUserProfileInfoStream();
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => ChatUserProfilePage(
        //           member,
        //           name: member['user_name'],
        //           phone: member['phone'],
        //           email: member['email'],
        //           image: member['avatar_url'] + member['avatar'],
        //         ),
        //       ),
        //     ).whenComplete(
        //       () {
        //         ChatRoom.shared.closeCabinetInfoStream();
        //       },
        //     );
        //   },
        // ),
        CupertinoActionSheetAction(
          child: member['role'] == '$memberRole'
              ? Text('${localization.setAdmin}')
              : member['role'] == '$adminRole'
                  ? Text('${localization.makeMember}')
                  : Text('${localization.error}'),
          onPressed: () {
            // print('${member['role']} $memberRole $adminRole $ownerRole');
            switch (member['role'].toString()) {
              case '$memberRole':
                print('toAdmin');
                ChatRoom.shared
                    .changePrivileges(chatId, member['user_id'], '$adminRole');
                break;
              case '$adminRole':
                print('toMember');
                ChatRoom.shared
                    .changePrivileges(chatId, member['user_id'], '$memberRole');
                break;
              default:
            }
            ChatRoom.shared.chatMembers(widget.chatId);
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          child: Text('${localization.delete}'),
          onPressed: () {
            setState(() {
              _membersCount -= 1;
            });
            ChatRoom.shared.deleteChatMember(chatId, member['user_id']);
            Navigator.pop(context);
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('${localization.back}'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => act,
    );
  }

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
                    Column(
                      children: [
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
                                Navigator.pop(context, _membersCount);
                              },
                            ),
                            Flexible(
                              child: InkWell(
                                onTap: () {
                                  if (_myPrivilege.toString() == '$ownerRole' &&
                                      widget.chatType != 0) {
                                    setState(() {
                                      _isEditing = !_isEditing;
                                    });
                                  }
                                },
                                child: _isEditing
                                    ? Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: TextField(
                                              textAlign: TextAlign.center,
                                              controller: _chatTitleController,
                                              style: fS26(c: 'ffffff'),
                                              onSubmitted: (value) {
                                                ChatRoom.shared.changeChatName(
                                                    widget.chatId, value);
                                              },
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.edit, color: Colors.white)
                                        ],
                                      )
                                    : FittedBox(
                                        child: Text(
                                          widget.chatName.length > 2
                                              ? '${_chatTitle[0].toUpperCase()}${_chatTitle.substring(1)}'
                                              : '',
                                          style: fS26(c: 'ffffff'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              color: widget.chatType == 1
                                  ? Colors.white
                                  : Colors.transparent,
                              onPressed: () {
                                widget.chatType == 1
                                    ? _addMembers(widget.chatId)
                                    : print(
                                        'Change this action to private functions');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Flexible(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _buildProfileImage(),
                            ],
                          ),
                          SizedBox(height: 10),
                          widget.chatType == 1
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10.0,
                                    left: 10.0,
                                    right: 10,
                                    bottom: 0,
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: blackPurpleColor,
                                      ),
                                      hintText: "${localization.search}",
                                      fillColor: blackPurpleColor,
                                    ),
                                    onChanged: (value) {
                                      ChatRoom.shared.searchChatMembers(
                                          value, '${widget.chatId}');
                                    },
                                    controller: _searchController,
                                  ),
                                )
                              : Container(),
                          widget.chatType == 1
                              ? Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 20),
                                  child: Text(
                                    '${localization.members} $_membersCount',
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
                                    '$_onlineCount ${localization.online}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : Center(),
                          SizedBox(height: 10),
                          _actualMembersList.isEmpty
                              ? Center(
                                  child: Text('${localization.emptyContacts}'))
                              : widget.chatType == 1
                                  ? Flexible(
                                      child: ScrollConfiguration(
                                        behavior: MyBehavior(),
                                        child: SmartRefresher(
                                          enablePullDown: false,
                                          enablePullUp: true,
                                          // header: WaterDropHeader(),
                                          footer: CustomFooter(
                                            builder: (BuildContext context,
                                                LoadStatus mode) {
                                              Widget body;
                                              return Container(
                                                height: 55.0,
                                                child: Center(child: body),
                                              );
                                            },
                                          ),
                                          controller: _refreshController,
                                          onRefresh: _onRefresh,
                                          onLoading: _onLoading,
                                          child: ListView.builder(
                                            itemCount:
                                                _actualMembersList.length,
                                            itemBuilder: (context, i) {
                                              return ListTile(
                                                onTap: () {
                                                  if (_actualMembersList[i]
                                                              ['user_id']
                                                          .toString() ==
                                                      '${user.id}') {
                                                    // print(_actualMembersList[i]
                                                    // ['user_id']
                                                    // .toString() ==
                                                    // '${user.id}');
                                                    // memberAction(actualMembersList[i]);
                                                  } else {
                                                    switch (_myPrivilege
                                                        .toString()) {
                                                      case '$ownerRole':
                                                        print('ownerAction');
                                                        _action(
                                                            widget.chatId,
                                                            _actualMembersList[
                                                                i]);
                                                        break;
                                                      case '$adminRole':
                                                        print('adminAction');
                                                        _adminAction(
                                                            widget.chatId,
                                                            _actualMembersList[
                                                                i]);
                                                        break;
                                                      case '$memberRole':
                                                        print('memberAction');
                                                        _memberAction(
                                                            _actualMembersList[
                                                                i]);
                                                        break;
                                                      default:
                                                    }
                                                  }
                                                  // ChatRoom.shared.checkUserOnline(ids);
                                                  // ChatRoom.shared
                                                  //     .getMessages(actualMembersList[i]['id']);
                                                },
                                                leading: Container(
                                                  height: 42,
                                                  width: 42,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      CircleAvatar(
                                                        backgroundImage: (_actualMembersList[
                                                                            i][
                                                                        "avatar"] ==
                                                                    null ||
                                                                _actualMembersList[
                                                                            i][
                                                                        "avatar"] ==
                                                                    '' ||
                                                                _actualMembersList[
                                                                            i][
                                                                        "avatar"] ==
                                                                    false)
                                                            ? CachedNetworkImageProvider(
                                                                "${_actualMembersList[i]["avatar_url"]}noAvatar.png")
                                                            : CachedNetworkImageProvider(
                                                                '${_actualMembersList[i]["avatar_url"]}${_actualMembersList[i]["avatar"]}'),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(2),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: _actualMembersList[
                                                                              i]
                                                                          [
                                                                          'online'] ==
                                                                      'online'
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .transparent),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: _actualMembersList[i]
                                                                            [
                                                                            'online'] ==
                                                                        'online'
                                                                    ? greenColor
                                                                    : Colors
                                                                        .transparent),
                                                            height: 15,
                                                            width: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                title: Text(
                                                    "${_actualMembersList[i]["user_name"]}"),
                                                subtitle: memberName(
                                                  _actualMembersList[i],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        "${localization.status}",
                                        style: TextStyle(
                                          fontSize: 24,
                                          // fontFamily: ""
                                        ),
                                      ),
                                    ),
                        ],
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
      case '100':
        return Text('${localization.creator}');
        break;
      case '50':
        return Text('${localization.admin}');
        break;
      case '2':
        return Text('${localization.member}');
        break;
      default:
        return Text('');
    }
  }
}
