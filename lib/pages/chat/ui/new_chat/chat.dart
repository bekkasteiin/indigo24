import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/pages/chat/ui/new_chat/message.dart';
import 'package:indigo24/pages/chat/ui/new_widgets/new_widgets.dart';
import 'package:indigo24/pages/chat/ui/new_extensions.dart';
import 'package:indigo24/pages/chat/ui/users_list_draggable.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/test_timer.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/widgets/photo.dart';
import 'package:indigo24/widgets/preview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vibration/vibration.dart';

import '../../../../main.dart';
import '../../chat_info.dart';
import '../chats_list_draggable.dart';
import 'divider_message.dart';

class ChatPage extends StatefulWidget {
  final int chatId;
  final int chatType;
  final String userIds;
  final String chatName;
  final String avatarUrl;
  final String avatar;
  final int memberCount;
  final phone;
  const ChatPage({
    Key key,
    @required this.chatId,
    @required this.chatType,
    this.userIds,
    @required this.chatName,
    this.phone,
    @required this.avatar,
    @required this.avatarUrl,
    this.memberCount,
  }) : super(key: key);
  @override
  _NewChatPageState createState() => _NewChatPageState();
}

var replyMessage;

class _NewChatPageState extends State<ChatPage> {
  bool _sendingTyping;
  bool _isSomeoneTyping;
  bool _isRecording;
  int _messagesPage;
  int _lastMessageTime;
  List _messagesList;
  List _typingUsers;
  bool _isMessagesLoading;
  TextEditingController _messageController;
  Dependencies _dependencies = Dependencies();
  String _recordFilePath;
  Api _api;
  File _image;
  ImagePicker _picker = ImagePicker();
  File uploadingImage;
  bool _isUploaded;
  bool _multiPick = false;
  String _path;
  Map<String, String> _paths;
  FileType _pickingType = FileType.custom;
  String _fileName;
  dynamic _replyMessage;
  dynamic _editMessage;
  bool showForwardingProcess;
  List toForwardMessages;
  String _onlineString;
  ItemScrollController _itemScrollController = ItemScrollController();
  final bgChat = AssetImage("assets/images/background_chat.png");
  final bgChat2 = AssetImage("assets/images/background_chat_2.png");
  @override
  void didChangeDependencies() {
    precacheImage(bgChat, context);
    precacheImage(bgChat2, context);

    super.didChangeDependencies();
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

  Future<String> _getAudioFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/temple.mp3";
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
          ChatRoom.shared.sendMessage('${widget.chatId}', "voice",
              type: 3, attachments: jsonDecode(jsonEncode(a)));

          Directory storageDirectory = await getApplicationDocumentsDirectory();
          String sdPath = storageDirectory.path + "/record";
          var dir = Directory(sdPath);
          dir.deleteSync(recursive: true);
        } else {
          indigoCupertinoDialogAction(context, '${r["message"]}');
          print("error");
        }
      });

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _sendingTyping = false;
    _isMessagesLoading = false;
    _isSomeoneTyping = false;
    _isRecording = false;
    showForwardingProcess = false;
    _messagesPage = 1;
    _messagesList = [];
    _typingUsers = [];
    toForwardMessages = [];
    _messageController = TextEditingController();
    _api = Api();
    ChatRoom.shared.setNewChatStream();
    ChatRoom.shared.checkUserOnline(widget.userIds);

    listen();
    ChatRoom.shared.getMessages(widget.chatId, page: _messagesPage);
  }

  @override
  void dispose() {
    ChatRoom.shared.closeNewChatStream();
    _messageController.dispose();
    super.dispose();
  }

  getDateFromUnix(unix) {
    return DateTime.fromMillisecondsSinceEpoch(
        int.parse(unix.toString()) * 1000);
  }

  _buildMessage(index, Widget child) {
    if (_messagesList[index]['time'].toString() != '') {
      if (_messagesList[index]['time'].toString() == '1') {
        return SizedBox(height: 0, width: 0);
      } else {
        if (index == 0) {
          _lastMessageTime = int.parse(_messagesList[0]['time'].toString());
        }
        DateTime actualUnixDate = getDateFromUnix(_messagesList[index]['time']);

        DateTime lastUnixDate = getDateFromUnix(
          _lastMessageTime == null
              ? _messagesList[index]['time']
              : _lastMessageTime,
        );

        int differenceInDays = lastUnixDate.difference(actualUnixDate).inDays;
        _lastMessageTime = int.parse(_messagesList[index]['time'].toString());
        if (differenceInDays != 0) {
          return Column(
            children: <Widget>[
              child,
              lastUnixDate.difference(DateTime.now()).inDays == 0
                  ? DividerMessageWidget(child: Text('${localization.today}'))
                  : DividerMessageWidget(
                      child: Text(
                        '$lastUnixDate'.substring(0, 10).replaceAll('-', '.'),
                      ),
                    ),
            ],
          );
        } else {
          return child;
        }
      }
    } else {
      return SizedBox(height: 0, width: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: indigoAppBar(
        context,
        withBack: true,
        actions: [
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
              print("${widget.avatarUrl}${widget.avatar.toString()}");
              print("${widget.avatarUrl}${widget.avatar.toString()}");
              print("${widget.avatarUrl}${widget.avatar.toString()}");
              print("${widget.avatarUrl}${widget.avatar.toString()}");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenWrapper(
                      imageProvider: CachedNetworkImageProvider(
                          "${widget.avatarUrl}${(widget.avatar == '' || widget.avatar == null) ? "noAvatar.png" : widget.avatar.toString().replaceAll('AxB', '200x200')}"),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.contained * 3,
                      backgroundDecoration:
                          BoxDecoration(color: Colors.transparent),
                    ),
                  )).whenComplete(() {
                ChatRoom.shared.getMessages(widget.chatId);
              });
            },
          ),
        ],
        title: InkWell(
          onTap: () async {
            ChatRoom.shared.setChatInfoStream();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatProfileInfo(
                  chatType: widget.chatType,
                  chatName: widget.chatName,
                  chatAvatar:
                      widget.avatar == null ? 'noAvatar.png' : widget.avatar,
                  memberCount: widget.memberCount,
                  chatId: widget.chatId,
                  phone: widget.phone,
                ),
              ),
            ).whenComplete(() {
              setState(() {
                // ChatRoom.shared.setChatStream();
                ChatRoom.shared.getMessages(widget.chatId);
              });
            });
          },
          child: Column(
            children: <Widget>[
              Container(
                height: 0.1,
              ),
              FittedBox(
                child: Text(
                  widget.chatName.capitalize(),
                  style: TextStyle(
                    color: blackPurpleColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              widget.chatType == 0
                  ? _onlineString == null
                      ? SizedBox(
                          height: 0,
                          width: 0,
                        )
                      : Text(
                          ('$_onlineString' == 'online' ||
                                  '$_onlineString' == 'offline')
                              ? '$_onlineString'
                              : '${localization.lastSeen} $_onlineString',
                          style: TextStyle(
                            color: blackPurpleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                  : Text(
                      '${localization.members} ${widget.memberCount}',
                      style: TextStyle(
                        color: blackPurpleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
              _isSomeoneTyping
                  ? Text(
                      _typingUsers.join(', '),
                      style: TextStyle(
                        color: blackPurpleColor,
                        fontSize: 12,
                      ),
                    )
                  : Text(
                      '',
                      style: TextStyle(
                        color: Colors.transparent,
                        fontSize: 12,
                      ),
                    )
            ],
          ),
        ),
      ),
      backgroundColor: greyColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: user.chatBackground == 'ligth' ? bgChat : bgChat2,
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!_isMessagesLoading &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    _loadMore();
                  }
                },
                child: Expanded(
                  child: ScrollablePositionedList.builder(
                    itemCount: _messagesList.length,
                    reverse: true,
                    itemScrollController: _itemScrollController,
                    itemBuilder: (BuildContext context, int i) {
                      var message = _messagesList[i];

                      return InkWell(
                        onTap: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          if (showForwardingProcess &&
                              message['type'].toString() != '7') {
                            if (message['message_id'] == null) {
                              print(
                                  'clicki31231ng ${message['id']} \n $toForwardMessages');

                              if (toForwardMessages.contains(message['id'])) {
                                setState(() {
                                  toForwardMessages.remove(message['id']);
                                });
                              } else {
                                setState(() {
                                  toForwardMessages.add(message['id']);
                                });
                              }
                            } else {
                              if (toForwardMessages
                                  .contains(message['message_id'])) {
                                print(
                                    'contains ${message['message_id']} \n $toForwardMessages');
                                setState(() {
                                  toForwardMessages
                                      .remove(message['message_id']);
                                });
                              } else {
                                print('not $toForwardMessages');

                                setState(() {
                                  toForwardMessages.add(message['message_id']);
                                });
                              }
                            }
                          }
                        },
                        child: Row(
                          children: <Widget>[
                            showForwardingProcess &&
                                    message['type'].toString() != '7'
                                ? Container(
                                    margin: EdgeInsets.all(5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue),
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: message['message_id'] == null
                                            ? toForwardMessages
                                                    .contains(message['id'])
                                                ? Icon(
                                                    Icons.check,
                                                    size: 15,
                                                    color: Colors.white,
                                                  )
                                                : Icon(
                                                    Icons
                                                        .check_box_outline_blank,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  )
                                            : toForwardMessages
                                                    .contains(message['id'])
                                                ? Icon(
                                                    Icons.check,
                                                    size: 15,
                                                    color: Colors.white,
                                                  )
                                                : Icon(
                                                    Icons
                                                        .check_box_outline_blank,
                                                    size: 15,
                                                    color: Colors.blue,
                                                  ),
                                      ),
                                    ),
                                  )
                                : SizedBox(height: 0, width: 0),
                            Flexible(
                              child: Column(
                                children: <Widget>[
                                  _buildMessage(
                                    i,
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 5,
                                      ),
                                      child: MessageWidget(
                                        messageCategory: identifyCategory(
                                          int.parse(
                                            message['user_id'].toString(),
                                          ),
                                        ),
                                        chatType: widget.chatType,
                                        message: message,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                color: whiteColor,
                child: Column(
                  children: [
                    _replyMessage != null
                        ? Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 45,
                                        color: primaryColor,
                                      ),
                                      Container(width: 5),
                                      _replyMessage["attachment_url"] != null
                                          ? Container(
                                              width: 40,
                                              height: 40,
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    "${_replyMessage["attachment_url"]}${json.decode(_replyMessage["attachments"])[0]["r_filename"]}",
                                              ),
                                            )
                                          : Container(),
                                      Container(width: 5),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  "${_replyMessage["user_name"]}",
                                                  style: TextStyle(
                                                      color: primaryColor),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  "${_replyMessage["type"].toString() == '1' ? "Изображение" : _replyMessage["type"].toString() == '4' ? "Видео" : _replyMessage["text"]}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _replyMessage = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: 0,
                            width: 0,
                          ),
                    _editMessage != null
                        ? Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 45,
                                        color: primaryColor,
                                      ),
                                      Container(width: 5),
                                      _editMessage["attachment_url"] != null
                                          ? Container(
                                              width: 40,
                                              height: 40,
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    "${_editMessage["attachment_url"]}${json.decode(_editMessage["attachments"])[0]["r_filename"]}",
                                              ),
                                            )
                                          : Container(),
                                      Container(width: 5),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  "${_editMessage["user_name"]}",
                                                  style: TextStyle(
                                                      color: primaryColor),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  "${_editMessage["type"].toString() == '1' ? "Изображение" : _editMessage["type"].toString() == '4' ? "Видео" : _editMessage["text"]}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _editMessage = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: 0,
                            width: 0,
                          ),
                    showForwardingProcess
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  ChatRoom.shared.setChatsListDialogStream();

                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) =>
                                          ChatListDraggablePage(
                                              messages: toForwardMessages),
                                    ),
                                  ).whenComplete(() {
                                    ChatRoom.shared
                                        .closeChatsListDialogStream();
                                    // ChatRoom.shared.setChatStream();
                                    ChatRoom.shared.getMessages(widget.chatId);
                                  });
                                },
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
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
                                            TextCapitalization.sentences,
                                        maxLines: 6,
                                        minLines: 1,
                                        controller: _messageController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.all(0),
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                          if (!_sendingTyping) {
                                            ChatRoom.shared
                                                .typing(widget.chatId);
                                            _sendingTyping = true;
                                            Future.delayed(Duration(seconds: 3),
                                                () {
                                              _sendingTyping = false;
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  : Expanded(
                                      child: Container(
                                        height: 45,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              "assets/record.gif",
                                              width: 10,
                                              height: 10,
                                            ),
                                            Container(width: 5),
                                            TimerText(
                                                dependencies: _dependencies),
                                          ],
                                        ),
                                      ),
                                    ),
                              _messageController.text.isNotEmpty
                                  ? IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(Icons.send, size: 30),
                                      onPressed: () {
                                        if (_messageController
                                            .text.isNotEmpty) {
                                          if (_editMessage != null) {
                                            print("Edit message is called");
                                            var mId = _editMessage['id'] == null
                                                ? _editMessage['message_id']
                                                : _editMessage['id'];
                                            var type = _editMessage['type'];
                                            var time = _editMessage['time'];
                                            ChatRoom.shared.editMessage(
                                              _messageController.text,
                                              widget.chatId,
                                              type,
                                              time,
                                              mId,
                                            );
                                            setState(() {
                                              _messageController.clear();
                                              _editMessage = null;
                                            });
                                          } else {
                                            if (_replyMessage != null) {
                                              var mId = _replyMessage['id'] ==
                                                      null
                                                  ? _replyMessage['message_id']
                                                  : _replyMessage['id'];
                                              ChatRoom.shared.replyMessage(
                                                _messageController.text,
                                                widget.chatId,
                                                10,
                                                mId,
                                              );
                                              setState(() {
                                                _replyMessage = null;
                                              });
                                            } else {
                                              ChatRoom.shared.sendMessage(
                                                widget.chatId,
                                                _messageController.text,
                                              );
                                            }
                                          }

                                          setState(() {
                                            _messageController.clear();
                                          });
                                        }
                                      },
                                    )
                                  : GestureDetector(
                                      onLongPressUp: () {
                                        print("long press UP");
                                        _stopRecord();
                                      },
                                      onLongPress: () async {
                                        bool p = await _checkPermission();
                                        if (p) {
                                          _startRecord();
                                        }
                                      },
                                      child: Container(
                                        height: 45,
                                        width: 45,
                                        child: Icon(
                                          Icons.mic,
                                          size: 45,
                                        ),
                                      ),
                                    )
                            ],
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  identifyCategory(int messageUserId) {
    if (messageUserId == 13) {
      return 1;
    } else {
      return messageUserId == int.parse(user.id) ? 2 : 0;
    }
  }

  _loadMore() {
    setState(() {
      _isMessagesLoading = true;
    });

    ChatRoom.shared.getMessages(widget.chatId, page: _messagesPage);
  }

  bool typingProcessing = false;
  listen() {
    ChatRoom.shared.onNewChatChange.listen((e) {
      print("NEW CHAT EVENT ${e.json}");
      var cmd = e.json['cmd'];
      var data = e.json['data'];
      switch (cmd) {
        case "replyMessage":
          setState(() {
            _replyMessage = e.json['message'];
          });
          break;
        case "editMessage":
          setState(() {
            _messageController.text = e.json['text'];
            _editMessage = e.json['message'];
          });

          break;

        case 'message:deleted:all':
          var mId = e.json['data']['message_id'];
          print("deleting $mId");
          var i = _messagesList.indexWhere((element) =>
              (element['id'] == null ? element['message_id'] : element['id']) ==
              mId);
          print("deleting ${e.json}");
          setState(() {
            _messagesList.removeAt(i);
          });
          break;
        case "message:edit":
          var mId = e.json['data']['message_id'];
          var i = _messagesList.indexWhere((element) =>
              (element['id'] == null ? element['message_id'] : element['id']) ==
              mId);
          print("editing ${e.json}");
          setState(() {
            _messagesList[i] = e.json['data'];
          });
          break;
        case "chat:get":
          if (data.isNotEmpty) {
            _messagesPage++;
            setState(() {
              _messagesList.addAll(data);
              _isMessagesLoading = false;
            });
            if (replyMessage != null) {
              int i = _messagesList.indexWhere((e) {
                return e['id'] == replyMessage['message_id'];
              });
              if (i != -1) {
                setState(() {
                  _itemScrollController.scrollTo(
                      index: i, duration: Duration(milliseconds: 500));
                  replyMessage = null;
                });
              } else {
                _loadMore();
              }
            }
          }

          break;

        case "findMessage":
          print("Scrolling to ${e.json['index']['message_id']}");
          // while(_myLis
          var id = e.json['index']['message_id'];

          int i = _messagesList.indexWhere((e) {
            return e['id'] == id;
          });

          if (i != -1) {
            setState(() {
              _itemScrollController.scrollTo(
                  index: i, duration: Duration(milliseconds: 500));
            });
          } else {
            _loadMore();
          }
          break;

        case "message:create":
          if (widget.chatId == int.parse(data['chat_id'].toString()))
            setState(() {
              _messagesList.insert(0, data);
            });
          var senderId = e.json["data"]['user_id'].toString();
          var userId = user.id.toString();
          if ('${e.json['data']['chat_id']}' == '${widget.chatId}' &&
              senderId != userId) {
          } else {
            if (_messagesList.length > 5) {
              _itemScrollController.scrollTo(
                index: 0,
                duration: Duration(milliseconds: 500),
              );
            }
          }
          break;
        case "user:writing":
          print('writing');
          if (data[0]['chat_id'] == widget.chatId) {
            typingProcessing = true;
            setState(() {
              _isSomeoneTyping = true;
              data.toList().forEach((element) {
                if (user.id != '${element['user_id']}')
                  setState(() {
                    _typingUsers.add(element['name']);
                  });
                Future.delayed(Duration(seconds: 3), () {
                  if (typingProcessing) {
                    setState(() {
                      _typingUsers = [];
                    });
                  } else {
                    typingProcessing = false;
                  }
                });
              });
            });
          }
          break;
        case "message:write":
          print('message read');
          var i = _messagesList.indexWhere((element) {
            if (element['message_id'].toString() == 'null') {
              return element['id'] == data['message_id'];
            } else {
              return element['message_id'] == data['message_id'];
            }
          });

          setState(() {
            _messagesList[i]['write'] = '1';
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
        case "user:check:online":
          setState(() {
            data.forEach((element) {
              print('${element['user_id']} == ${widget.userIds}');
              if (element['user_id'] == widget.userIds) {
                _onlineString = element['online'];
              }
            });
          });
      }
    });
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
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    fullscreenDialog: true,
                                    builder: (context) =>
                                        UsersListDraggableWidget(
                                      chatId: widget.chatId,
                                    ),
                                  ),
                                ).whenComplete(() {
                                  ChatRoom.shared.getMessages(widget.chatId);
                                });
                                // widget.chatType == 0
                                // ? Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => TransferPage(
                                //         phone: '${widget.phone}',
                                //         transferChat: '${widget.chatID}',
                                //       ),
                                //     ),
                                //   )
                                // : _showBottomModalSheet(context);
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
      },
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

  Future _getImage(ImageSource imageSource) async {
    final pickedFile = await _picker.getImage(source: imageSource);
    if (pickedFile != null) {
      _image = File(pickedFile.path);

      final popResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewMedia(
            filePath: pickedFile.path,
          ),
        ),
      );

      if (popResult['cmd'] == "sending") {
        _api.uploadMedia(_image.path, 1).then((r) async {
          print("RRR $r");
          if (r["status"]) {
            var a = [
              {
                "filename": "${r["file_name"]}",
                "r_filename": "${r["resize_file_name"]}"
              }
            ];
            ChatRoom.shared.sendMessage(
                '${widget.chatId}', "${popResult['text']}",
                type: 1, attachments: jsonDecode(jsonEncode(a)));
          } else {
            // _showAlertDialog(context, r["message"]);
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
        _api.uploadMedia(_image.path, 4).then((r) async {
          print("RRR $r");
          if (r["status"]) {
            var a = [
              {"filename": "${r["file_name"]}"}
            ];
            ChatRoom.shared.sendMessage(
                '${widget.chatId}', "${popResult['text']}",
                type: 4, attachments: jsonDecode(jsonEncode(a)));
          } else {
            // _showAlertDialog(context, r["message"]);
            print("error");
          }
        });
      }
    }
  }

  void _openFileExplorer() async {
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
          ChatRoom.shared.sendMessage('${widget.chatId}', "file",
              type: 2,
              fileId: r["file_id"],
              attachments: jsonDecode(jsonEncode(a)));
        } else {
          // _showAlertDialog(context, r["message"]);
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
}
