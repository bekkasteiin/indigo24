import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat_info.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'chat_page_view_test.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

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
  ChatPage(this.name, this.chatID, {this.memberCount, this.userIds});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List myList = [];
  TextEditingController _text = new TextEditingController();
  var online;
  ScrollController controller;
  bool isLoaded = false;

  Api api = Api();
  int page = 1;
  // RefreshController _refreshController = RefreshController();
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
                      'Участников ${widget.memberCount}',
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
                  chatAvatar: 'noAvatar.png',
                  chatMembers: widget.memberCount,
                  chatId: widget.chatID,
                ),
              ),
            ).whenComplete(() {});
          },
        ),
        actions: <Widget>[
          InkWell(
            child: Image.network(
                'https://indigo24.xyz/uploads/avatars/noAvatar.png'),
            onTap: () {
              ChatRoom.shared.setChatInfoStream();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatProfileInfo(
                    chatName: widget.name,
                    chatAvatar: 'noAvatar.png',
                    chatMembers: widget.memberCount,
                    chatId: widget.chatID,
                  ),
                ),
              ).whenComplete(() {});
            },
          ),
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 5),
                    child: TextField(
                      maxLines: 6,
                      minLines: 1,
                      controller: _text,
                      decoration: InputDecoration(
                        // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                        
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
// <<<<<<< HEAD
//                             print('+++++++++++++++___________+++++++++++');
                            
// =======
// >>>>>>> 222314f78ca2c8bd1c63a5e2b9c9a1fbe7409c5f
                            ChatRoom.shared
                                .sendMessage('${widget.chatID}', _text.text);
                            setState(() {
                              _text.text = '';
                            });
                          },
                        ),
                      ),
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
          image: 'https://indigo24.xyz/uploads/avatars/${m['avatar']}'),
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
