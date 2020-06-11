import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:indigo24/db/Student_DAO.dart';
import 'package:indigo24/db/chats_model.dart';
import 'package:indigo24/db/student.dart';
import 'package:indigo24/pages/chat.dart';
import 'package:indigo24/pages/chat_contacts.dart';
import 'package:indigo24/services/socket.dart';

import 'chat_page_view_test.dart';

class ChatsListPage extends StatefulWidget {
  ChatsListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ChatsListPageState createState() => _ChatsListPageState();
}

List<ChatsModel> dbChats = [];
List myList = [];
List<ChatsModel> chatsModel = [];

class _ChatsListPageState extends State<ChatsListPage> with AutomaticKeepAliveClientMixin{
  bool isOffline = false;

  int _counter = 0;

  @override
  void initState() {
    super.initState();

  }

  @override
  dispose() {
    super.dispose();
  }


  goToChat(name, chatID) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(name, chatID)),
    ).whenComplete(() {
      ChatRoom.shared.forceGetChat();
      ChatRoom.shared.closeCabinetStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    String string = 'Чаты';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(string, style: TextStyle(color: Colors.black),),
        brightness: Brightness.light,
      ),
      body: Container(child: _listView(context, string)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatContactsPage()))
              .whenComplete(() {
            ChatRoom.shared.forceGetChat();
            ChatRoom.shared.closeContactsStream();
          });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  _listView(context, status) {
    return status == "Offline"
        ? dbChats.isEmpty
            ? Text("Загрузка")
            : ListView.builder(
                itemCount: dbChats.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    onTap: () {
                      ChatRoom.shared.getMessages(dbChats[i].id);
                      goToChat(dbChats[i].name, dbChats[i].id);
                    },
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider('https://indigo24.xyz/uploads/avatars/${dbChats[i].avatar}')
                      // NetworkImage("https://media.indigo24.com/avatars/noAvatar.png"),
                    ),
                    title: Text(dbChats[i].name),
                    subtitle: Text(dbChats[i].lastMessage["text"]),
                    trailing: Text(dbChats[i].lastMessage["time"] == null
                        ? "null"
                        : time(dbChats[i].lastMessage["time"])),
                  );
                },
              )
        : myList.isEmpty
            ? Text("Загрузка")
            : ListView.builder(
                itemCount: myList.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    onTap: () {
                      ChatRoom.shared.getMessages(myList[i]['id']);
                      goToChat(myList[i]['name'], myList[i]['id']);
                    },
                    leading: CircleAvatar(
                      backgroundImage: (myList[i]["avatar"]==null || myList[i]["avatar"]=='' || myList[i]["avatar"] == false)?
                      CachedNetworkImageProvider("https://media.indigo24.com/avatars/noAvatar.png")
                      :
                      CachedNetworkImageProvider('https://indigo24.xyz/uploads/avatars/${myList[i]["avatar"]}')
                    ),
                    title: Text("${myList[i]["name"]}"),
                    subtitle: Text("${myList[i]['last_message']["text"]}"),
                    trailing: Wrap(
                      direction: Axis.vertical,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        Text(myList[i]['last_message']["time"] == null? 
                        "null" : time(myList[i]['last_message']["time"])
                        ),
                        myList[i]['unread_messages']==0?
                        Container()
                        :
                        Container(
                          // width: 20,
                          decoration: BoxDecoration(
                            color: Colors.blue[300],
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text(" ${myList[i]['unread_messages']} ", style: TextStyle(color: Colors.white))
                        )
                      ],
                    ),
                  );
                },
              );
  }

  String time(timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp) * 1000,
    );
    TimeOfDay roomBooked = TimeOfDay.fromDateTime(DateTime.parse('$date'));
    // messageMinutes = '${roomBooked.minute}';
    return '${roomBooked.hour}:${roomBooked.minute}';
  }

  @override
  bool get wantKeepAlive => true;
}
