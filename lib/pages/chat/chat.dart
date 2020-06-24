import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indigo24/pages/chat/chat_info.dart';
import 'package:indigo24/services/test_timer.dart';
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
import 'package:vibration/vibration.dart';
import 'chat_page_view_test.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:indigo24/services/localization.dart' as localization;

var parser = EmojiParser();
List listMessages = [];

Image backgroundForChat = Image(
  image: AssetImage('assets/images/background_chat.png'),
  fit: BoxFit.fill,
);

class ChatPage extends StatefulWidget {
  final name;
  final chatID;
  final memberCount;
  final userIds;
  final avatar;
  final avatarUrl;
  ChatPage(this.name, this.chatID,
      {this.memberCount, this.userIds, this.avatar, this.avatarUrl});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Dependencies dependencies =  Dependencies();
  List myList = [];
  TextEditingController _text = new TextEditingController();
  var online;
  ScrollController controller;
  bool isLoaded = false;
  bool isTyping = false;
  bool isRecording = false;
  Api api = Api();
  int page = 1;
  // RefreshController _refreshController = RefreshController();
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  String statusText = "";
  bool isComplete = false;
  bool hasPermission = false;
  bool isEditing = false;
  var editMessage;
  
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  var myFileUrl;
  bool haveFile = false;
  bool isSomeoneTyping = false;
  List typingMembers = [];
  String typingName;

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
    // monitor network fetch

    // await Future.delayed(Duration(milliseconds: 1000));

    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length+1).toString());
    print("_onLoading ");
    // print("_onLoading ");
    if (mounted)
      setState(() {
        print("mounted ");
        // page += 1;
      });
    _loadData();
    _refreshController.loadComplete();
  }

  @override
  initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    print('______________________________');
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

  // [{id: message:27886:346, user_id: 27886, user_name: AdilTest,
  // avatar: 27886.20200612143047_100x100.jpg, avatar_url: https://media.indigo24.com/avatars/,
  // text: 40, time: 1591947445, type: 0, write: 0},

