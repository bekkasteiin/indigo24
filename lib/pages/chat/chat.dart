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
import 'package:indigo24/pages/chat/ui/sended.dart';
import 'package:indigo24/pages/wallet/transfers/transfer.dart';
import 'package:indigo24/services/test_timer.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/widgets/keyboard_dismisser.dart';
import 'package:indigo24/widgets/player.dart';
import 'package:indigo24/widgets/preview.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vibration/vibration.dart';
import 'chat_page_view_test.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:indigo24/services/localization.dart' as localization;

var parser = EmojiParser();
List listMessages = [];

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
  ChatPage(this.name, this.chatID,
      {this.members,
      this.chatType,
      this.memberCount,
      this.userIds,
      this.avatar,
      this.avatarUrl,
      this.phone});

  @override
  _ChatPageState createState() => _ChatPageState();
}

var temp;

class _ChatPageState extends State<ChatPage> {
  Dependencies dependencies = Dependencies();
  List myList = [];
  List members = [];
  TextEditingController _text = new TextEditingController();
  var online;
  var hiddenId;
  ScrollController controller;
  bool isLoaded = false;
  bool isTyping = false;
  bool isRecording = false;
  Api api = Api();
  int page = 1;
  // RefreshController _refreshController = RefreshController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String statusText = "";
  bool isComplete = false;
  bool hasPermission = false;
  bool isEditing = false;
  var editMessage;
  bool isReplying = false;
  var replyMessage;

  String fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  var myFileUrl;
  bool haveFile = false;
  bool isSomeoneTyping = false;
  List typingMembers = [];
  List typingName = [];

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  void sendSound() {
    print("Send sound is called");
    final player = AudioCache();
    player.play("sound/msg_out.mp3");
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    print("_onRefresh ");
    // print("_onRefresh ");
    // print("_onRefresh ");
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

  RefreshController _memberRefreshController =
      RefreshController(initialRefresh: false);

  void _onMemberRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    print("_onRefresh");
    _refreshController.refreshCompleted();
  }

  int chatMembersPage = 1;

