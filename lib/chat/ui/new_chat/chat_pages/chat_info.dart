import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/wallet/wallet.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/style/fonts.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/full_photo.dart';
import 'package:indigo24/widgets/indigo_search_widget.dart';
import 'package:indigo24/widgets/progress_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../tabs.dart';
import 'chat.dart';
import 'chat_members_selection.dart';

class ChatProfileInfo extends StatefulWidget {
  final chatName;
  final chatAvatar;
  final chatId;
  final chatType;
  final memberCount;
  final phone;
  final userId;
  ChatProfileInfo({
    this.chatType,
    this.phone,
    this.chatId,
    this.chatName,
    this.chatAvatar,
    this.memberCount,
    this.userId,
  });
  @override
  _ChatProfileInfoState createState() => _ChatProfileInfoState();
}

class _ChatProfileInfoState extends State<ChatProfileInfo>
    with SingleTickerProviderStateMixin {
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
  TabController _tabController;

  RefreshController _refreshController;
  String chatAvatar;
  bool loaderCheck = true;
  dynamic _member;

  @override
  void initState() {
    if (widget.chatAvatar != null && '${widget.chatAvatar}' != '')
      chatAvatar = widget.chatAvatar;
    _isEditing = false;

    _chatMembersPage = 1;
    _onlineCount = 0;

    _myPrivilege = '';

    _membersList = [];
    _actualMembersList = [];

    _picker = ImagePicker();
    _tabController = TabController(length: 4, vsync: this);

    _chatTitleController = TextEditingController();
    _searchController = TextEditingController();
    _refreshController = RefreshController(initialRefresh: false);
    _membersCount = 0;
    // _membersCount = widget.memberCount;

    _chatTitle = '${widget.chatName}';

    _listen();
    if (widget.chatId != null) {
      ChatRoom.shared.chatMembers(widget.chatId, page: _chatMembersPage);
    } else if (widget.chatType == 0) {
      ChatRoom.shared.userCheckById(widget.userId);
    }
    if (widget.chatName.length > 2) {
      _chatTitleController.text =
          '${_chatTitle[0].toUpperCase()}${_chatTitle.substring(1)}';
    }
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    await subscription.cancel();
  }

  StreamSubscription subscription;

  _listen() {
    subscription = ChatRoom.shared.onChatInfoChange.listen((e) {});
    subscription.onData((e) {
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
                _actualMembersList.addAll(message);
              }
              if (_membersList.isNotEmpty) {
                _membersList.forEach((member) {
                  if (member['user_id'].toString() == '${user.id}') {
                    _myPrivilege = member['role'].toString();
                    _member = member;
                  }
                  if (member['online'] == 'online') {
                    _onlineCount++;
                  }
                });
              }
            });
            break;
          case "chat:members:privileges":
            _actualMembersList.forEach((element) {
              message['users'].forEach((messageELement) {
                if ('${element['user_id']}' == '${messageELement['user_id']}') {
                  setState(() {
                    element['role'] = '${messageELement['role']}';
                  });
                }
              });
            });
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
          case "chat:create":
            if (e.json["data"]["status"].toString() == "true") {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    chatName: '${e.json['data']['chat_name']}',
                    chatId: int.parse(e.json['data']['chat_id'].toString()),
                    chatType: 0,
                  ),
                ),
              ).whenComplete(() {
                // this is bool for check load more is needed or not
                ChatRoom.shared.forceGetChat();
              });
            } else {
              // ChatRoom.shared.setChatStream();
              var name = e.json["data"]["name"];
              var chatID = e.json["data"]["chat_id"];
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    chatName: name,
                    chatId: int.parse(
                      chatID.toString(),
                    ),
                  ),
                ),
              ).whenComplete(() {
                ChatRoom.shared.forceGetChat();
              });
            }
            break;
          case "chat:member:leave":
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Tabs()), (r) => false);
            break;
          case "check:user:id":
            if (e.json['data']['chat_id'].toString() != 'false' &&
                e.json['data']['status'].toString() == 'true') {
              // ChatRoom.shared.setChatStream();
              if (loaderCheck == false) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      chatName: '${e.json['data']['name']}',
                      chatId: int.parse(e.json['data']['chat_id'].toString()),
                      chatType: 0,
                      avatar: '${e.json['data']['avatar']}',
                    ),
                  ),
                ).whenComplete(() {});
                loaderCheck = false;
              } else {
                setState(() {
                  _member = e.json['data'];
                });
              }
            } else if (e.json['data']['status'].toString() == 'true') {
              if (loaderCheck == false) {
                ChatRoom.shared
                    .cabinetCreate("${e.json['data']['user_id']}", 0);
              } else {}
            }
            break;
          default:
        }
      }
    });
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (_actualMembersList.length % 20 == 0) {
      _chatMembersPage++;
      if (mounted)
        setState(() {
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
        },
        onReceiveProgress: (count, total) {
          setState(() {
            isUploading = false;
            uploadPercent = 0.0;
            percent = "0 %";
          });
        },
      );

      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
      } else {}
    }
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
      setState(() {
        _image = compressedImage;
        // _image = File(pickedFile.path);
      });
      if (_image != null) {
        uploadAvatar(_image.path).then((r) async {
          if (r['message'] == 'Not authenticated' &&
              r['success'].toString() == 'false') {
            logOut(context);
            return r;
          } else {
            if (r["success"]) {
              ChatRoom.shared.setGroupAvatar(
                  int.parse(widget.chatId.toString()), r["file_name"]);
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                    description: "${r["message"]}",
                    yesCallBack: () {
                      Navigator.pop(context);
                    },
                  );
                },
              );
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

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullPhoto(
                    url:
                        "$avatarUrl${chatAvatar.toString().replaceAll('AxB', '200x200')}"),
              ),
            );
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
          if (widget.chatType == 0) {
            newAction(member: _member, chatId: widget.chatId);
          }
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
                child: CachedNetworkImage(
                  errorWidget: (context, url, error) => Material(
                    child: Image.network(
                      '${avatarUrl}noAvatar.png',
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                  imageUrl: chatAvatar != null
                      ? '$avatarUrl${widget.chatAvatar.replaceAll('AxB', '200x200')}'
                      : '${avatarUrl}noAvatar.png',
                ),
              ),
            ),
          ),
        ),
      ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatMembersSelection(chatId, _membersList),
                      ),
                    ).whenComplete(() {
                      ChatRoom.shared.chatMembers(widget.chatId);
                    });
                  },
                )
              : Container(),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: Text('${localization.exitGroup}'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                    description: "${localization.sureExitGroup}",
                    yesCallBack: () {
                      Navigator.pop(context);
                      ChatRoom.shared.leaveChat(widget.chatId);
                    },
                    noCallBack: () {
                      Navigator.pop(context);
                    },
                  );
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
                                      bottom: 0),
                                  child: IndigoSearchWidget(
                                    onChangeCallback: (value) {
                                      ChatRoom.shared.searchChatMembers(
                                          value, '${widget.chatId}');
                                    },
                                    searchController: _searchController,
                                  ),
                                )
                              : Container(),
                          // widget.chatType == 1
                          //     ? Container(
                          //         alignment: Alignment.centerLeft,
                          //         margin: EdgeInsets.only(left: 20),
                          //         child: Text(
                          //           '${localization.members} $_membersCount',
                          //           style: TextStyle(
                          //             fontSize: 18,
                          //             fontWeight: FontWeight.w500,
                          //           ),
                          //         ),
                          //       )
                          //     : Container(),
                          // widget.chatType == 1
                          //     ? Container(
                          //         alignment: Alignment.centerLeft,
                          //         margin: EdgeInsets.only(left: 20),
                          //         child: Text(
                          //           '$_onlineCount ${localization.online}',
                          //           style: TextStyle(
                          //             fontSize: 14,
                          //             fontWeight: FontWeight.w500,
                          //           ),
                          //         ),
                          //       )
                          //     : Center(),
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
                              : SizedBox(
                                  height: 0,
                                  width: 0,
                                ),
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
                                            itemBuilder: (ContextAction, i) {
                                              return ListTile(
                                                onTap: () {
                                                  if (_actualMembersList[i]
                                                              ['user_id']
                                                          .toString() ==
                                                      '${user.id}') {
                                                    // ['user_id']
                                                    // .toString() ==
                                                    // '${user.id}');
                                                    // memberAction(actualMembersList[i]);
                                                  } else {
                                                    newAction(
                                                      myPrivilege: _myPrivilege,
                                                      member:
                                                          _actualMembersList[i],
                                                      chatId: widget.chatId,
                                                    );
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
                                  : Text('status')
                          // : Flexible(
                          //     child: Stack(
                          //       children: [
                          //         TabBar(
                          //           controller: _tabController,
                          //           tabs: [
                          //             Tab(
                          //               text: 'media',
                          //             ),
                          //             Tab(
                          //               text: 'file',
                          //             ),
                          //             Tab(
                          //               text: 'link',
                          //             ),
                          //             Tab(
                          //               text: 'audio',
                          //             ),
                          //           ],
                          //         ),
                          //         Container(
                          //           margin: EdgeInsets.only(top: 45),
                          //           child: Container(
                          //             color: greenColor,
                          //             child: Flexible(
                          //               child: Column(
                          //                 children: <Widget>[
                          //                   Expanded(
                          //                     child: TabBarView(
                          //                       controller:
                          //                           _tabController,
                          //                       children: [
                          //                         MediaTab(),
                          //                         FileTab(
                          //                           chatId:
                          //                               widget.chatId,
                          //                         ),
                          //                         LinkTab(),
                          //                         AudioTab()
                          //                       ],
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
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

  newAction({String myPrivilege, dynamic member, dynamic chatId}) {
    print(member);
    List<Widget> actions = [
      CupertinoActionSheetAction(
        child: Text('${localization.watch}'),
        onPressed: () {
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullPhoto(
                url:
                    "$avatarUrl${member['avatar'].toString().replaceAll('AxB', '200x200')}",
              ),
            ),
          );
        },
      ),
      CupertinoActionSheetAction(
        child: Text('${localization.goToChat}'),
        onPressed: () {
          loaderCheck = false;
          ChatRoom.shared.userCheckById(member['user_id']);
          Navigator.pop(context);
        },
      ),
    ];

    List<Widget> ownerActions = [
      CupertinoActionSheetAction(
        child: member['role'] == '$memberRole'
            ? Text('${localization.setAdmin}')
            : member['role'] == '$adminRole'
                ? Text('${localization.makeMember}')
                : Text('${localization.error}'),
        onPressed: () {
          switch (member['role'].toString()) {
            case '$memberRole':
              ChatRoom.shared.changePrivileges(
                  chatId,
                  [int.parse(member['user_id'].toString())],
                  int.parse(adminRole));
              break;
            case '$adminRole':
              ChatRoom.shared.changePrivileges(
                  chatId,
                  [int.parse(member['user_id'].toString())],
                  int.parse(memberRole));
              break;
            default:
          }
          // ChatRoom.shared.chatMembers(widget.chatId);
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
          ChatRoom.shared.chatMembers(widget.chatId);
          Navigator.pop(context);
        },
      )
    ];

    List<Widget> adminActions = [
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
    ];

    switch (myPrivilege) {
      case '$ownerRole':
        actions.addAll(ownerActions);
        break;
      case '$adminRole':
        actions.addAll(adminActions);
        break;
      case '$memberRole':
        break;
      default:
    }
    final act = CupertinoActionSheet(
      title: Text('${localization.selectOption}'),
      actions: actions,
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

class MediaTab extends StatefulWidget {
  @override
  _MediaTabState createState() => _MediaTabState();
}

class _MediaTabState extends State<MediaTab> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(10, (index) {
        return Center(
          child: Text(
            'Item $index',
            style: Theme.of(context).textTheme.headline5,
          ),
        );
      }),
    );
  }
}

class FileTab extends StatefulWidget {
  final int chatId;

  const FileTab({Key key, this.chatId}) : super(key: key);
  @override
  _FileTabState createState() => _FileTabState();
}

class _FileTabState extends State<FileTab> {
  String type = 'files';
  @override
  void initState() {
    ChatRoom.shared.getMessagesByType(widget.chatId, type);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${[index]}'),
        );
      },
    );
  }
}

class LinkTab extends StatefulWidget {
  @override
  _LinkTabState createState() => _LinkTabState();
}

class _LinkTabState extends State<LinkTab> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${[index]}'),
        );
      },
    );
  }
}

class AudioTab extends StatefulWidget {
  @override
  _AudioTabState createState() => _AudioTabState();
}

class _AudioTabState extends State<AudioTab> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${[index]}'),
        );
      },
    );
  }
}
