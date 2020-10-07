import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/pages/chat/ui/new_chat/message_categories/divider_message.dart';
import 'package:indigo24/pages/chat/ui/new_chat/message.dart';
import 'package:indigo24/pages/chat/ui/new_chat/message_types/audio_message.dart';
import 'package:indigo24/pages/chat/ui/new_widgets/new_widgets.dart';
import 'package:indigo24/pages/chat/ui/new_extensions.dart';
import 'package:indigo24/pages/chat/ui/users_list_draggable.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/timer.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/full_photo.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/preview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vibration/vibration.dart';
import 'chat_models/hive_names.dart';
import '../../ui/new_chat/chat_models/messages_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../main.dart';
import '../../chat_info.dart';
import '../chats_list_draggable.dart';

class ChatPage extends StatefulWidget {
  final int chatId;
  final int chatType;
  final String chatName;
  final String avatar;
  final int memberCount;
  final phone;
  const ChatPage({
    Key key,
    @required this.chatId,
    @required this.chatType,
    @required this.chatName,
    this.phone,
    @required this.avatar,
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
  bool _stickersIsActive;
  int _messagesPage;
  int _lastMessageTime;
  List _typingUsers;
  dynamic _stickersList;
  bool _isMessagesLoading;
  TextEditingController _messageController;
  Dependencies _dependencies = Dependencies();
  String _recordFilePath;
  String stickersUrl;
  Api _api;
  File _image;
  ImagePicker _picker = ImagePicker();
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

  FocusNode myFocusNode;
  @override
  void initState() {
    super.initState();
    _sendingTyping = false;
    _isMessagesLoading = false;
    _isSomeoneTyping = false;
    _isRecording = false;
    showForwardingProcess = false;
    _stickersIsActive = false;
    closeMainChat = true;
    _messagesPage = 1;
    _typingUsers = [];
    toForwardMessages = [];
    _stickersList = [];
    stickersUrl = '';
    _messageController = TextEditingController();
    myFocusNode = FocusNode();
    _api = Api();
    ChatRoom.shared.setNewChatStream();
    // ChatRoom.shared.checkUserOnline(widget.userIds); // ADD WITH NEW BACKEND VALUE
    ChatRoom.shared.getStickers();
    listen();
    ChatRoom.shared.getMessages(widget.chatId, page: _messagesPage);
  }

  @override
  void dispose() {
    closeMainChat = false;
    ChatRoom.shared.closeNewChatStream();
    _messageController.dispose();
    myFocusNode.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    super.dispose();
  }

  getDateFromUnix(unix) {
    return DateTime.fromMillisecondsSinceEpoch(
        int.parse(unix.toString()) * 1000);
  }

  _buildMessage(int message, index, Widget child) {
    if (message.toString() != '') {
      if (message.toString() == '1') {
        return SizedBox(height: 0, width: 0);
      } else {
        if (index == 0) {
          _lastMessageTime = int.parse(message.toString());
        }
        DateTime actualUnixDate = getDateFromUnix(message);

        DateTime lastUnixDate = getDateFromUnix(
          _lastMessageTime == null ? message : _lastMessageTime,
        );

        int differenceInDays = lastUnixDate.difference(actualUnixDate).inDays;
        _lastMessageTime = int.parse(message.toString());
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

  _identifyType(type) {
    // const TEXT_MESSAGE_TYPE = 0;
    // const IMAGE_MESSAGE_TYPE = 1;
    // const DOCUMENT_MESSAGE_TYPE = 2;
    // const VOICE_MESSAGE_TYPE = 3;
    // const VIDEO_MESSAGE_TYPE = 4;
    // const SYSTEM_MESSAGE_TYPE = 7;
    // const SYSTEM_MESSAGE_DIVIDER_TYPE = 8;
    // const GEO_POINT_MESSAGE_TYPE = 9;
    // const REPLY_MESSAGE_TYPE = 10;
    // const MONEY_MESSAGE_TYPE = 11;
    // const LINK_MESSAGE_TYPE = 12;
    // const FORWARD_MESSAGE_TYPE = 13;
    switch ('$type') {
      case '0':
        return '${localization.textMessage}';
        break;
      case '1':
        return '${localization.photo}';
        break;
      case '2':
        return '${localization.document}';
        break;
      case '3':
        return '${localization.voiceMessage}';
        break;
      case '4':
        return '${localization.video}';
        break;
      case '7':
        return '${localization.systemMessage}';
        break;
      // case '8':
      // return 'Дивайдер сообщение';
      // break;
      case '9':
        return '${localization.location}';
        break;
      case '10':
        return '${localization.reply}';
        break;
      case '11':
        return '${localization.money}';
        break;
      case '12':
        return '${localization.link}';
        break;
      case '13':
        return '${localization.forwardedMessage}';
        break;
      default:
        return '${localization.message}';
    }
  }

  List<String> audios = [
    'Cr40YlNezldbtLBHYcbvuEnmscTN3C4KB.mp3',
    'Cr40YlNezldbtLBHYcbvuEnmscTN3C4KB.mp3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IndigoAppBarWidget(
        elevation: 0.5,
        actions: [
          IconButton(
            padding: EdgeInsets.all(5),
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: CachedNetworkImage(
                errorWidget: (context, url, error) => Image.asset(
                  'assets/preloader.gif',
                ),
                imageUrl:
                    '$avatarUrl${(widget.avatar == '' || widget.avatar == null) ? "noAvatar.png" : widget.avatar.toString().replaceAll('AxB', '200x200')}',
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullPhoto(
                      url:
                          "$avatarUrl${(widget.avatar == '' || widget.avatar == null) ? "noAvatar.png" : widget.avatar.toString().replaceAll('200x200', 'AxB')}"),
                ),
              ).whenComplete(() {
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
                  chatAvatar: widget.avatar,
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
                  : SizedBox(height: 0, width: 0),
              // Text(
              //     '${localization.members} ${widget.memberCount}',
              //     style: TextStyle(
              //       color: blackPurpleColor,
              //       fontSize: 14,
              //       fontWeight: FontWeight.w400,
              //     ),
              //   ),
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
                  child: ValueListenableBuilder(
                    valueListenable:
                        Hive.box<MessageModel>(HiveBoxes.messages).listenable(),
                    builder: (context, Box box, newWidget) {
                      var numbers = box.values
                          .where((message) => message.chatId == widget.chatId)
                          .toList();

                      if (numbers.isNotEmpty)
                        numbers.sort((a, b) {
                          return b.time.compareTo(a.time);
                        });

                      return ScrollablePositionedList.builder(
                        itemCount: numbers.length,
                        reverse: true,
                        itemScrollController: _itemScrollController,
                        itemBuilder: (BuildContext context, int i) {
                          MessageModel message = numbers[i];
                          if (numbers.isEmpty)
                            return SizedBox(height: 0, width: 0);
                          return InkWell(
                            onTap: () {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              if (showForwardingProcess && message.type != 7) {
                                if (toForwardMessages.contains(message.id)) {
                                  setState(() {
                                    toForwardMessages.remove(message.id);
                                  });
                                } else {
                                  setState(() {
                                    toForwardMessages.add(message.id);
                                  });
                                }
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                showForwardingProcess && message.type != 7
                                    ? Container(
                                        margin: EdgeInsets.all(5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue),
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: toForwardMessages
                                                    .contains(message.id)
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
                                        message.time,
                                        i,
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 5,
                                          ),
                                          child: MessageWidget(
                                            messageCategory: identifyCategory(
                                              message.userId,
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
                                      // _replyMessage["attachment_url"] != null
                                      //     ? Container(
                                      //         width: 40,
                                      //         height: 40,
                                      //         child: CachedNetworkImage(
                                      //           imageUrl:
                                      //               "${_replyMessage["attachment_url"]}${json.decode(_replyMessage["attachments"])[0]["r_filename"]}",
                                      //         ),
                                      //       )
                                      //     : Container(),
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
                                                  // "${_replyMessage["user_name"]}",
                                                  "${_replyMessage['username']}",
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
                                                  // "${_replyMessage['message_text_for_type']}",
                                                  "${_replyMessage['type'] == 0 ? _replyMessage['text'] : _identifyType(_replyMessage['type'])}",

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
                                      // _editMessage["attachment_url"] != null
                                      //     ? Container(
                                      //         width: 40,
                                      //         height: 40,
                                      //         child: CachedNetworkImage(
                                      //           imageUrl:
                                      //               "${_editMessage["attachment_url"]}${json.decode(_editMessage["attachments"])[0]["r_filename"]}",
                                      //         ),
                                      //       )
                                      //     : Container(),
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
                                                  // "${_editMessage["user_name"]}",
                                                  "${_editMessage['username']}",
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
                                                  "${_editMessage['text']}",
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
                                        _messageController.clear();
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
                        : Column(
                            children: <Widget>[
                              Row(
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
                                          child: Row(
                                            children: <Widget>[
                                              Flexible(
                                                child: TextField(
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  maxLines: 6,
                                                  minLines: 1,
                                                  controller:
                                                      _messageController,
                                                  focusNode: myFocusNode,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    errorBorder:
                                                        InputBorder.none,
                                                    disabledBorder:
                                                        InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(0),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {});
                                                    if (!_sendingTyping) {
                                                      ChatRoom.shared.typing(
                                                          widget.chatId);
                                                      _sendingTyping = true;
                                                      Future.delayed(
                                                          Duration(seconds: 3),
                                                          () {
                                                        _sendingTyping = false;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.all(0),
                                                icon: Icon(
                                                    _stickersIsActive
                                                        ? Icons.keyboard
                                                        : Icons.sms_failed,
                                                    size: 30),
                                                onPressed: () {
                                                  if (!_stickersIsActive) {
                                                    SystemChannels.textInput
                                                        .invokeMethod(
                                                            'TextInput.hide');
                                                  } else {
                                                    SystemChannels.textInput
                                                        .invokeMethod(
                                                            'TextInput.show');
                                                    myFocusNode.requestFocus();
                                                  }
                                                  setState(() {
                                                    _stickersIsActive =
                                                        !_stickersIsActive;
                                                  });
                                                },
                                              ),
                                            ],
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
                                                    dependencies:
                                                        _dependencies),
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
                                                var mId = _editMessage['id'] ==
                                                        null
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
                                                  var mId =
                                                      _replyMessage['id'] ==
                                                              null
                                                          ? _replyMessage[
                                                              'message_id']
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
                              Container(
                                color: blackColor,
                                height: 1,
                              ),
                              MediaQuery.of(context).viewInsets.bottom == 0 &&
                                      _stickersIsActive &&
                                      _stickersList.isNotEmpty
                                  ? Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: GridView.count(
                                        scrollDirection: Axis.horizontal,
                                        crossAxisCount: 3,
                                        children: List.generate(
                                            _stickersList.length, (index) {
                                          return InkWell(
                                            onTap: () {
                                              print('adding $index');
                                              ChatRoom.shared.sendMessage(
                                                widget.chatId,
                                                '',
                                                type: 14,
                                                attachments: [
                                                  {
                                                    'stick_id':
                                                        _stickersList[index]
                                                            ['id']
                                                  }
                                                ],
                                              );
                                            },
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  '$stickersUrl${_stickersList[index]['path']}',
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.15,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.15,
                                            ),
                                          );
                                        }),
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.42,
                                    )
                                  : SizedBox(
                                      height: 0,
                                      width: 0,
                                    ),
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

          Box<MessageModel> contactsBox =
              Hive.box<MessageModel>(HiveBoxes.messages);

          contactsBox.delete(mId);
          // var i = _messagesList.indexWhere((element) =>
          //     (element['id'] == null ? element['message_id'] : element['id']) ==
          //     mId);
          // print("deleting ${e.json}");
          // setState(() {
          //   _messagesList.removeAt(i);
          // });
          break;
        case "message:edit":
          print("editing ${e.json}");
          Box<MessageModel> contactsBox =
              Hive.box<MessageModel>(HiveBoxes.messages);
          contactsBox.put(
            data['message_id'],
            MessageModel(
              id: data['message_id'] as String,
              chatId: int.parse(data['chat_id'].toString()),
              userId: int.parse(data['user_id'].toString()),
              avatar: data['avatar'] as String,
              read: data['write'].toString() == '1' ? true : false,
              username: data['user_name'] as String,
              text: data['text'] as String,
              type: int.parse(data['type'].toString()),
              time: int.parse(data['time'].toString()),
              attachments: data['attachments'] != null
                  ? json.decode(data['attachments'])
                  : null,
              reply_data: data['attachments'] != null
                  ? json.decode(data['reply_data'])
                  : null,
              edited: data['edit'].toString() == '1' ? true : false,
              moneyData: {
                'avatar': data['another_user_avatar'],
                'name': data['another_user_name']
              },
            ),
          );
          break;
        case "chat:get":
          if (data.isNotEmpty) {
            print('chat get is $data');
            _messagesPage++;
            Box<MessageModel> contactsBox =
                Hive.box<MessageModel>(HiveBoxes.messages);
            data.forEach((message) {
              contactsBox.put(
                message['id'],
                MessageModel(
                  id: message['id'] as String,
                  chatId: int.parse(message['chat_id'].toString()),
                  userId: int.parse(message['user_id'].toString()),
                  avatar: message['avatar'] as String,
                  read: message['write'].toString() == '1' ? true : false,
                  username: message['user_name'] as String,
                  text: message['text'] as String,
                  type: int.parse(message['type'].toString()),
                  time: int.parse(message['time'].toString()),
                  attachments: message['attachments'],
                  reply_data: message['reply_data'],
                  edited: message['edit'].toString() == '1' ? true : false,
                  moneyData: {
                    'avatar': message['another_user_avatar'],
                    'name': message['another_user_name']
                  },
                ),
              );
            });
            setState(() {
              _isMessagesLoading = false;
            });
          }

          break;

        case "findMessage":
          print("Scrolling to ${e.json['index']}");
          // while(_myLis
          String id = e.json['index'];
          Box<MessageModel> contactsBox =
              Hive.box<MessageModel>(HiveBoxes.messages);

          List messages = contactsBox.values
              .where((message) => message.chatId == widget.chatId)
              .toList();

          messages.sort((a, b) {
            return b.time.compareTo(a.time);
          });
          var i = messages.indexWhere((element) => element.id == id);

          print('and i is $i');
          if (i != -1) {
            setState(() {
              _itemScrollController.scrollTo(
                index: i,
                duration: Duration(milliseconds: 500),
              );
            });
          } else {
            _loadMore();
          }
          break;

        case "message:create":
          if (widget.chatId == int.parse(data['chat_id'].toString())) {
            Box<MessageModel> contactsBox =
                Hive.box<MessageModel>(HiveBoxes.messages);
            contactsBox.put(
              data['message_id'],
              MessageModel(
                id: data['message_id'] as String,
                chatId: int.parse(data['chat_id'].toString()),
                userId: int.parse(data['user_id'].toString()),
                avatar: data['avatar'] as String,
                read: data['write'].toString() == '1' ? true : false,
                username: data['user_name'] as String,
                text: data['text'] as String,
                type: int.parse(data['type'].toString()),
                time: data['time'],
                attachments: data['attachments'],
                reply_data: data['reply_data'],
                edited: data['edit'].toString() == '1' ? true : false,
                moneyData: {
                  'avatar': data['another_user_avatar'],
                  'name': data['another_user_name']
                },
              ),
            );
          }

          var senderId = e.json["data"]['user_id'].toString();
          var userId = user.id.toString();
          if ('${e.json['data']['chat_id']}' == '${widget.chatId}' &&
              senderId != userId) {
          } else {
            // if (_messagesList.length > 10) {
            // _itemScrollController.scrollTo(
            // index: 0,
            // duration: Duration(milliseconds: 500),
            // );
            // }
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

          break;
        case "forwardMessage":
          setState(() {
            showForwardingProcess = true;
            print('add to forward is ${e.json}');
            toForwardMessages.add(e.json['id']);
          });
          break;
        case "user:check:online":
          // setState(() {
          //   data.forEach((element) {
          //     if (element['user_id'] == widget.userIds) {
          //       _onlineString = element['online'];
          //     }
          //   });
          // });
          break;
        case "chat:stickers":
          setState(() {
            stickersUrl = data['media_url'];
            List stickers = data['packs'];
            if (stickers != null && stickers.isNotEmpty)
              data['packs'].forEach((stickerPack) {
                _stickersList.addAll(stickerPack['stickers']);
              });
          });
          break;
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