  void _onMemberLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (temp.length % 20 == 0) {
      chatMembersPage++;
      if (mounted)
        setState(() {
          print("_onLoading chat members with page $chatMembersPage");
          ChatRoom.shared.chatMembers(widget.chatID, page: chatMembersPage);

          // for(int i = 0; i < 20; i++){
          //   membersList.add({'name' : 'test'});
          //   print(membersList.length);
          // }
        });
      _refreshController.loadComplete();
    }
  }

  @override
  initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    ChatRoom.shared.chatMembers(widget.chatID);
    // widget.members.forEach((element){
    // element ==  myContacts;
    // });
    print('______________________________');
    print('members of this chat ${widget.members}');
    print('this is chats user online check ${widget.userIds}');
    print('______________________________');
    ChatRoom.shared.checkUserOnline(widget.userIds);
    listen();
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

  int pageCounter = 1;
  bool isUploading = false;
  bool isUploaded = false;

  listen() {
    ChatRoom.shared.onCabinetChange.listen((e) {
      print("CABINET EVENT ${e.json['cmd']}");
      var cmd = e.json['cmd'];
      switch (cmd) {
        case "chat:get":
          if (page == 1) {
            setState(() {
              print(e.json['data']);
              page += 1;
              myList = e.json['data'].toList();
              listMessages = e.json['data'].toList();
            });
          } else {
            print(
                '____________________________________________________________$page');
            print(e.json['data']);
            setState(() {
              page += 1;
              myList.addAll(e.json['data'].toList());
              listMessages.addAll(e.json['data'].toList());
            });
          }
          break;
        case "chat:members":
          print(e.json);
          temp = [];
          e.json['data'].forEach((memberElement) {
            myContacts.toList().forEach((element) {
              if ('${element.phone}' == '${memberElement['phone']}') {
                print('match ${element.phone}');
                temp.add(memberElement);
              }
            });
          });
          break;
        case "message:create":
          var message = e.json['data'];
          print("Message created with data $message");
          if (message['type'].toString() == '1') {
            // setState(() {
            //   uploadingImage = null;
            // });
          }
          if ('${widget.chatID}' == '${e.json['data']['chat_id']}') {
            if (isUploaded) {
              setState(() {
                isUploaded = false;
                ChatRoom.shared.lastMessage = message;
                myList.remove(uploadingMessage);
                myList.insert(0, message);
                listMessages.insert(0, message);
              });
            } else {
              setState(() {
                ChatRoom.shared.lastMessage = message;
                myList.insert(0, message);
                listMessages.insert(0, message);
              });
            }
          }
          var senderId = e.json["data"]['user_id'].toString();
          var userId = user.id.toString();
          if (senderId != userId &&
              '${widget.chatID}' != '${e.json['data']['chat_id']}') {
            inAppPush(e.json["data"]);
          }
          break;
        case "chat:create":
          ChatRoom.shared.getMessages(widget.chatID);
          break;
        case "user:check:online":
          // print('${e.json['data']['online']}');
          print(e.json);
          setState(() {
            hiddenId = '${e.json['data'][0]['user_id']}';
            online = '${e.json['data'][0]['online']}';
          });
          break;
        case "user:writing":
          print("PRINT PRINT ${e.json['data']}");
          if (e.json['data'][0]['chat_id'].toString() ==
              widget.chatID.toString()) {
            setState(() {
              typingName = [];
              typingMembers = e.json['data'].toList();
              if (e.json['data'].toList().length > 0) {
                typingMembers.forEach((element) {
                  if (typingName.contains('${element['name']}'))
                    element['name'] = '';
                  if (element['user_id'].toString() != '${user.id}')
                    typingName.add("${element['name']}");
                });
              }
            });
            if (!isSomeoneTyping) {
              setState(() {
                isSomeoneTyping = true;

                deleteTyping();
              });
            }
          }
          break;
        case "message:deleted:all":
          var mId = e.json['data']['message_id'];
          print("deleting $mId");
          var i = myList.indexWhere((element) =>
              (element['id'] == null ? element['message_id'] : element['id']) ==
              mId);
          print("deleting ${e.json}");
          setState(() {
            myList.removeAt(i);
            listMessages.removeAt(i);
          });
          break;
        case "message:edit":
          var mId = e.json['data']['message_id'];
          var i = myList.indexWhere((element) =>
              (element['id'] == null ? element['message_id'] : element['id']) ==
              mId);
          print("editing ${e.json}");
          setState(() {
            myList[i] = e.json['data'];
            listMessages[i] = e.json['data'];
          });
          break;
        case "editMessage":
          _text.text = e.json['text'];
          setState(() {
            isEditing = true;
            editMessage = e.json['message'];
          });
          break;
        case "replyMessage":
          setState(() {
            isReplying = true;
            replyMessage = e.json['message'];
          });
          break;
        case "scrolling":
          print("Scrolling to ${e.json['index']}");
          setState(() {
            itemScrollController.scrollTo(
                index: e.json['index'],
                duration: Duration(milliseconds: 300),
                curve: Curves.linear,
                alignment: 0.9);
          });

          break;
        default:
          print('CABINET EVENT DEFAULT');
      }
    });
  }

  deleteTyping() async {
    await Future.delayed(Duration(seconds: 3)).then((value) {
      setState(() {
        isSomeoneTyping = false;
      });
    });
  }
  // bool isLoading = false;

  Future _loadData() async {
    // perform fetching data delay
    print("WTF?????? $isLoaded");
    setState(() {
      isLoaded = false;
      // if(page==1){
      //   ChatRoom.shared.getMessages(widget.chatID, page: 2);
      // } else {
      ChatRoom.shared.getMessages(widget.chatID, page: page);
      // }
    });

    print("load more with page $page");
    // update data and loading status
  }

  File _image;

  final picker = ImagePicker();

  var uploadingMessage = json.decode(
      json.encode({"type": "uploading", "time": "1", "user_id": user.id}));

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(source: imageSource);
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

      if (popResult == "sending") {
        setState(() {
          isUploading = true;
          uploadingImage = _image;
          myList.insert(0, uploadingMessage);
        });

        api.uploadMedia(_image.path, 1).then((r) async {
          print("RRR $r");
          if (r["status"]) {
            var a = [
              {
                "filename": "${r["file_name"]}",
                "r_filename": "${r["resize_file_name"]}"
              }
            ];
            setState(() {
              isUploaded = true;
            });
            ChatRoom.shared.sendMessage('${widget.chatID}', "image",
                type: 1, attachments: jsonDecode(jsonEncode(a)));
          } else {
            showAlertDialog(context, r["message"]);
            print("error");
          }
        });
      }
    }
  }

  Future getVideo(ImageSource imageSource) async {
    final pickedFile = await picker.getVideo(source: imageSource);
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

      if (popResult == "sending") {
        setState(() {
          isUploading = true;
          myList.insert(0, uploadingMessage);
        });

        api.uploadMedia(_image.path, 4).then((r) async {
          print("RRR $r");
          if (r["status"]) {
            var a = [
              {"filename": "${r["file_name"]}"}
            ];
            setState(() {
              isUploaded = true;
            });
            ChatRoom.shared.sendMessage('${widget.chatID}', "video",
                type: 4, attachments: jsonDecode(jsonEncode(a)));
          } else {
            showAlertDialog(context, r["message"]);
            print("error");
          }
        });
      }
    }
  }

  void _openFileExplorer() async {
    setState(() => loadingPath = true);
    try {
      if (_multiPick) {
        _path = null;
        _paths = await FilePicker.getMultiFilePath(
            type: _pickingType,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);
      } else {
        _paths = null;
        _path = await FilePicker.getFilePath(
            type: _pickingType,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);

        print(_path);
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      loadingPath = false;
      fileName = _path != null
          ? _path.split('/').last
          : _paths != null ? _paths.keys.toString() : '...';

      print("path name $_path");
    });

    api.uploadMedia(_path, 2).then((r) async {
      print("RRR ${r["message"]}");
      if (r["status"]) {
        var a = [
          {"filename": "${r["file_name"]}"}
        ];
        ChatRoom.shared.sendMessage('${widget.chatID}', "file",
            type: 2, attachments: jsonDecode(jsonEncode(a)));
      } else {
        showAlertDialog(context, r["message"]);
        print("error");
      }
    });

    // doReguest();
  }

  @override
  void dispose() {
    ChatRoom.shared.cabinetController.close();
    controller.removeListener(_scrollListener);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
    audioPlayers = [];
  }

  showAttachmentBottomSheet(context) {
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
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(15)),
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
                                      child: Text('${localization.camera}',
                                          style: TextStyle(
                                              color: Color(0xFF001D52),
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  Navigator.pop(context);
                                  getImage(ImageSource.camera);
                                  print('Камера');
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
                                      child: Text('${localization.money}',
                                          style: TextStyle(
                                              color: Color(0xFF001D52),
                                              fontWeight: FontWeight.w500)),
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
                                                transferChat:
                                                    '${widget.chatID}'),
                                          ))
                                      // showBottomModalSheet(context,
                                      //   private: true)
                                      : showBottomModalSheet(context);
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
                                      child: Text('${localization.gallery}',
                                          style: TextStyle(
                                              color: Color(0xFF001D52),
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  print('Галерея');
                                  Navigator.pop(context);
                                  getImage(ImageSource.gallery);
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
                                      child: Text('${localization.video}',
                                          style: TextStyle(
                                              color: Color(0xFF001D52),
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  print('видео');
                                  Navigator.pop(context);
                                  getVideo(ImageSource.gallery);
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
                                      child: Text('${localization.files}',
                                          style: TextStyle(
                                              color: Color(0xFF001D52),
                                              fontWeight: FontWeight.w500)),
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

  showBottomModalSheet(context, {private}) {
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
                // height: 120,
                // width: 100,
                child: SmartRefresher(
                  enablePullDown: false,
                  enablePullUp: true,
                  // header: WaterDropHeader(),
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
                    itemCount: temp.length,
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      // print(temp);
                      // print(temp.length);
                      return Center(
                        child: InkWell(
                          onTap: () {
                            print(json.decode(json.encode(temp[i])));
                            print(temp[i]['phone']);

                            // myContacts
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransferPage(
                                    phone: temp[i]['phone'],
                                    transferChat: '${widget.chatID}'),
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
                                    '$avatarUrl${temp[i]['avatar'].toString().replaceAll("AxB", "200x200")}',
                                    width: 35,
                                    height: 35,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child: Text(
                                    '${temp[i]['user_name']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                // Text("${_saved2[index][0]}")
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: [
        GestureType.onTap,
        GestureType.onPanUpdateDownDirection,
      ],
      // onTap: () {
      //   SystemChannels.textInput.invokeMethod('TextInput.hide');
      //   FocusScopeNode currentFocus = FocusScope.of(context);
      //   if (!currentFocus.hasPrimaryFocus) {
      //     currentFocus.unfocus();
      //   }
      // },
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
                      color: Color(0xFF001D52), fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
                isSomeoneTyping
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (widget.memberCount > 2)
                              ? Text("${typingName.join(' ')} ",
                                  style: TextStyle(
                                      color: Color(0xFF001D52),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400))
                              : Container(),
                          Image.asset(
                            "assets/typing.gif",
                            width: 20,
                          )
                        ],
                      )
                    : (widget.chatType == 1)
                        ? Text(
                            '${localization.members} ${widget.memberCount}',
                            style: TextStyle(
                                color: Color(0xFF001D52),
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          )
                        : online == null
                            ? Container()
                            : Text(
                                ('$online' == 'online' ||
                                        '$online' == 'offline')
                                    ? '$online'
                                    : '${localization.wasOnline} $online',
                                style: TextStyle(
                                    color: Color(0xFF001D52),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
              ],
            ),
            onTap: () {
              ChatRoom.shared.setChatInfoStream();
              ChatRoom.shared.cabinetController.close();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatProfileInfo(
                    chatType: widget.chatType,
                    chatName: widget.name,
                    memberCount: widget.memberCount,
                    chatAvatar:
                        widget.avatar == null ? 'noAvatar.png' : widget.avatar,
                    chatId: widget.chatID,
                  ),
                ),
              ).whenComplete(() {
                setState(() {
                  ChatRoom.shared.getMessages('${widget.chatID}');
                });
              });
            },
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 0,
              color: Colors.transparent,
              textColor: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: ClipOval(
                    child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl: widget.avatar == null
                            ? "${avatarUrl}noAvatar.png"
                            : widget.avatarUrl == null
                                ? avatarUrl + widget.avatar
                                : '${widget.avatarUrl}${widget.avatar.toString().replaceAll('AxB', '200x200')}',
                        errorWidget: (context, url, error) =>
                            CachedNetworkImage(
                                imageUrl: "${avatarUrl}noAvatar.png"))),
              ),
              // padding: EdgeInsets.all(16),
              shape: CircleBorder(),
              onPressed: () {
                ChatRoom.shared.cabinetController.close();
                ChatRoom.shared.setChatInfoStream();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatProfileInfo(
                      chatType: widget.chatType,
                      chatName: widget.name,
                      memberCount: widget.memberCount,
                      chatAvatar: widget.avatar == null
                          ? 'noAvatar.png'
                          : widget.avatar,
                      chatId: widget.chatID,
                    ),
                  ),
                ).whenComplete(() {
                  ChatRoom.shared.getMessages('${widget.chatID}');
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
                  child: const Image(
                    image: chatBackgroundProvider,
                    fit: BoxFit.fill,
                  )),
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
                        child: myList.isEmpty
                            ? Center()
                            : Column(
                                children: [
                                  Expanded(
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
                                        controller: controller,
                                        // itemScrollController: itemScrollController,
                                        // itemPositionsListener: itemPositionsListener,
                                        itemCount: myList.length,
                                        reverse: true,
                                        itemBuilder: (context, i) {
                                          return message(myList[i]);
                                        },
                                      ),
                                    ),
                                  ),
                                  isEditing
                                      ? Container(
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.white,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                        icon: Icon(Icons.edit,
                                                            color: Colors
                                                                .transparent),
                                                        onPressed: null),
                                                    Container(
                                                        width: 2.5,
                                                        height: 45,
                                                        color:
                                                            Color(0xff0543B8)),
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
                                                                          color: Color(
                                                                              0xff0543B8)),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                      softWrap:
                                                                          false))),
                                                          Flexible(
                                                              child: Container(
                                                                  child: Text(
                                                                      "${editMessage["text"]}",
                                                                      overflow:
                                                                          TextOverflow
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
                                                      isEditing = false;
                                                      editMessage = null;
                                                      _text.text = "";
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  isReplying
                                      ? Container(
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.white,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                        icon: Icon(Icons.edit,
                                                            color: Colors
                                                                .transparent),
                                                        onPressed: null),
                                                    Container(
                                                        width: 2.5,
                                                        height: 45,
                                                        color:
                                                            Color(0xff0543B8)),
                                                    Container(width: 5),
                                                    replyMessage[
                                                                "attachment_url"] !=
                                                            null
                                                        ? Container(
                                                            width: 40,
                                                            height: 40,
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  "${replyMessage["attachment_url"]}${json.decode(replyMessage["attachments"])[0]["r_filename"]}",
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
                                                                      "${replyMessage["user_name"]}",
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xff0543B8)),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                      softWrap:
                                                                          false))),
                                                          Flexible(
                                                              child: Container(
                                                                  child: Text(
                                                                      "${replyMessage["type"].toString() == '1' ? "Изображение" : replyMessage["type"].toString() == '4' ? "Видео" : replyMessage["text"]}",
                                                                      overflow:
                                                                          TextOverflow
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
                                                      isReplying = false;
                                                      replyMessage = null;
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  showAttachmentBottomSheet(context);
                                },
                              ),
                              !isRecording
                                  ? Flexible(
                                      child: TextField(
                                        maxLines: 6,
                                        minLines: 1,
                                        controller: _text,
                                        onChanged: (value) {
                                          print("Typing: $value");
                                          if (value == '') {
                                            setState(() {
                                              isTyping = false;
                                            });
                                          } else {
                                            ChatRoom.shared
                                                .typing(widget.chatID);
                                            setState(() {
                                              isTyping = true;
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Image.asset("assets/record.gif",
                                            width: 10, height: 10),
                                        Container(width: 5),
                                        TimerText(dependencies: dependencies),
                                      ],
                                    ),
                              !isTyping
                                  ? ClipOval(
                                      child: GestureDetector(
                                        onLongPress: () async {
                                          print("long press");
                                          bool p = await checkPermission();
                                          if (p) {
                                            startRecord();
                                          }
                                        },
                                        onLongPressUp: () {
                                          print("long press UP");
                                          stopRecord();
                                        },
                                        // onTap: () {
                                        //   startRecord();
                                        // },
                                        // onDoubleTap: () {
                                        //   stopRecord();
                                        // },
                                        child: Center(
                                            child: !isRecording
                                                ? Icon(
                                                    Icons.mic,
                                                    size: 30,
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
                                  : IconButton(
                                      icon: Icon(Icons.send),
                                      onPressed: () {
                                        print(
                                            "new message or editing? editing: $isEditing");
                                        if (isEditing) {
                                          print("Edit message is called");
                                          var mId = editMessage['id'] == null
                                              ? editMessage['message_id']
                                              : editMessage['id'];
                                          var type = editMessage['type'];
                                          var time = editMessage['time'];
                                          ChatRoom.shared.editMessage(
                                              _text.text,
                                              widget.chatID,
                                              type,
                                              time,
                                              mId);
                                          setState(() {
                                            isTyping = false;
                                            _text.text = '';
                                            isEditing = false;
                                            editMessage = null;
                                          });
                                        } else if (isReplying) {
                                          print("Reply message is called");
                                          var mId = replyMessage['id'] == null
                                              ? replyMessage['message_id']
                                              : replyMessage['id'];
                                          ChatRoom.shared.replyMessage(
                                              _text.text,
                                              widget.chatID,
                                              10,
                                              mId);
                                          setState(() {
                                            isTyping = false;
                                            _text.text = '';
                                            isReplying = false;
                                            replyMessage = null;
                                          });
                                        } else {
                                          ChatRoom.shared.sendMessage(
                                              '${widget.chatID}', _text.text);
                                          setState(() {
                                            isTyping = false;
                                            _text.text = '';
                                          });
                                        }
                                      },
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isRecording
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
        )),
      ),
    );
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      Vibration.vibrate();
      statusText = "Recording...";
      recordFilePath = await getAudioFilePath();
      isComplete = false;
      isRecording = true;

      print("RECORD FILE PATH $recordFilePath");
      dependencies.stopwatch.start();

      RecordMp3.instance.start(recordFilePath, (type) {
        statusText = "Record error--->$type";
        setState(() {});
      });
    } else {
      print("No microphone permission");
      statusText = "No microphone permission";
    }
    setState(() {});
  }

  void pauseRecord() {
    if (RecordMp3.instance.status == RecordStatus.PAUSE) {
      bool s = RecordMp3.instance.resume();
      if (s) {
        statusText = "Recording...";
        setState(() {});
      }
    } else {
      bool s = RecordMp3.instance.pause();
      if (s) {
        statusText = "Recording pause...";
        setState(() {});
      }
    }
  }

  void stopRecord() {
    bool s = RecordMp3.instance.stop();
    if (s) {
      statusText = "Record complete";
      isComplete = true;
      isRecording = false;
      dependencies.stopwatch.stop();
      dependencies = new Dependencies();

      api.uploadMedia(recordFilePath, 3).then((r) async {
        print("RRRRR ${r["message"]}");
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
          showAlertDialog(context, r["message"]);
          print("error");
        }
      });

      setState(() {});
    }
  }

  void resumeRecord() {
    bool s = RecordMp3.instance.resume();
    if (s) {
      statusText = "Recording...";
      setState(() {});
    }
  }

  String recordFilePath;

  void play() async {
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(recordFilePath, isLocal: true);

      Directory storageDirectory = await getApplicationDocumentsDirectory();
      String sdPath = storageDirectory.path + "/record";
      var dir = Directory(sdPath);
      dir.deleteSync(recursive: true);
    }
  }

  int i = 0;

  Future<String> getAudioFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/temple.mp3";
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

  Widget message(m) {
    bool isGroup = int.parse("${widget.memberCount}") > 2 ? true : false;
    // return DeviderMessageWidget(date: 'test');
    if ('${m['id']}' == 'chat:message:create' ||
        '${m['type']}' == '7' ||
        '${m['type']}' == '8') return Devider(m);
    return '${m['user_id']}' == '${user.id}'
        ? Sended(m, chatId: widget.chatID)
        : Received(m, chatId: widget.chatID, isGroup: isGroup);
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

  String time(timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    TimeOfDay roomBooked = TimeOfDay.fromDateTime(DateTime.parse('$date'));
    return '${roomBooked.hour}:${roomBooked.minute}';
  }
}
