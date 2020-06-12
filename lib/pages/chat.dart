import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat_info.dart';
import 'package:indigo24/services/api.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/user.dart' as user;
import 'chat_page_view_test.dart';

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

  Api api = Api();
  @override
  initState() {
    super.initState();
    ChatRoom.shared.checkUserOnline(widget.userIds);
    listen();
  }

  int pageCounter = 1;

  listen() {
    ChatRoom.shared.onCabinetChange.listen((e) {
      print("CABINET EVENT");
      // print(e.json);
      var cmd = e.json['cmd'];
      switch (cmd) {
        case "chat:get":
          if (pageCounter == 1) {
            setState(() {
              myList = e.json['data'].toList();
            });
          } else {
            print(
                '____________________________________________________________$pageCounter');
            setState(() {
              myList.addAll(e.json['data'].reversed.toList());
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

  bool isLoading = false;

  Future _loadData() async {
    // perform fetching data delay
    pageCounter++;
    setState(() {
      isLoading = false;
      ChatRoom.shared.getMessages(widget.chatID, page: pageCounter);
    });
    print("load more");
    // update data and loading status
  }

  @override
  void dispose() {
    ChatRoom.shared.cabinetController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: <Widget>[
            Text(
              widget.name.length != 0 ? "${widget.name[0].toUpperCase() + widget.name.substring(1)}" : "",
              style: TextStyle(
                  color: Color(0xFF001D52), fontWeight: FontWeight.w400),
            ),
            (widget.memberCount > 2)
                ? Text(
                    'Участников ${widget.memberCount}',
                    style: TextStyle(color: Color(0xFF001D52), fontSize: 14, fontWeight: FontWeight.w400),
                  )
                : Text(
                    'был в сети $online',
                    style: TextStyle(color: Color(0xFF001D52), fontSize: 14, fontWeight: FontWeight.w400),
                  ),
          ],
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
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image:
                              AssetImage('assets/images/background_chat.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.linearToSrgbGamma()),
                    ),
                    child: Container(
                      child: myList.isEmpty
                          ? Center(
                              child: Text("Loading"),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (!isLoading &&
                                    scrollInfo.metrics.pixels ==
                                        scrollInfo.metrics.maxScrollExtent) {
                                  print('start');
                                  _loadData();
                                  setState(() {
                                    isLoading = true;
                                  });
                                }
                              },
                              child: ListView.builder(
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
                            ChatRoom.shared
                                .sendMessage('${widget.chatID}', _text.text);
                            setState(() {
                              _text.text = '';
                            });
                          },
                        ),
                        border: InputBorder.none,
                        hintText: "Введите сообщение",
                      ),
                    ),
                  ),
                ),
                // ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Widget message(m) {
    // return DeviderMessageWidget(date: 'test');
    if (m['id'] == 'chat:message:create') return Devider(m);
    return m['user_id'] == user.id ? Sended(m) : Received(m);
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
