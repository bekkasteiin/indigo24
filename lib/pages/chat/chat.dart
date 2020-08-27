import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/main.dart';
import 'package:indigo24/pages/chat/chat_info.dart';
import 'package:indigo24/pages/chat/ui/received.dart';
import 'package:indigo24/pages/chat/ui/replyMessage.dart';
import 'package:indigo24/pages/chat/ui/sended.dart';
import 'package:indigo24/pages/wallet/transfers/transfer.dart';
import 'package:indigo24/services/test_timer.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/keyboard_dismisser.dart';
import 'package:indigo24/widgets/photo.dart';
import 'package:indigo24/widgets/player.dart';
import 'package:indigo24/widgets/preview.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vibration/vibration.dart';
import 'chat_page_view_test.dart';
import 'package:indigo24/services/localization.dart' as localization;

import 'ui/chats_list_draggable.dart';

List listMessages = [];
bool showForwardingProcess;

class ChatPage extends StatefulWidget {
  final members;
  final name;
  final chatID;
  final memberCount;
  final userIds;
  final avatar;
  final avatarUrl;
  final chatType;
  final phone;
  final List data;
  ChatPage(
    this.name,
    this.chatID, {
    this.members,
    this.chatType,
    this.memberCount,
    this.userIds,
    this.avatar,
    this.avatarUrl,
    this.phone,
    this.data,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

int messagesPage;

class _ChatPageState extends State<ChatPage> {
  List toForwardMessages = [];

  Dependencies _dependencies = Dependencies();
  List _myList = [];
  List _temp;
  int _lastMessageTime;
  TextEditingController _text = TextEditingController();
  var _online;
  ScrollController _scrollController;
  bool _isTyping = false;
  bool _isRecording = false;
  Api _api = Api();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool _isEditing = false;
  var _editMessage;
  bool _isReplying = false;
  var _replyMessage;
  String _recordFilePath;

  String _fileName;
  String _path;
  Map<String, String> _paths;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.custom;
  bool _isSomeoneTyping = false;
  List _typingMembers = [];
  List _typingName = [];
  bool _isGroup;
  RefreshController _memberRefreshController =
      RefreshController(initialRefresh: false);
  ItemScrollController _itemScrollController = ItemScrollController();
  int _chatMembersPage = 1;
  int _membersCount;
  bool _isUploaded = false;
  int _onlineCount = 0;
  File _image;
  bool messageFinding = false;
  ImagePicker _picker = ImagePicker();
  @override
  initState() {
    showForwardingProcess = false;
    listMessages = [];
    messagesPage = 1;
    _isGroup = widget.chatType.toString() == '1';
    _membersCount = widget.memberCount;

    _scrollController = new ScrollController()..addListener(_scrollListener);
    super.initState();
    ChatRoom.shared.chatMembers(widget.chatID);

    ChatRoom.shared.checkUserOnline(widget.userIds);
    if (widget.data != null) {
      ChatRoom.shared.forwardMessage(widget.data.join(','), '', widget.chatID);
    }
    _listen();
  }

  @override
  void dispose() {
    // ChatRoom.shared.chatController.close();
    _scrollController.removeListener(_scrollListener);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
    audioPlayers = [];
  }

  bool isLoading = false;
  getDateFromUnix(unix) {
    return DateTime.fromMillisecondsSinceEpoch(
        int.parse(unix.toString()) * 1000);
  }

  buildMessage(index) {
    if (_myList[index]['time'].toString() != '') {
      if (_myList[index]['time'].toString() == '1') {
        return SizedBox(height: 0, width: 0);
      } else {
        if (index == 0) {
          _lastMessageTime = int.parse(_myList[0]['time'].toString());
        }
        DateTime actualUnixDate = getDateFromUnix(_myList[index]['time']);

        DateTime lastUnixDate = getDateFromUnix(
          _lastMessageTime == null ? _myList[index]['time'] : _lastMessageTime,
        );

        int differenceInDays = lastUnixDate.difference(actualUnixDate).inDays;
        _lastMessageTime = int.parse(_myList[index]['time'].toString());
        if (differenceInDays != 0) {
          return Column(
            children: <Widget>[
              temp(_myList[index]),
              lastUnixDate.difference(DateTime.now()).inDays == 0
                  ? Devider({'text': '${localization.today}'})
                  : Devider({
                      'text':
                          '$lastUnixDate'.substring(0, 10).replaceAll('-', '.')
                    }),
            ],
          );
        } else {
          return temp(
            _myList[index],
          );
        }
      }
    } else {
      return SizedBox(height: 0, width: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: [
        GestureType.onTap,
        GestureType.onPanUpdateDownDirection,
      ],
      child: GestureDetector(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(10),
                child: Image(
                  image: AssetImage(
                    'assets/images/back.png',
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: InkWell(
              child: Column(
                children: <Widget>[
                  Text(
                    widget.name.length != 0
                        ? "${widget.name[0].toUpperCase() + widget.name.substring(1)}"
                        : "",
                    style: TextStyle(
                        color: blackPurpleColor, fontWeight: FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                  ),
                  _isSomeoneTyping
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${_typingName.join(' ')} ",
                              style: TextStyle(
                                color: blackPurpleColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Image.asset(
                              "assets/typing.gif",
                              width: 20,
                            )
                          ],
                        )
                      : (widget.chatType.toString() == '1')
                          ? Column(
                              children: <Widget>[
                                Text(
                                  '${localization.members} ${_membersCount}',
                                  style: TextStyle(
                                      color: blackPurpleColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  '${localization.online} $_onlineCount',
                                  style: TextStyle(
                                      color: blackPurpleColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            )
                          : _online == null
                              ? Container()
                              : Text(
                                  ('$_online' == 'online' ||
                                          '$_online' == 'offline')
                                      ? '$_online'
                                      : '${localization.lastSeen} $_online',
                                  style: TextStyle(
                                      color: blackPurpleColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                ],
              ),
              onTap: () async {
                ChatRoom.shared.setChatInfoStream();
                var chatProfileResult = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatProfileInfo(
                      chatType: widget.chatType,
                      chatName: widget.name,
                      memberCount: _membersCount,
                      phone: widget.phone,
                      chatAvatar: widget.avatar == null
                          ? 'noAvatar.png'
                          : widget.avatar,
                      chatId: widget.chatID,
                    ),
                  ),
                ).whenComplete(() {
                  setState(() {
                    ChatRoom.shared.setChatStream();
                    ChatRoom.shared.getMessages(widget.chatID);
                  });
                });
                if (chatProfileResult != null) {
                  setState(() {
                    _membersCount = chatProfileResult;
                  });
                }
              },
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 0,
                color: Colors.transparent,
                textColor: Colors.white,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    color: greyColor,
                    child: ClipOval(
                        child: Image.network(
                      '${widget.chatType.toString() == '1' ? groupAvatarUrl : widget.avatarUrl}${(widget.avatar == '' || widget.avatar == null) ? "noAvatar.png" : widget.avatar.toString().replaceAll('AxB', '200x200')}',
                      width: 35,
                      height: 35,
                    )),
                  ),
                ),
                shape: CircleBorder(),
                onPressed: () {
                  // ChatRoom.shared.chatController.close();
                  ChatRoom.shared.setChatInfoStream();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenWrapper(
                          imageProvider: CachedNetworkImageProvider(
                              "${widget.avatarUrl}${widget.avatar.toString().replaceAll('AxB', '200x200')}"),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.contained * 3,
                          backgroundDecoration:
                              BoxDecoration(color: Colors.transparent),
                        ),
                      )).whenComplete(() {
                    ChatRoom.shared.setChatStream();
                    ChatRoom.shared.getMessages(widget.chatID);

                    setState(() {});
                  });
                },
              ),
            ],
            backgroundColor: Colors.white,
            brightness: Brightness.light,
          ),
          body: SafeArea(
            child: Container(
              child: Stack(
                fit: StackFit.loose,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Image(
                      image: user.chatBackground == 'ligth'
                          ? AssetImage("assets/images/background_chat.png")
                          : AssetImage("assets/images/background_chat_2.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(
                        height: 0,
                        color: Colors.black54,
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          child: Container(
                            child: _myList.isEmpty
                                ? Center()
                                : Column(
                                    children: [
                                      Expanded(
                                          child: NotificationListener<
                                              ScrollNotification>(
                                        onNotification:
                                            (ScrollNotification scrollInfo) {
                                          if (!isLoading &&
                                              scrollInfo.metrics.pixels ==
                                                  scrollInfo.metrics
                                                      .maxScrollExtent) {
                                            _loadData();
                                            setState(() {
                                              isLoading = true;
                                            });
                                          }
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Flexible(
                                              child: ScrollablePositionedList
                                                  .builder(
                                                itemScrollController:
                                                    _itemScrollController,
                                                itemCount: _myList.length,
                                                reverse: true,
                                                itemBuilder: (context, index) {
                                                  return buildMessage(index);
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                          ],
                                        ),
                                      )

                                          // ListView.builder(
                                          //   itemCount: _myList.length,
                                          //   reverse: true,
                                          //   itemBuilder: (context, index) {
                                          //     return _message(_myList[index]);
                                          //   },
                                          // ),
                                          ),
                                      // Expanded(
                                      //   child: SmartRefresher(
                                      //     enablePullDown: false,
                                      //     enablePullUp: true,
                                      //     // header: WaterDropHeader(),
                                      //     footer: CustomFooter(
                                      //       builder: (BuildContext context,
                                      //           LoadStatus mode) {
                                      //         Widget body;
                                      //         return Container(
                                      //           height: 55.0,
                                      //           child: Center(child: body),
                                      //         );
                                      //       },
                                      //     ),
                                      //     controller: _refreshController,
                                      //     onRefresh: _onRefresh,
                                      //     onLoading: _onLoading,
                                      //     child: ListView.builder(
                                      //       controller: _scrollController,
                                      //       // itemScrollController: itemScrollController,
                                      //       // itemPositionsListener: itemPositionsListener,
                                      //       itemCount: _myList.length,
                                      //       reverse: true,
                                      //       itemBuilder: (context, i) {
                                      //         return _message(_myList[i]);
                                      //       },
                                      //     ),
                                      //   ),
                                      // ),
                                      _isEditing
                                          ? Container(
                                              height: 50,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: Colors.white,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        IconButton(
                                                            icon: Icon(
                                                                Icons.edit,
                                                                color: Colors
                                                                    .transparent),
                                                            onPressed: null),
                                                        Container(
                                                            width: 2.5,
                                                            height: 45,
                                                            color:
                                                                primaryColor),
                                                        Container(width: 5),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Flexible(
                                                                  child: Container(
                                                                      child: Text(
                                                                          "${localization.edit}",
                                                                          style: TextStyle(
                                                                              color:
                                                                                  primaryColor),
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          softWrap:
                                                                              false))),
                                                              Flexible(
                                                                  child: Container(
                                                                      child: Text(
                                                                          "${_editMessage["text"]}",
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          softWrap:
                                                                              false)))
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: IconButton(
                                                      icon: Icon(Icons.close),
                                                      onPressed: () {
                                                        setState(() {
                                                          _isEditing = false;
                                                          _editMessage = null;
                                                          _text.text = "";
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      _isReplying
                                          ? Container(
                                              height: 50,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: Colors.white,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        IconButton(
                                                            icon: Icon(
                                                                Icons.edit,
                                                                color: Colors
                                                                    .transparent),
                                                            onPressed: null),
                                                        Container(
                                                            width: 2.5,
                                                            height: 45,
                                                            color:
                                                                primaryColor),
                                                        Container(width: 5),
                                                        _replyMessage[
                                                                    "attachment_url"] !=
                                                                null
                                                            ? Container(
                                                                width: 40,
                                                                height: 40,
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      "${_replyMessage["attachment_url"]}${json.decode(_replyMessage["attachments"])[0]["r_filename"]}",
                                                                ),
                                                              )
                                                            : Container(),
                                                        Container(width: 5),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Flexible(
                                                                  child: Container(
                                                                      child: Text(
                                                                          "${_replyMessage["user_name"]}",
                                                                          style: TextStyle(
                                                                              color:
                                                                                  primaryColor),
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          softWrap:
                                                                              false))),
                                                              Flexible(
                                                                  child: Container(
                                                                      child: Text(
                                                                          "${_replyMessage["type"].toString() == '1' ? "Изображение" : _replyMessage["type"].toString() == '4' ? "Видео" : _replyMessage["text"]}",
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          softWrap:
                                                                              false)))
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: IconButton(
                                                      icon: Icon(Icons.close),
                                                      onPressed: () {
                                                        setState(() {
                                                          _isReplying = false;
                                                          _replyMessage = null;
                                                          _text.text = "";
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      Divider(height: 0, color: Colors.black26),
                      // SizedBox(
                      //   height: 50,
                      Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Column(
                            children: <Widget>[
                              showForwardingProcess
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.cancel),
                                          onPressed: () {
                                            print("cancelling forward");
                                            setState(() {
                                              showForwardingProcess = false;
                                              toForwardMessages.clear();
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.reply_all),
                                          onPressed: () {
                                            setState(() {
                                              showForwardingProcess = false;
                                            });
                                            print('going to reply');
                                            ChatRoom.shared
                                                .setChatsListDialogStream();

                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                fullscreenDialog: true,
                                                builder: (context) =>
                                                    ChatListDraggablePage(
                                                        messages:
                                                            toForwardMessages),
                                              ),
                                            ).whenComplete(() {
                                              ChatRoom.shared
                                                  .closeChatsListDialogStream();
                                              ChatRoom.shared.setChatStream();
                                              ChatRoom.shared
                                                  .getMessages(widget.chatID);
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        // isComplete
                                        //     ? GestureDetector(
                                        //         onTap: () {
                                        //           play();
                                        //         },
                                        //         child: Center(
                                        //           child: Icon(
                                        //             Icons.play_arrow,
                                        //             size: 30,
                                        //           ),
                                        //         ),
                                        //       )
                                        //     :
                                        IconButton(
                                          icon: Icon(Icons.attach_file),
                                          onPressed: () {
                                            print("Прикрепить");

                                            FocusScopeNode currentFocus =
                                                FocusScope.of(context);
                                            if (!currentFocus.hasPrimaryFocus) {
                                              currentFocus.unfocus();
                                            }
                                            _showAttachmentBottomSheet(context);
                                          },
                                        ),
                                        !_isRecording
                                            ? Flexible(
                                                child: TextField(
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  maxLines: 6,
                                                  minLines: 1,
                                                  controller: _text,
                                                  onChanged: (value) {
                                                    print("Typing: $value");
                                                    if (value == '') {
                                                      setState(() {
                                                        _isTyping = false;
                                                      });
                                                    } else {
                                                      ChatRoom.shared.typing(
                                                          widget.chatID);
                                                      setState(() {
                                                        _isTyping = true;
                                                      });
                                                    }
                                                  },
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Image.asset(
                                                      "assets/record.gif",
                                                      width: 10,
                                                      height: 10),
                                                  Container(width: 5),
                                                  TimerText(
                                                      dependencies:
                                                          _dependencies),
                                                ],
                                              ),
                                        !_isTyping
                                            ? ClipOval(
                                                child: GestureDetector(
                                                  onLongPress: () async {
                                                    print("long press");
                                                    bool p =
                                                        await _checkPermission();
                                                    if (p) {
                                                      _startRecord();
                                                    }
                                                  },
                                                  onLongPressUp: () {
                                                    print("long press UP");
                                                    _stopRecord();
                                                  },
                                                  // onTap: () {
                                                  //   startRecord();
                                                  // },
                                                  // onDoubleTap: () {
                                                  //   stopRecord();
                                                  // },
                                                  child: Center(
                                                      child: !_isRecording
                                                          ? Container(
                                                              height: 50,
                                                              width: 50,
                                                              child: Icon(
                                                                Icons.mic,
                                                                size: 50,
                                                              ),
                                                            )
                                                          : Container()),
                                                ),
                                              )

                                            // IconButton(
                                            //   icon: Icon(Icons.mic),
                                            //   onPressed: () {
                                            //     print("audio pressed");
                                            //   },
                                            // )
                                            : Container(
                                                height: 50,
                                                width: 50,
                                                child: IconButton(
                                                  icon: Icon(Icons.send),
                                                  onPressed: () {
                                                    print(
                                                        "new message or editing? editing: $_isEditing");
                                                    if (_isEditing) {
                                                      print(
                                                          "Edit message is called");
                                                      var mId = _editMessage[
                                                                  'id'] ==
                                                              null
                                                          ? _editMessage[
                                                              'message_id']
                                                          : _editMessage['id'];
                                                      var type =
                                                          _editMessage['type'];
                                                      var time =
                                                          _editMessage['time'];
                                                      ChatRoom.shared
                                                          .editMessage(
                                                              _text.text,
                                                              widget.chatID,
                                                              type,
                                                              time,
                                                              mId);
                                                      setState(() {
                                                        _isTyping = false;
                                                        _text.text = '';
                                                        _isEditing = false;
                                                        _editMessage = null;
                                                      });
                                                    } else if (_isReplying) {
                                                      print(
                                                          "Reply message is called");
                                                      var mId = _replyMessage[
                                                                  'id'] ==
                                                              null
                                                          ? _replyMessage[
                                                              'message_id']
                                                          : _replyMessage['id'];
                                                      ChatRoom.shared
                                                          .replyMessage(
                                                              _text.text,
                                                              widget.chatID,
                                                              10,
                                                              mId);
                                                      setState(() {
                                                        _isTyping = false;
                                                        _text.text = '';
                                                        _isReplying = false;
                                                        _replyMessage = null;
                                                      });
                                                    } else {
                                                      ChatRoom.shared
                                                          .sendMessage(
                                                              '${widget.chatID}',
                                                              _text.text);
                                                      setState(() {
                                                        _isTyping = false;
                                                        _text.text = '';
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  _isRecording
                      ? Positioned.fill(
                          // top: 100,
                          left: MediaQuery.of(context).size.width * 0.8,
                          child: Image.asset(
                            "assets/voice.gif",
                            // fit: BoxFit.fitWidth,
                            width: 100,
                            height: 100,
                            alignment: Alignment.bottomCenter,
                          ),
                        )
                      : Container(),
                  // Container(
                  //   width: 200,
                  //   height: 200,
                  //   margin: EdgeInsets.only(
                  //     left:MediaQuery.of(context).size.width*0.85,
                  //     top: MediaQuery.of(context).size.height*0.78
                  //   ),
                  //   // alignment: Alignment.bottomRight,
                  //   child: OverflowBox(child: Image.asset("assets/voice.gif", width: 200, height: 200,)),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void sendSound() {
    print("Send sound is called");
    final player = AudioCache();
    player.play("sound/msg_out.mp3");
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    print("_onRefresh ");
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    print("_onLoading ");
    if (mounted)
      setState(() {
        print("mounted ");
        // page += 1;
      });
    _loadData();
    _refreshController.loadComplete();
  }

  void _onMemberRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    print("_onRefresh");
    _refreshController.refreshCompleted();
  }

  void _onMemberLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (_temp.length % 20 == 0) {
      _chatMembersPage++;
      if (mounted)
        setState(() {
          print("_onLoading chat members with page $_chatMembersPage");
          ChatRoom.shared.chatMembers(widget.chatID, page: _chatMembersPage);
        });
      _refreshController.loadComplete();
    }
  }

  _scrollListener() async {
    // print(controller.position.extentAfter);
    // print("${controller.position.extentAfter <= 0 && !isLoaded}");
    // if (controller.position.extentAfter <= 0 && !isLoaded) {
    //   page += 1;
    //   setState(() {
    //     isLoaded = true;
    //   });
    //   await _loadData();
    // }
  }

  _listen() {
    ChatRoom.shared.onChatChange.listen((e) {
      print("CABINET EVENT ${e.json['cmd']}");
      var cmd = e.json['cmd'];
      switch (cmd) {
        case "chat:get":
          if (messagesPage == 1) {
            setState(() {
              print(e.json['data']);
              messagesPage += 1;
              _myList = e.json['data'].toList();
              listMessages = e.json['data'].toList();
            });
          } else {
            print(
                '____________________________________________________________$messagesPage');
            print(e.json['data']);
            if (e.json['data'].isNotEmpty) {
              boolToLoadData = false;
              setState(() {
                messagesPage += 1;
                _myList.addAll(e.json['data'].toList());
                listMessages.addAll(e.json['data'].toList());
              });
            }
            print('this is before finding');
            if (messageFinding) {
              print('this is founded process');
              bool contains = false;
              e.json['data'].forEach((element) {
                contains = false;
                if (element['id'] == replyMessage['message_id']) {
                  contains = true;
                  Future.delayed(Duration(milliseconds: 500)).then((value) {
                    ChatRoom.shared.findMessage(replyMessage);
                  });
                }
              });
              if (!contains) {
                _loadData();
              }
            }

            // int i = e.json['data'].toList().indexWhere(
            //     (e) => e['id'] == null ? e['message_id'] : e['id'] == id);
            // print("index of message is $i");
            // print("index of message is $i");
            // print("index of message is $i");

            // if (i != -1) {}
            // messageFound
            setState(() {
              isLoading = false;
            });
          }
          break;
        case "chat:members":
          print(e.json);
          _temp = [];
          e.json['data'].forEach((memberElement) {
            if (memberElement['online'] == 'online') {
              _onlineCount++;
            }
            myContacts.toList().forEach((element) {
              if ('${element.phone}' == '${memberElement['phone']}') {
                if (!_temp.contains(memberElement)) {
                  print('match ${element.phone}');
                  _temp.add(memberElement);
                }
              }
            });
          });
          break;
        case "message:create":
          var message = e.json['data'];
          if ('${widget.chatID}' == '${e.json['data']['chat_id']}') {
            _lastMessageTime = message['time'];
            if (_isUploaded) {
              setState(() {
                _isUploaded = false;
                _myList.remove(uploadingMessage);
                _myList.insert(0, message);
                listMessages.insert(0, message);
              });
            } else {
              setState(() {
                _myList.insert(0, message);
                listMessages.insert(0, message);
              });
            }
          }
          print("Message created with data $message");
          var senderId = e.json["data"]['user_id'].toString();
          var userId = user.id.toString();
          if ('${e.json['data']['chat_id']}' == '${widget.chatID}' &&
              senderId != userId) {
          } else {
            _itemScrollController.scrollTo(
                index: 0, duration: Duration(milliseconds: 500));
          }
          if (senderId != userId &&
              '${widget.chatID}' != '${e.json['data']['chat_id']}') {
            inAppPush(
              e.json["data"],
            );
          }
          break;
        case "chat:create":
          ChatRoom.shared.getMessages(widget.chatID);
          break;
        case "user:check:online":
          setState(() {
            _online = '${e.json['data'][0]['online']}';
          });
          break;
        case "user:writing":
          print("PRINT PRINT ${e.json['data']}");
          if (e.json['data'][0]['chat_id'].toString() ==
              widget.chatID.toString()) {
            setState(() {
              _typingName = [];
              _typingMembers = e.json['data'].toList();
              if (e.json['data'].toList().length > 0) {
                _typingMembers.forEach((element) {
                  if (_typingName.contains('${element['name']}'))
                    element['name'] = '';
                  if (element['user_id'].toString() != '${user.id}')
                    _typingName.add("${element['name']}");
                });
              }
            });
            if (!_isSomeoneTyping) {
              setState(() {
                _isSomeoneTyping = true;

                _deleteTyping();
              });
            }
          }
          break;
        case "message:deleted:all":
          var mId = e.json['data']['message_id'];
          print("deleting $mId");
          var i = _myList.indexWhere((element) =>
              (element['id'] == null ? element['message_id'] : element['id']) ==
              mId);
          print("deleting ${e.json}");
          setState(() {
            _myList.removeAt(i);
            listMessages.removeAt(i);
          });
          break;
        case "message:edit":
          var mId = e.json['data']['message_id'];
          var i = _myList.indexWhere((element) =>
              (element['id'] == null ? element['message_id'] : element['id']) ==
              mId);
          print("editing ${e.json}");
          setState(() {
            _myList[i] = e.json['data'];
            listMessages[i] = e.json['data'];
          });
          break;
        case "editMessage":
          _text.text = e.json['text'];
          setState(() {
            _isEditing = true;
            _editMessage = e.json['message'];
          });
          break;
        case "replyMessage":
          setState(() {
            _isReplying = true;
            _replyMessage = e.json['message'];
          });
          break;
        case "findMessage":
          messageFinding = true;

          print("Scrolling to ${e.json['index']['message_id']}");
          // while(_myLis
          var id = e.json['index']['message_id'];

          int i = _myList.indexWhere((e) {
            return e['id'] == id;
          });

          if (i != -1) {
            messageFinding = false;

            setState(() {
              _itemScrollController.scrollTo(
                  index: i, duration: Duration(milliseconds: 500));
            });
          } else {
            _loadData();
          }

          break;
        case "message:write":
          print('message read');
          var i = _myList.indexWhere((element) {
            print(_myList[0]['message_id']);
            return element['message_id'] == e.json['data']['message_id'];
          });

          setState(() {
            _myList[i]['write'] = '1';
          });
          break;
        case "forwardMessage":
          setState(() {
            showForwardingProcess = true;
            print('add to forward is ${e.json}');
            print('add to forward is ${e.json}');
            print('add to forward is ${e.json}');
            print('add to forward is ${e.json}');
            toForwardMessages.add(e.json['id']);
          });
          break;
        default:
          print('CABINET EVENT DEFAULT');
      }
    });
  }

  _deleteTyping() async {
    await Future.delayed(Duration(seconds: 3)).then((value) {
      setState(() {
        _isSomeoneTyping = false;
      });
    });
  }

  bool boolToLoadData = false;
  Future _loadData() async {
    print("load more with page $messagesPage");
    if (!boolToLoadData) {
      boolToLoadData = true;
      print('getting message');
      setState(() {
        ChatRoom.shared.getMessages(widget.chatID, page: messagesPage);
      });
    } else {
      print('not getting message');
    }
  }

  var uploadingMessage = json.decode(
      json.encode({"type": "uploading", "time": "1", "user_id": user.id}));

  Future _getImage(ImageSource imageSource) async {
    final pickedFile = await _picker.getImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      print(_image);
      final popResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewMedia(
            filePath: pickedFile.path,
          ),
        ),
      ).whenComplete(() {});

      if (popResult['cmd'] == "sending") {
        setState(() {
          uploadingImage = _image;
          _myList.insert(0, uploadingMessage);
        });

        _api.uploadMedia(_image.path, 1).then((r) async {
          print("RRR $r");
          if (r["status"]) {
            var a = [
              {
                "filename": "${r["file_name"]}",
                "r_filename": "${r["resize_file_name"]}"
              }
            ];
            setState(() {
              _isUploaded = true;
            });
            ChatRoom.shared.sendMessage(
                '${widget.chatID}', "${popResult['text']}",
                type: 1, attachments: jsonDecode(jsonEncode(a)));
          } else {
            _showAlertDialog(context, r["message"]);
            print("error");
          }
        });
      }
    }
  }

  Future _getVideo(ImageSource imageSource) async {
    final pickedFile = await _picker.getVideo(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      print(_image);

      final popResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewMedia(
            filePath: pickedFile.path,
            type: 'video',
          ),
        ),
      ).whenComplete(() {});

      if (popResult['cmd'] == "sending") {
        setState(() {
          _myList.insert(0, uploadingMessage);
        });

        _api.uploadMedia(_image.path, 4).then((r) async {
          print("RRR $r");
          if (r["status"]) {
            var a = [
              {"filename": "${r["file_name"]}"}
            ];
            setState(() {
              _isUploaded = true;
            });
            ChatRoom.shared.sendMessage(
                '${widget.chatID}', "${popResult['text']}",
                type: 4, attachments: jsonDecode(jsonEncode(a)));
          } else {
            _showAlertDialog(context, r["message"]);
            print("error");
          }
        });
      }
    }
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      if (_multiPick) {
        _path = null;
        _paths = await FilePicker.getMultiFilePath(
          type: _pickingType,
          allowedExtensions: ['jpg', 'pdf', 'doc'],
        );
      } else {
        _paths = null;
        _path = await FilePicker.getFilePath(
          type: _pickingType,
          allowedExtensions: ['jpg', 'pdf', 'doc'],
        );

        print(_path);
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName = _path != null
          ? _path.split('/').last
          : _paths != null ? _paths.keys.toString() : '...';

      print("path name $_path");
    });
    if ('$_path' != 'null') {
      _api.uploadMedia(_path, 2).then((r) async {
        print("RRR ${r["message"]}");
        if (r["status"]) {
          var a = [
            {
              "filename": "${r["file_name"]}",
            }
          ];
          ChatRoom.shared.sendMessage('${widget.chatID}', "file",
              type: 2,
              fileId: r["file_id"],
              attachments: jsonDecode(jsonEncode(a)));
        } else {
          _showAlertDialog(context, r["message"]);
          print("error");
        }
      });
    }
  }

  _galleryActions() {
    final act = CupertinoActionSheet(
      title: Text('${localization.selectOption}'),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('${localization.photo}'),
          onPressed: () async {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            Navigator.pop(context);
            _getImage(ImageSource.gallery);
            print('Камера');
          },
        ),
        CupertinoActionSheetAction(
          child: Text('${localization.video}'),
          onPressed: () async {
            _getVideo(ImageSource.gallery);
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

  _cameraActions() {
    final act = CupertinoActionSheet(
      title: Text('${localization.selectOption}'),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('${localization.photo}'),
          onPressed: () async {
            Navigator.pop(context);
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            Navigator.pop(context);
            _getImage(ImageSource.camera);
            print('Камера');
          },
        ),
        CupertinoActionSheetAction(
          child: Text('${localization.video}'),
          onPressed: () async {
            _getVideo(ImageSource.camera);
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

  _showAttachmentBottomSheet(context) {
    showModalBottomSheet(
        barrierColor: Colors.white.withOpacity(0),
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: InkWell(
              onTap: () {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                Navigator.of(context).pop();
              },
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.only(bottom: 48),
                  margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                    ),
                    child: Container(
                      color: Colors.white.withOpacity(0.9),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            height: 50,
                            child: Theme(
                              data: ThemeData(),
                              child: FlatButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 40,
                                      height: 40,
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/cameraPurple.png',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        '${localization.camera}',
                                        style: TextStyle(
                                          color: blackPurpleColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _cameraActions();
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            child: Theme(
                              data: ThemeData(),
                              child: FlatButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 40,
                                      height: 40,
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/money.png',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        '${localization.money}',
                                        style: TextStyle(
                                          color: blackPurpleColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  print('Деньги');
                                  Navigator.pop(context);
                                  print("${widget.phone}");
                                  widget.chatType == 0
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TransferPage(
                                              phone: '${widget.phone}',
                                              transferChat: '${widget.chatID}',
                                            ),
                                          ),
                                        )
                                      : _showBottomModalSheet(context);
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            child: Theme(
                              data: ThemeData(),
                              child: FlatButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 40,
                                      height: 40,
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/gallery.png',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        '${localization.gallery}',
                                        style: TextStyle(
                                          color: blackPurpleColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  print('Галерея');
                                  Navigator.pop(context);
                                  _galleryActions();
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            child: Theme(
                              data: ThemeData(),
                              child: FlatButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 40,
                                      height: 40,
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/files.png',
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        '${localization.files}',
                                        style: TextStyle(
                                          color: blackPurpleColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  print('Файлы');
                                  Navigator.pop(context);
                                  _openFileExplorer();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  _showBottomModalSheet(context, {private}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 40.0,
              maxHeight: 100.0,
            ),
            child: Container(
              child: SmartRefresher(
                enablePullDown: false,
                enablePullUp: true,
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    return Container(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
                controller: _memberRefreshController,
                onRefresh: _onMemberRefresh,
                onLoading: _onMemberLoading,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _temp.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransferPage(
                                phone: _temp[i]['phone'],
                                transferChat: '${widget.chatID}',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 80,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(25.0),
                                child: Image.network(
                                  '$avatarUrl${_temp[i]['avatar'].toString().replaceAll("AxB", "200x200")}',
                                  width: 35,
                                  height: 35,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Text(
                                  '${_temp[i]['user_name']}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void _startRecord() async {
    bool hasPermission = await _checkPermission();
    if (hasPermission) {
      Vibration.vibrate();
      _recordFilePath = await _getAudioFilePath();
      _isRecording = true;

      print("RECORD FILE PATH $_recordFilePath");
      _dependencies.stopwatch.start();

      RecordMp3.instance.start(_recordFilePath, (type) {
        setState(() {});
      });
    } else {
      print("No microphone permission");
    }
    setState(() {});
  }

  void _stopRecord() {
    bool s = RecordMp3.instance.stop();
    if (s) {
      _isRecording = false;
      _dependencies.stopwatch.stop();
      _dependencies = new Dependencies();

      _api.uploadMedia(_recordFilePath, 3).then((r) async {
        print("RRRRR $r");
        if (r["status"]) {
          var a = [
            {
              "filename": "${r["file_name"]}",
            }
          ];
          ChatRoom.shared.sendMessage('${widget.chatID}', "voice",
              type: 3, attachments: jsonDecode(jsonEncode(a)));

          Directory storageDirectory = await getApplicationDocumentsDirectory();
          String sdPath = storageDirectory.path + "/record";
          var dir = Directory(sdPath);
          dir.deleteSync(recursive: true);
        } else {
          _showAlertDialog(context, r["message"]);
          print("error");
        }
      });

      setState(() {});
    }
  }

  Future<String> _getAudioFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/temple.mp3";
  }

  _showAlertDialog(BuildContext context, String message) {
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

  bool _value = true;
  Widget temp(m) {
    return InkWell(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        if (m['message_id'] == null) {
          print('clicking ${m['id']} \n $toForwardMessages');

          if (toForwardMessages.contains(m['id'])) {
            setState(() {
              toForwardMessages.remove(m['id']);
            });
          } else {
            setState(() {
              toForwardMessages.add(m['id']);
            });
          }
        } else {
          if (toForwardMessages.contains(m['message_id'])) {
            print('contains ${m['message_id']} \n $toForwardMessages');
            setState(() {
              toForwardMessages.remove(m['message_id']);
            });
          } else {
            print('not $toForwardMessages');

            setState(() {
              toForwardMessages.add(m['message_id']);
            });
          }
        }
      },
      child: Row(
        children: <Widget>[
          showForwardingProcess
              ? Container(
                  margin: EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blue),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: m['message_id'] == null ?
                      toForwardMessages.contains(m['id'])
                          ? Icon(
                              Icons.check,
                              size: 15,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.check_box_outline_blank,
                              size: 15,
                              color: Colors.blue,
                            ) :
                            toForwardMessages.contains(m['id'])
                          ? Icon(
                              Icons.check,
                              size: 15,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.check_box_outline_blank,
                              size: 15,
                              color: Colors.blue,
                            ),
                    ),
                  ),
                )
              : SizedBox(height: 0, width: 0),
          Flexible(
            child: _message(m),
          ),
        ],
      ),
    );
  }

  Widget _message(m) {
    if ('${m['id']}' == 'chat:message:create' ||
        '${m['type']}' == '7' ||
        '${m['type']}' == '8') return Devider(m);
    if ('${m['user_id']}' == '${user.id}') {
      return Sended(m, chatId: widget.chatID);
    } else {
      if (m['write'].toString() == '0') {
        ChatRoom.shared.readMessage(widget.chatID, m['message_id']);
      }
      return Received(m, chatId: widget.chatID, isGroup: _isGroup);
    }
  }
}

class Devider extends StatelessWidget {
  final m;
  Devider(this.m);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-1, 0),
      child: DeviderMessageWidget(
        date: m['text'],
      ),
    );
  }
}
