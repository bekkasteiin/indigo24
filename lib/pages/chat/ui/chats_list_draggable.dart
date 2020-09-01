import 'package:flutter/material.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/helpers/day_helper.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;

import '../chat.dart';

class ChatListDraggablePage extends StatefulWidget {
  final List messages;

  const ChatListDraggablePage({Key key, this.messages}) : super(key: key);
  @override
  _ChatListDraggablePageState createState() => _ChatListDraggablePageState();
}

class _ChatListDraggablePageState extends State<ChatListDraggablePage> {
  List _chats;
  List _selectedChats;
  @override
  void initState() {
    _selectedChats = [];
    _listen();
    ChatRoom.shared.forceGetChat();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          color: blackPurpleColor,
          icon: Icon(Icons.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          children: <Widget>[
            Text(
              localization.chats,
              style: TextStyle(
                fontSize: 22.0,
                color: blackPurpleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        brightness: Brightness.light,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.send,
              color: blackPurpleColor,
            ),
            onPressed: () {
              if (_selectedChats.isNotEmpty) {
                ChatRoom.shared.getMessages(_selectedChats[0]['id']);
                print(_selectedChats[0]);
                Navigator.pop(context);
                if (_selectedChats.length > 1) {
                  print('listing is 1');
                  List _selectedChatsId = [];
                  _selectedChats.forEach((element) {
                    _selectedChatsId.add(element['id']);
                  });
                  print('this is selected id $_selectedChatsId');
                  ChatRoom.shared.forwardMessage(widget.messages.join(','),
                      'asd', _selectedChatsId.join(','));
                  ChatRoom.shared.forceGetChat();
                  Navigator.pop(context);
                } else {
                  print('listing is else');

                  _goToChat(
                    _selectedChats[0]['name'],
                    _selectedChats[0]['id'],
                    phone: _selectedChats[0]['another_user_phone'],
                    members: _selectedChats[0]['members'],
                    memberCount: _selectedChats[0]['members_count'],
                    chatType: _selectedChats[0]['type'],
                    userIds: _selectedChats[0]['another_user_id'],
                    avatar: _selectedChats[0]['avatar']
                        .toString()
                        .replaceAll("AxB", "200x200"),
                    avatarUrl: _selectedChats[0]['avatar_url'],
                    data: widget.messages,
                  );
                }
              }
            },
          )
        ],
      ),
      body: SizedBox.expand(
        child: Container(
          child: ListView.builder(
            itemCount: _chats != null ? _chats.length : 0,
            itemBuilder: (BuildContext context, int i) {
              return ListTile(
                onTap: () {
                  print('get message');
                  if (_selectedChats.contains(_chats[i])) {
                    setState(() {
                      _selectedChats.remove(_chats[i]);
                    });
                  } else {
                    setState(() {
                      _selectedChats.add(_chats[i]);
                    });
                  }
                },
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.blue),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: _selectedChats.contains(_chats[i])
                              ? Icon(
                                  Icons.check,
                                  size: 15,
                                  color: Colors.white,
                                )
                              : Icon(
                                  Icons.check_box_outline_blank,
                                  size: 15,
                                  color: Colors.blue,
                                ),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Container(
                        height: 50,
                        width: 50,
                        color: greyColor,
                        child: ClipOval(
                          child: Image.network(
                            (_chats[i]["avatar"] == null ||
                                    _chats[i]["avatar"] == '' ||
                                    _chats[i]["avatar"] == false)
                                ? '${_chats[i]['type'].toString() == '1' ? groupAvatarUrl : avatarUrl}noAvatar.png'
                                : '${_chats[i]['type'].toString() == '1' ? groupAvatarUrl : avatarUrl}${_chats[i]["avatar"].toString().replaceAll("AxB", "200x200")}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  _chats[i]["name"].toString().length != 0
                      ? "${_chats[i]["name"][0].toUpperCase() + _chats[i]["name"].substring(1)}"
                      : "",
                  maxLines: 1,
                  style: TextStyle(
                      color: blackPurpleColor, fontWeight: FontWeight.w400),
                ),
                subtitle: Text(
                  _chats[i]["last_message"].toString().length != 0
                      ? _chats[i]["last_message"]['text'].toString().length != 0
                          ? "${_chats[i]["last_message"]['text'].toString()[0].toUpperCase() + _chats[i]["last_message"]['text'].toString().substring(1)}"
                          : _chats[i]["last_message"]['message_for_type'] !=
                                  null
                              ? "${_chats[i]["last_message"]['message_for_type'][0].toUpperCase() + _chats[i]["last_message"]['message_for_type'].substring(1)}"
                              : ""
                      : "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: darkGreyColor2),
                ),
                trailing: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    Text(
                      _chats[i]['last_message']["time"] == null
                          ? "null"
                          : _time(_chats[i]['last_message']["time"]),
                      style: TextStyle(
                        color: blackPurpleColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    _chats[i]['unread_messages'] == 0
                        ? Container()
                        : Container(
                            decoration: BoxDecoration(
                                color: brightGreyColor4,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              " ${_chats[i]['unread_messages']} ",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _listen() {
    ChatRoom.shared.onChatsListDialog.listen((e) {
      print("CABINET LIST DRAGABLE EVENT ${e.json['cmd']}");
      var cmd = e.json['cmd'];
      var data = e.json['data'];
      switch (cmd) {
        case "chats:get":
          print('$data');
          setState(() {
            _chats = data.toList();
          });
          break;

        default:
          print('CABINET LIST DRAGABLE DEFasdasdAULT');
      }
    });
  }

  String _time(timestamp) {
    if (timestamp != null) {
      if (timestamp != '') {
        var messageUnixDate = DateTime.fromMillisecondsSinceEpoch(
          int.parse("$timestamp") * 1000,
        );
        TimeOfDay messageDate =
            TimeOfDay.fromDateTime(DateTime.parse('$messageUnixDate'));
        var hours;
        var minutes;
        hours = '${messageDate.hour}';
        minutes = '${messageDate.minute}';
        var diff = DateTime.now().difference(messageUnixDate);
        if (messageDate.hour.toString().length == 1)
          hours = '0${messageDate.hour}';
        if (messageDate.minute.toString().length == 1)
          minutes = '0${messageDate.minute}';
        if (diff.inDays == 0) {
          return '${localization.today}\n$hours:$minutes';
        } else if (diff.inDays < 7) {
          int weekDay = messageUnixDate.weekday;
          return newIdentifyDay(weekDay) + '\n$hours:$minutes';
        } else {
          return '$messageUnixDate'.substring(0, 10).replaceAll('-', '.') +
              '\n$hours:$minutes';
        }
      }
    }
    return '??:??';
  }

  _goToChat(
    name,
    chatID, {
    phone,
    chatType,
    memberCount,
    userIds,
    avatar,
    avatarUrl,
    members,
    data,
  }) async {
    ChatRoom.shared.setChatStream();
    ChatRoom.shared.checkUserOnline(userIds);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          name,
          chatID,
          phone: phone,
          members: members,
          chatType: chatType,
          memberCount: memberCount,
          userIds: userIds,
          avatar: avatar,
          avatarUrl: avatarUrl,
          data: data,
        ),
      ),
    ).whenComplete(
      () {
        ChatRoom.shared.closeChatStream();
      },
    );
  }
}