// [{id: 145959, user_id: 27886, user_name: AdilTest,
// avatar: 27886.20200612143047_100x100.jpg, avatar_url: https://media.indigo24.com/avatars/,
// text: 20, time: 1591947417, type: 0, write: 0},

  listen() {
    ChatRoom.shared.onCabinetChange.listen((e) {
      print("CABINET EVENT");
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
            print('____________________________________________________________$page');
            print(e.json['data']);
            setState(() {
              page += 1;
              myList.addAll(e.json['data'].toList());
              listMessages.addAll(e.json['data'].toList());
            });
          }
          break;
        case "message:create":
          var message = e.json['data'];
          print("Message created with data $message");
          if(message['type'].toString() == '1'){
            // setState(() {
            //   uploadingImage = null;
            // });
          }
          if ('${widget.chatID}' == '${e.json['data']['chat_id']}') {
            if(isUploaded){
              setState(() {
                isUploaded = false;
                ChatRoom.shared.lastMessage = message;
                myList.remove(uploadingMessage);
                myList.insert(0, message);
                listMessages.insert(0, message);
              });
            } else{
              setState(() {
                ChatRoom.shared.lastMessage = message;
                myList.insert(0, message);
                listMessages.insert(0, message);
              });
            }
          }

          break;
        case "chat:create":
          ChatRoom.shared.getMessages(widget.chatID);
          break;
        case "user:check:online":
          // print('${e.json['data']['online']}');
          print(e.json);
          setState(() {
            online = '${e.json['data'][0]['online']}';
          });
          break;
        case "user:writing":
          if(e.json['data'][0]['chat_id'].toString() == widget.chatID.toString()){
            setState(() {
              
              typingMembers = e.json['data'].toList();
              for(var i=0; i<typingMembers.length; i++){
                if(typingMembers.length==1){
                  typingName = typingMembers[0]['name'];
                } else {
                  if(i==0){
                    typingName = "${typingMembers[i]['name']}";
                  } else {
                    typingName = "$typingName, ${typingMembers[i]['name']}";
                  }
                }
              }
              if(e.json['data'].toList().length>1){
                typingMembers.forEach((element) {
                  typingName = "$typingName, ${element['name']}";
                });
              }
              
            });
            if(!isSomeoneTyping){
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
            (element['id']==null?element['message_id']:element['id']) == mId
          );
          print("deleting ${e.json}");
          setState(() {
            myList.removeAt(i);
            listMessages.removeAt(i);
          });
          break;
        case "message:edit":
          var mId = e.json['data']['message_id'];
          var i = myList.indexWhere((element) => 
            (element['id']==null?element['message_id']:element['id']) == mId
          );
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

  var uploadingMessage = json.decode(json.encode({
    "type": "uploading",
    "time": "1",
    "user_id": user.id
  }));

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      print(_image);

      // {status: true, write: 0, chat_id: 101, message_id: message:27886:117, 
      // user_id: 27886, time: 1592914094, avatar: 27886.20200623174222_200x200.jpg, 
      // avatar_url: https://indigo24.xyz/uploads/avatars/, user_name: AdilTest, text: tres, type: 0}
      

      final popResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewMedia(
            filePath: pickedFile.path,
          ),
        ),
      ).whenComplete(() {
      });

      if(popResult=="sending"){
        setState(() {
          isUploading = true;
          uploadingImage = _image;
          myList.insert(0, uploadingMessage);
        });

        api.uploadMedia(_image.path, 1).then((r) async {
          print("RRR $r");
          if (r["status"]) {
            var a = [{
              "filename": "${r["file_name"]}",
              "r_filename": "${r["resize_file_name"]}"
            }];
            setState(() {
              isUploaded = true;
            });
            ChatRoom.shared.sendMessage('${widget.chatID}', "image", type: 1, attachments: jsonDecode(jsonEncode(a)));
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
      
      setState(() {
        isUploading = true;
        myList.insert(0, uploadingMessage);
      });

      api.uploadMedia(_image.path, 4).then((r) async {
        print("RRR $r");
        if (r["status"]) {
          var a = [{
            "filename": "${r["file_name"]}"
          }];
          setState(() {
            isUploaded = true;
          });
          ChatRoom.shared.sendMessage('${widget.chatID}', "video", type: 4, attachments: jsonDecode(jsonEncode(a)));
        } else {
          showAlertDialog(context, r["message"]);
          print("error");
        }
      });
    }
  } 

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
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
      _loadingPath = false;
      _fileName = _path != null
          ? _path.split('/').last
          : _paths != null ? _paths.keys.toString() : '...';

      print("path name $_path");
    });

    api.uploadMedia(_path, 2).then((r) async {
      print("RRR ${r["message"]}");
      if (r["status"]) {
        var a = [{
          "filename": "${r["file_name"]}"
        }];
        ChatRoom.shared.sendMessage('${widget.chatID}', "file", type: 2, attachments: jsonDecode(jsonEncode(a)));
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
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.only(bottom: 80),
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
                                    child: Text('Камера',
                                        style: TextStyle(
                                            color: Color(0xFF001D52),
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                              onPressed: () {
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
                                    child: Text('Деньги',
                                        style: TextStyle(
                                            color: Color(0xFF001D52),
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                print('Деньги');
                                
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
                                    child: Text('Галерея',
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
                                    child: Text('Видео',
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
                                    child: Text('Файлы',
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
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
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
                isSomeoneTyping?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (widget.memberCount > 2)?
                        Text("$typingName ",
                          style: TextStyle(
                                    color: Color(0xFF001D52),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)
                          ):Container(),
                        Text(typingMembers.length>1?"печатают ":"печатает ",
                          style: TextStyle(
                                  color: Color(0xFF001D52),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)
                        ),
                        Image.asset("assets/typing.gif", width: 20,)
                      ],
                    )
                    :
                (widget.memberCount > 2)
                    ? Text(
                        '${localization.members} ${widget.memberCount}',
                        style: TextStyle(
                            color: Color(0xFF001D52),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      )
                    : 
                    online == null
                        ? Container()
                        : Text(
                            ('$online' == 'online' || '$online' == 'offline')
                                ? '$online'
                                : 'был в сети $online',
                            style: TextStyle(
                                color: Color(0xFF001D52),
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
              ],
            ),
            onTap: () {
              ChatRoom.shared.setChatInfoStream();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatProfileInfo(
                    chatName: widget.name,
                    chatAvatar:
                        widget.avatar == null ? 'noAvatar.png' : widget.avatar,
                    chatMembers: widget.memberCount,
                    chatId: widget.chatID,
                  ),
                ),
              ).whenComplete(() {});
            },
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 0,
              color: Colors.transparent,
              textColor: Colors.white,
              child: CircleAvatar(
                radius: 25,
                child: ClipOval(
                    child: CachedNetworkImage(
                        imageUrl: widget.avatar == null
                            ? "https://indigo24.xyz/uploads/avatars/noAvatar.png"
                            : widget.avatarUrl == null
                                ? "https://indigo24.xyz/uploads/avatars/" +
                                    widget.avatar
                                : widget.avatarUrl + widget.avatar,
                        errorWidget: (context, url, error) => CachedNetworkImage(
                            imageUrl:
                                "https://media.indigo24.com/avatars/noAvatar.png"))),
              ),
              // padding: EdgeInsets.all(16),
              shape: CircleBorder(),
              onPressed: () {
                ChatRoom.shared.setChatInfoStream();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatProfileInfo(
                      chatName: widget.name,
                      chatAvatar:
                          widget.avatar == null ? 'noAvatar.png' : widget.avatar,
                      chatMembers: widget.memberCount,
                      chatId: widget.chatID,
                    ),
                  ),
                ).whenComplete(() {});
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
              // Image(
              //   width: MediaQuery.of(context).size.width,
              //   image:
              //       ExactAssetImage('assets/images/background_chat.png'),
              //   fit: BoxFit.cover,
              //   // colorFilter: ColorFilter.linearToSrgbGamma()
              // ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: backgroundForChat),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                // mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Divider(
                    height: 0,
                    color: Colors.black54,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    // height: 500,
                    child: Container(
                      // width: MediaQuery.of(context).size.width,
                      // decoration: BoxDecoration(
                      //   image: DecorationImage(
                      //       image:
                      //           AssetImage('assets/images/background_chat.png'),
                      //       fit: BoxFit.cover,
                      //       colorFilter: ColorFilter.linearToSrgbGamma()),
                      // ),
                      child: Container(
                        child: myList.isEmpty
                            ? Center(
                                child: Image.asset("assets/empty.gif", height: MediaQuery.of(context).size.width / 2,)
                              )
                            : Column(
                              children: [
                                Expanded(
                                  child: SmartRefresher(
                                      enablePullDown: false,
                                      enablePullUp: true,
                                      // header: WaterDropHeader(),
                                      footer: CustomFooter(
                                        builder:
                                            (BuildContext context, LoadStatus mode) {
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
                                        itemCount: myList.length,
                                        reverse: true,
                                        itemBuilder: (context, i) {
                                          return message(myList[i]);
                                        },
                                      ),
                                    ),
                                ),

                                isEditing?Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          // Container(
                                          //   width: MediaQuery.of(context).size.width*0.07,
                                          // ),
                                          IconButton(icon: Icon(Icons.edit, color: Colors.transparent), onPressed: null),
                                          Container(width: 2.5, height: 45, color: Color(0xff0543B8)),
                                          Container(width: 5),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("Редактирование", style: TextStyle(color: Color(0xff0543B8))),
                                              Text("${editMessage["text"]}")
                                            ],
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: (){
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
                                :
                                Container()
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
                                        SystemChannels.textInput.invokeMethod('TextInput.hide');
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
                                            ChatRoom.shared.typing(widget.chatID);
                                            setState(() {
                                              isTyping = true;
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  : 
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Image.asset("assets/record.gif", width: 10, height: 10),
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
                                          if(p){
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
                                          child: !isRecording?
                                          Icon(
                                            Icons.mic,
                                            size: 30,
                                          )
                                          : Container()
                                        ),
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
                                        print("new message or editing? editing: $isEditing");
                                        if(isEditing){
                                          print("Edit message is called");
                                          var mId = editMessage['id']==null?editMessage['message_id']:editMessage['id'];
                                          var type = editMessage['type'];
                                          var time = editMessage['time'];
                                          ChatRoom.shared.editMessage(_text.text, widget.chatID, type, time, mId);
                                          setState(() {
                                              isTyping = false;
                                              _text.text = '';
                                              isEditing = false;
                                              editMessage = null;
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
              isRecording?
              Positioned.fill(
                // top: 100,
                left: MediaQuery.of(context).size.width*0.8,
                child: Image.asset(
                  "assets/voice.gif",
                  // fit: BoxFit.fitWidth,
                  width: 100,
                  height: 100,
                  alignment: Alignment.bottomCenter,
                ),
              )
              :
              Container(),
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


 
  Widget message(m) {
    bool isGroup = int.parse("${widget.memberCount}")>2?true:false;
    // return DeviderMessageWidget(date: 'test');
    if ('${m['id']}' == 'chat:message:create' || '${m['type']}' == '7' || '${m['type']}' == '8')
      return Devider(m);
    return '${m['user_id']}' == '${user.id}' ? Sended(m, chatId: widget.chatID)
    :
    Received(m, chatId: widget.chatID, isGroup: isGroup);
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
          var a = [{
            "filename": "${r["file_name"]}",
          }];
          ChatRoom.shared.sendMessage('${widget.chatID}', "voice", type: 3, attachments: jsonDecode(jsonEncode(a)));
          
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
      title: Text("Ошибка"),
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

class Received extends StatelessWidget {
  final m;
  final chatId;
  final bool isGroup;
  Received(this.m, {this.chatId, this.isGroup});
  @override
  Widget build(BuildContext context) { 
    
    var a = (m['attachments']==false || m['attachments']==null)?false:jsonDecode(m['attachments']);

    return Align(
        alignment: Alignment(-1, 0),
        child: Container(
          child: CupertinoContextMenu(
            actions: [
                // CupertinoContextMenuAction(
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       const Text('Удалить', style: TextStyle(color:Colors.red, fontSize: 14),),
                //       const Icon(CupertinoIcons.delete, color: Colors.red, size: 20)
                //     ],
                //   ),
                //   onPressed: () {
                //     ChatRoom.shared.deleteFromAll(chatId, m['id']==null?m['message_id']:m['id']);
                //     Navigator.pop(context);
                //   },
                // ),
                // CupertinoContextMenuAction(
                //   child: Container(
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         const Text('Редактировать', style: TextStyle(fontSize: 14)),
                //         const Icon(CupertinoIcons.pen, size: 20,)
                //       ],
                //     ),
                //   ),
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                // ),
                CupertinoContextMenuAction(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Ответить', style: TextStyle(fontSize: 14)),
                      const Icon(CupertinoIcons.reply_thick_solid, size: 20)
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              child: Material(
                color: Colors.transparent,
            child: ReceivedMessageWidget(
              content: '${m['text']}',
              time: time('${m['time']}'),
              name: '${m['user_name']}',
              image: (m["avatar"] == null || m["avatar"] == "")
                  ? "https://indigo24.xyz/uploads/avatars/noAvatar.png"
                  : m["avatar_url"] == null
                      ? "https://indigo24.xyz/uploads/avatars/${m["avatar"]}"
                      : "${m["avatar_url"]}${m["avatar"]}",
              type: "${m["type"]}",
              media: (a==false || a==null)? null : a[0]['filename'],
              rMedia: (a==false || a==null)? null : a[0]['r_filename']==null?a[0]['filename']:a[0]['r_filename'],
              mediaUrl: (a==false || a==null)? null : m['attachment_url'],
              edit: "${m["edit"]}",
              isGroup: isGroup,
            ),
          ),)
        ));
  }

  String time(timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    TimeOfDay roomBooked = TimeOfDay.fromDateTime(DateTime.parse('$date'));
    var hours;
    var minutes;
    hours = '${roomBooked.hour}';
    minutes = '${roomBooked.minute}';

    if (roomBooked.hour.toString().length == 1) hours = '0${roomBooked.hour}';
    if (roomBooked.minute.toString().length == 1)
      minutes = '0${roomBooked.minute}';
    return '$hours:$minutes';
  }
}

class Sended extends StatelessWidget {
  final m;
  final chatId;
  Sended(this.m, {this.chatId});
  @override
  Widget build(BuildContext context) {
    var a = (m['attachments']==false || m['attachments']==null)?false:jsonDecode(m['attachments']);
    return Align(
        alignment: Alignment(1, 0),
        child: Container(
          child: CupertinoContextMenu(
            actions: [
                CupertinoContextMenuAction(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Удалить', style: TextStyle(color:Colors.red, fontSize: 14),),
                      const Icon(CupertinoIcons.delete, color: Colors.red, size: 20)
                    ],
                  ),
                  onPressed: () {
                    ChatRoom.shared.deleteFromAll(chatId, m['id']==null?m['message_id']:m['id']);
                    Navigator.pop(context);
                  },
                ),
                CupertinoContextMenuAction(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Редактировать', style: TextStyle(fontSize: 14)),
                        const Icon(CupertinoIcons.pen, size: 20,)
                      ],
                    ),
                  ),
                  onPressed: () {
                    ChatRoom.shared.editingMessage(m);
                    Navigator.pop(context);
                  },
                ),
                CupertinoContextMenuAction(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Ответить', style: TextStyle(fontSize: 14)),
                      const Icon(CupertinoIcons.reply_thick_solid, size: 20)
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                
            ],
            child: Material(
              color: Colors.transparent,
              child: SendedMessageWidget(
                content: '${m['text']}',
                time: time('${m['time']}'),
                write: '${m['write']}',
                type: "${m["type"]}",
                media: (a==false || a==null)? null : a[0]['filename'],
                rMedia: (a==false || a==null)? null : a[0]['r_filename']==null?a[0]['filename']:a[0]['r_filename'],
                mediaUrl: (a==false || a==null)? null : m['attachment_url'],
                edit: "${m["edit"]}"
              ),
            ),
          ),
        ));
  }

  String time(timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    TimeOfDay roomBooked = TimeOfDay.fromDateTime(DateTime.parse('$date'));
    var hours;
    var minutes;
    hours = '${roomBooked.hour}';
    minutes = '${roomBooked.minute}';

    if (roomBooked.hour.toString().length == 1) hours = '0${roomBooked.hour}';
    if (roomBooked.minute.toString().length == 1)
      minutes = '0${roomBooked.minute}';
    return '$hours:$minutes';
  }
}
