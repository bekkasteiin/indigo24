import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _ChatsListPageState extends State<ChatsListPage>
    with AutomaticKeepAliveClientMixin {
  bool isOffline = false;

  int _counter = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  goToChat(name, chatID, {memberCount, userIds}) {
    ChatRoom.shared.setCabinetStream();
    ChatRoom.shared.checkUserOnline(userIds);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatPage(name, chatID,
              memberCount: memberCount, userIds: userIds)),
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
        elevation: 0.5,
        title: Text(
          string,
          style: TextStyle(color: Color(0xFF001D52)),
        ),
        brightness: Brightness.light,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.contact_phone),
            iconSize: 30,
            color: Color(0xFF001D52),
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatContactsPage()))
                  .whenComplete(() {
                ChatRoom.shared.contactController.close();
                ChatRoom.shared.forceGetChat();
                ChatRoom.shared.closeContactsStream();
              });
            },
          )
        ],
      ),
      body: Container(child: _listView(context, string)),
    );
  }

  _listView(context, status) {
    return myList.isEmpty
        // ? dbChats.isNotEmpty
        //     ? localChatBuilder(dbChats)
            ? Center(child: CircularProgressIndicator())
        : chatBuilder(myList);
  }

  ListView localChatBuilder(tempList) {
    return ListView.builder(
      itemCount: tempList.length,
      itemBuilder: (context, i) {
        return ListTile(
          onTap: () {
            // ChatRoom.shared.checkUserOnline(ids);
            ChatRoom.shared.getMessages(tempList[i].id);
            goToChat(
              tempList[i].name,
              tempList[i].id,
              memberCount: tempList[i].membersCount,
              userIds: tempList[i].anotherUserID,
            );
          },
          leading: CircleAvatar(
            radius: 25.0,
            backgroundImage: (tempList[i].avatar == null ||
                    tempList[i].avatar == '' ||
                    tempList[i].avatar == false)
                ? CachedNetworkImageProvider(
                    "https://media.indigo24.com/avatars/noAvatar.png")
                : CachedNetworkImageProvider(
                    'https://indigo24.xyz/uploads/avatars/${tempList[i].avatar}'),
          ),
          title: Text(
            tempList[i].name.length != 0
                ? "${tempList[i].name[0].toUpperCase() + tempList[i].name.substring(1)}"
                : "",
            style: TextStyle(
                color: Color(0xFF001D52), fontWeight: FontWeight.w400),
          ),
          subtitle: Text(
            tempList[i].lastMessage.length != 0
                ? "${tempList[i].lastMessage['text'][0].toUpperCase() + tempList[i].lastMessage['text'].substring(1)}"
                : "",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: Color(0xFF5E5E5E)),
          ),
          trailing: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: <Widget>[
              Text(
                tempList[i].lastMessage['time'] == null
                    ? "null"
                    : time(tempList[i].lastMessage['time']),
                style: TextStyle(color: Color(0xFF001D52)),
              ),
              tempList[i].unreadMessage == 0
                  ? Container()
                  : Container(
                      // width: 20,
                      decoration: BoxDecoration(
                          color: Color(0xFFA9C7D2),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(" ${tempList[i].unreadMessage} ",
                          style: TextStyle(color: Colors.white)))
            ],
          ),
        );
      },
    );
  }

  ListView chatBuilder(tempList) {
    return ListView.builder(
      itemCount: tempList.length,
      itemBuilder: (context, i) {
        // print('this is templist INDEX ${tempList[i]}');
        return ListTile(
          onTap: () {
            // ChatRoom.shared.checkUserOnline(ids);
            ChatRoom.shared.getMessages(tempList[i]['id']);
            goToChat(
              tempList[i]['name'],
              tempList[i]['id'],
              memberCount: tempList[i]['members_count'],
              userIds: tempList[i]['another_user_id'],
            );
          },
          leading: CircleAvatar(
            radius: 25.0,
            backgroundImage: (tempList[i]["avatar"] == null ||
                    tempList[i]["avatar"] == '' ||
                    tempList[i]["avatar"] == false)
                ? CachedNetworkImageProvider(
                    "https://media.indigo24.com/avatars/noAvatar.png")
                : CachedNetworkImageProvider(
                    'https://indigo24.xyz/uploads/avatars/${tempList[i]["avatar"]}'),
          ),
          title: Text(
            tempList[i]["name"].length != 0
                ? "${tempList[i]["name"][0].toUpperCase() + tempList[i]["name"].substring(1)}"
                : "",
            style: TextStyle(
                color: Color(0xFF001D52), fontWeight: FontWeight.w400),
          ),
          subtitle: Text(
            tempList[i]["last_message"].length != 0
                ? "${tempList[i]["last_message"]['text'][0].toUpperCase() + tempList[i]["last_message"]['text'].substring(1)}"
                : "",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: Color(0xFF5E5E5E)),
          ),
          trailing: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: <Widget>[
              Text(
                tempList[i]['last_message']["time"] == null
                    ? "null"
                    : time(tempList[i]['last_message']["time"]),
                style: TextStyle(color: Color(0xFF001D52)),
              ),
              tempList[i]['unread_messages'] == 0
                  ? Container()
                  : Container(
                      // width: 20,
                      decoration: BoxDecoration(
                          color: Color(0xFFA9C7D2),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(" ${tempList[i]['unread_messages']} ",
                          style: TextStyle(color: Colors.white)))
            ],
          ),
        );
      },
    );
  }

  String time(timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(
      int.parse('$timestamp') * 1000,
    );
    TimeOfDay roomBooked = TimeOfDay.fromDateTime(DateTime.parse('$date'));
    var hours;
    var minutes;
    // messageMinutes = '${roomBooked.minute}';
    hours = '${roomBooked.hour}';
    minutes = '${roomBooked.minute}';

    if (roomBooked.hour.toString().length == 1) hours = '0${roomBooked.hour}';
    if (roomBooked.minute.toString().length == 1)
      minutes = '0${roomBooked.minute}';
    return '$hours:$minutes';
  }

  @override
  bool get wantKeepAlive => true;
}
