import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat_info.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'chat_page_view_test.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:indigo24/services/localization.dart' as localization;

var parser = EmojiParser();

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
  ChatPage(this.name, this.chatID, {this.memberCount, this.userIds, this.avatar, this.avatarUrl});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
      
  String statusText = "";
  bool isComplete = false;


  void sendSound(){
    print("Send sound is called");
    final player = AudioCache();
    player.play("sound/msg_out.mp3");
  }

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    print("_onRefresh ");
    // print("_onRefresh ");
    // print("_onRefresh ");
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch

    // await Future.delayed(Duration(milliseconds: 1000));

    // if failed,use loadFailed(),if no data return,use LoadNodata()
    // items.add((items.length+1).toString());
    print("_onLoading ");
    // print("_onLoading ");
    if(mounted)
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

  // [{id: message:27886:346, user_id: 27886, user_name: AdilTest, 
  // avatar: 27886.20200612143047_100x100.jpg, avatar_url: https://media.indigo24.com/avatars/, 
  // text: 40, time: 1591947445, type: 0, write: 0},

// [{id: 145959, user_id: 27886, user_name: AdilTest, 
// avatar: 27886.20200612143047_100x100.jpg, avatar_url: https://media.indigo24.com/avatars/, 
// text: 20, time: 1591947417, type: 0, write: 0},

  listen() {
    ChatRoom.shared.onCabinetChange.listen((e) {
      print("CABINET EVENT");
      print(e.json);
      var cmd = e.json['cmd'];
      switch (cmd) {
        case "chat:get":

          if (page == 1) {
            setState(() {
              page += 1;
              myList = e.json['data'].toList();
            });
          } else {
            print(
                '____________________________________________________________$page');
            setState(() {
              page += 1;
              myList.addAll(e.json['data'].toList());
            });
          }
          break;
        case "message:create":
          var message = e.json['data'];
          if ('${widget.chatID}' == '${e.json['data']['chat_id']}') {
            setState(() {
              ChatRoom.shared.lastMessage = message;
              myList.insert(0, message);
            });
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
        default:
          print('yes');
          print('yes');
          print('yes');
          print('yes');
          print('yes');
          print('yes');
          print('yes');
          print('yes');
          print('yes');
      }
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

  @override
  void dispose() {
    ChatRoom.shared.cabinetController.close();
    controller.removeListener(_scrollListener);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
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
          child: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: <Widget>[
              Text(
                widget.name.length != 0
                    ? "${widget.name[0].toUpperCase() + widget.name.substring(1)}"
                    : "",
                style: TextStyle(
                    color: Color(0xFF001D52), fontWeight: FontWeight.w400),
              ),
              (widget.memberCount > 2)
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
                          ('$online' == 'online' || '$online' == 'offline') ? '$online' : 'был в сети $online', 
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
                  chatAvatar: widget.avatar==null?'noAvatar.png':widget.avatar,
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
                      imageUrl: 
                        widget.avatar==null? "https://indigo24.xyz/uploads/avatars/noAvatar.png" :
                        widget.avatarUrl==null? "https://indigo24.xyz/uploads/avatars/" + widget.avatar : 
                        widget.avatarUrl+widget.avatar,
                      errorWidget: (context, url, error) => CachedNetworkImage(
                        imageUrl: "https://media.indigo24.com/avatars/noAvatar.png"
                      )
                    )
                ),
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
                    chatAvatar: widget.avatar==null?'noAvatar.png':widget.avatar,
                    chatMembers: widget.memberCount,
                    chatId: widget.chatID,
                  ),
                ),
              ).whenComplete(() {});
            },
          ),
          // InkWell(
          //   // child: Image.network('https://indigo24.xyz/uploads/avatars/noAvatar.png'),
          //   child: Container(
          //     padding: EdgeInsets.only(right: 5),
          //     child: CircleAvatar(
          //       radius: 25,
          //       child: ClipOval(
          //           child: CachedNetworkImage(imageUrl: "https://bizraise.pro/wp-content/uploads/2014/09/no-avatar-300x300.png")
          //       ),
          //     ),
          //   ),
          //   onTap: () {
          //     ChatRoom.shared.setChatInfoStream();
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ChatProfileInfo(
          //           chatName: widget.name,
          //           chatAvatar: 'noAvatar.png',
          //           chatMembers: widget.memberCount,
          //           chatId: widget.chatID,
          //         ),
          //       ),
          //     ).whenComplete(() {});
          //   },
          // ),
          // IconButton(
          //   icon: Image.network(
          //       'https://indigo24.xyz/uploads/avatars/noAvatar.png'),
          //   color: Colors.black,
          //   onPressed: () {
          //     ChatRoom.shared.setChatInfoStream();
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ChatProfileInfo(
          //           chatName: widget.name,
          //           chatAvatar: 'noAvatar.png',
          //           chatMembers: widget.memberCount,
          //           chatId: widget.chatID,
          //         ),
          //       ),
          //     ).whenComplete(() {});
          //   },
          // )
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
              child: backgroundForChat
            ),
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
                              child: Text("Loading"),
                            )
                          :  
                          SmartRefresher(
                            enablePullDown: false,
                            enablePullUp: true,
                            // header: WaterDropHeader(),
                            footer: CustomFooter(
                              builder: (BuildContext context,LoadStatus mode){
                                Widget body ;
                                return Container(
                                  height: 55.0,
                                  child: Center(child:body),
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
                  ),
                ),
                Divider(height: 0, color: Colors.black26),
                // SizedBox(
                //   height: 50,
                Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
// <<<<<<< HEAD
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        isComplete?
                        GestureDetector(
                          onTap: () {
                            play();
                          },
                          child: Center(
                            child: Icon(Icons.play_arrow, size: 30,),
                          ),
                        )
                        :
                        IconButton(
                          icon: Icon(Icons.attach_file),
                          onPressed: (){
                            print("Прикрепить");
// =======
//                     padding: const EdgeInsets.only(left: 20, right: 5),
//                     child: TextField(
//                       maxLines: 6,
//                       minLines: 1,
                      
//                       controller: _text,
//                       decoration: InputDecoration(
//                         // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
//                         hintText: "${localization.enterMessage}",  
//                         suffixIcon: IconButton(
//                           icon: Icon(Icons.send),
//                           onPressed: () {
// // <<<<<<< HEAD
// //                             print('+++++++++++++++___________+++++++++++');
// >>>>>>> b6578fee599585a15cf792daf57f65de418dc543
                            
                          },
                        ),
                      
                        !isRecording?Flexible(
                          child: TextField(
                            maxLines: 6,
                            minLines: 1,
                            controller: _text,
                            decoration: InputDecoration(
                              hintText: "${localization.enterMessage}",
                            ),
                            onChanged: (value) {
                              print("Typing: $value");
                              if(value == ''){
                                setState(() {
                                  isTyping = false;
                                });
                              } else {
                                setState(() {
                                  isTyping = true;
                                });
                              }
                            },
                          ),
                        )
                        :
                        GestureDetector(
                          onTap: () {
                            // startRecord();
                          },
                          child: Center(
                            child: Text("Нажмите 2 раза чтобы остановить запись"),
                          ),
                        ),
                        
                        !isTyping?
                            ClipOval(
                              child: GestureDetector(
                                onLongPress: (){
                                  print("long press");
                                },
                                onTap: () {
                                  startRecord();
                                },
                                onDoubleTap: () {
                                  stopRecord();
                                },
                                child: Center(
                                  child: Icon(Icons.mic, size: 30,),
                                ),
                              ),
                            )
                            // IconButton(
                            //   icon: Icon(Icons.mic),
                            //   onPressed: () {
                            //     print("audio pressed");
                            //   },
                            // )
                            :
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () {
                                ChatRoom.shared
                                    .sendMessage('${widget.chatID}', _text.text);
                                setState(() {
                                  isTyping = false;
                                  _text.text = '';
                                });
                              },
                            ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ],
          ),
        )),
    );
  }
  
  Widget message(m) {
    // return DeviderMessageWidget(date: 'test');
    if ('${m['id']}' == 'chat:message:create' || '${m['type']}' == '7') return Devider(m);
    return '${m['user_id']}' == '${user.id}' ? Sended(m) : Received(m);
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
      statusText = "Recording...";
      recordFilePath = await getFilePath();
      isComplete = false;
      isRecording = true;

      RecordMp3.instance.start(recordFilePath, (type) {
        statusText = "Record error--->$type";
        setState(() {});
      });
    } else {
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

  void play() {
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(recordFilePath, isLocal: true);
    }
  }

  int i = 0;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test_${i++}.mp3";
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
  Received(this.m);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-1, 0),
      child: ReceivedMessageWidget(
          content: '${m['text']}',
          time: time('${m['time']}'),
          name: '${m['user_name']}',
          image: (m["avatar"]==null || m["avatar"]=="")? "https://indigo24.xyz/uploads/avatars/noAvatar.png" :
                        m["avatar_url"]==null? "https://indigo24.xyz/uploads/avatars/" + m["avatar"] : 
                        m["avatar_url"]+m["avatar"],
      )
    );
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
  Sended(this.m);
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment(1, 0),
        child: SendedMessageWidget(
          content: '${m['text']}',
          time: time('${m['time']}'),
          write: '${m['write']}',
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
