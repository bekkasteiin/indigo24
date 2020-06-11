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
  ChatPage(this.name, this.chatID, {this.memberCount});

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
            Text("${widget.name}", style: TextStyle(color: Colors.black)),
            widget.memberCount != 2
                ? Text(
                    'Участников ${widget.memberCount}',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )
                : Text(
                    'был в сети $online',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatProfileInfo(
                    chatName: widget.name,
                    chatAvatar: 'noAvatar.png',
                    chatMembers: widget.memberCount,
                  ),
                ),
              );
            },
          )
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
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //       image: AssetImage(
                    //           'assets/images/background_login.png'),
                    //       fit: BoxFit.cover,
                    //       colorFilter: ColorFilter.linearToSrgbGamma()),
                    // ),
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
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      maxLines: 6,
                      minLines: 1,
                      controller: _text,
                      decoration: InputDecoration(
                        // contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            print('+++++++++++++++___________+++++');
                            ChatRoom.shared
                                .sendMessage('${widget.chatID}', _text.text);
                            setState(() {
                              _text.text = '';
                            });
                          },
                        ),
                        border: InputBorder.none,
                        hintText: "enter your message",
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
    return m['user_id'] == user.id ? Sended(m) : Received(m);
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
    return '${roomBooked.hour}:${roomBooked.minute}';
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
    // messageMinutes = '${roomBooked.minute}';
    return '${roomBooked.hour}:${roomBooked.minute}';
  }
}
