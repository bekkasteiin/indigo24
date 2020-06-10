import 'dart:async';

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

class _ChatsListPageState extends State<ChatsListPage> {
  bool isOffline = false;

  int _counter = 0;

  @override
  void initState() {
    super.initState();

    // chatsDB.deleteAll();
  }

  @override
  dispose() {
    super.dispose();
  }

  void _incrementCounter() {
    var st = StudentDao();
    Student student =
        Student(name: "Name $_counter", rollNo: _counter, grades: myList);
    st.insertStudent(student);
    Future<List<Student>> students = st.getAllStudents();
    students.then((value) {
      print(value);
    });

    setState(() {
      _counter++;
    });
  }

  goToChat(name, chatID) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(name, chatID)),
    ).whenComplete(() {
      ChatRoom.shared.closeCabinetStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    String string = 'Title';
    return Scaffold(
      appBar: AppBar(
        title: Text(string),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: () {},
          )
        ],
      ),
      body: Container(child: _listView(context, string)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChatContactsPage())).whenComplete(() {
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
                      backgroundImage: NetworkImage(
                          "https://media.indigo24.com/avatars/noAvatar.png"),
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
                      backgroundImage: NetworkImage(
                          "https://media.indigo24.com/avatars/noAvatar.png"),
                    ),
                    title: Text("${myList[i]["name"]}"),
                    subtitle: Text("${myList[i]['last_message']["text"]}"),
                    trailing: Text(myList[i]['last_message']["time"] == null
                        ? "null"
                        : time(myList[i]['last_message']["time"])),
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
}
