import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/user.dart' as user;
import 'chat_page_view_test.dart';

class ChatPage extends StatefulWidget {
  final name;
  final chatID;
  ChatPage(this.name, this.chatID);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List myList = [];
  TextEditingController _text = new TextEditingController();

  @override
  initState() {
    super.initState();
    ChatRoom.shared.setCabinetStream();
    listen();
  }

  int pageCounter = 1;

  listen() {
    ChatRoom.shared.onCabinetChange.listen((e) {
      print("CABINET EVENT");
      print(e.json);
      var cmd = e.json['cmd'];
      switch (cmd) {
        case "chat:get":
          if (pageCounter == 1) {
            setState(() {
              myList = e.json['data'].toList();
            });
          } else {
            setState(() {
              myList = e.json['data'].reversed.toList();
            });
          }

          break;
        case "message:create":
          var message = e.json['data'];
          setState(() {
            ChatRoom.shared.lastMessage = message;
            myList.insert(0, message);
          });
          break;

        default:
      }
    });
  }

  bool isLoading = false;

  getMessages(String chatID) {
    print("getMessages is called");

    var data = json.encode({
      "cmd": 'chat:get',
      "data": {
        "chat_id": "$chatID",
        "user_id": "113626",
        "userToken": "113626",
        "page": pageCounter,
      }
    });
    ChatRoom.shared.channel.sink.add(data);
  }

  Future _loadData() async {
    // perform fetching data delay
    pageCounter++;
    setState(() {
      isLoading = false;
      getMessages(widget.chatID);
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
        title: Text("${widget.name}", style: TextStyle(color: Colors.black)),
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
                          image: AssetImage(
                              'assets/images/background_chat.png'),
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
                                  }),
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
