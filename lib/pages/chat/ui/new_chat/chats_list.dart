import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:indigo24/db/chats_db.dart';
import 'package:indigo24/db/chats_model.dart';
import 'package:indigo24/pages/chat/ui/new_chat/chat.dart';
import 'package:indigo24/pages/chat/ui/new_widgets/new_widgets.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/helpers/day_helper.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/pages/chat/ui/new_extensions.dart';
import 'package:indigo24/widgets/alerts.dart';

import '../../chat_contacts.dart';
import '../../chat_group_selection.dart';
// import '../../chat_list.dart';

class TestChatsListPage extends StatefulWidget {
  @override
  _TestChatsListPageState createState() => _TestChatsListPageState();
}

class _TestChatsListPageState extends State<TestChatsListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool _isChatsLoading;
  int _chatsPage;
  List _chatsList;

  @override
  void initState() {
    super.initState();
    ChatRoom.shared.setNewChatsStream();
    listen();
    _isChatsLoading = false;
    _chatsList = [];
    _chatsPage = 1;
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadMore() {
    setState(() {
      _isChatsLoading = true;
    });
    ChatRoom.shared.forceGetChat();
  }

  ListTile _chatListTile(chat) {
    return ListTile(
      onTap: () {
        print('get message');
        ChatRoom.shared.getMessages(chat['id']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: int.parse(chat['id'].toString()),
              chatName: chat['name'],
              chatType: int.parse(chat['type'].toString()),
              userIds: chat['another_user_id'].toString(),
            ),
          ),
        );
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          height: 50,
          width: 50,
          color: greyColor,
          child: ClipOval(
            child: Image.network(
              (chat["avatar"] == null ||
                      chat["avatar"] == '' ||
                      chat["avatar"] == false)
                  ? '${chat['type'].toString() == '1' ? groupAvatarUrl : avatarUrl}noAvatar.png'
                  : '${chat['type'].toString() == '1' ? groupAvatarUrl : avatarUrl}${chat["avatar"].toString().replaceAll("AxB", "200x200")}',
            ),
          ),
        ),
      ),
      title: Text(
        chat["name"].toString().capitalize(),
        maxLines: 1,
        style: TextStyle(color: blackPurpleColor, fontWeight: FontWeight.w400),
      ),
      subtitle: Text(
        chat["last_message"].toString().length != 0
            ? chat["last_message"]['text'].toString().length != 0
                ? "${chat["last_message"]['text'].toString()[0].toUpperCase() + chat["last_message"]['text'].toString().substring(1)}"
                : chat["last_message"]['message_for_type'] != null
                    ? "${chat["last_message"]['message_for_type'][0].toUpperCase() + chat["last_message"]['message_for_type'].substring(1)}"
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
            chat['last_message']["time"] == null
                ? "null"
                : _time(chat['last_message']["time"]),
            style: TextStyle(
              color: blackPurpleColor,
            ),
            textAlign: TextAlign.right,
          ),
          chat['unread_messages'] == 0
              ? Container()
              : Container(
                  decoration: BoxDecoration(
                      color: brightGreyColor4,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    " ${chat['unread_messages']} ",
                    style: TextStyle(color: Colors.white),
                  ),
                )
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: indigoAppBar(
        context,
        elevation: 0.5,
        title: Text(
          localization.chats,
          style: TextStyle(
            fontSize: 22.0,
            color: blackPurpleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Container(
              height: 20,
              width: 20,
              child: Image(
                image: AssetImage(
                  'assets/images/contacts.png',
                ),
              ),
            ),
            iconSize: 30,
            color: blackPurpleColor,
            onPressed: () {
              ChatRoom.shared.setChatUserProfileInfoStream();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatContactsPage(),
                ),
              ).whenComplete(
                () {
                  ChatRoom.shared.forceGetChat();
                },
              );
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10),
            child: ButtonTheme(
              height: 0,
              child: RaisedButton(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${localization.createGroup}',
                        style: TextStyle(color: blackPurpleColor),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 10,
                        width: 10,
                        child: Image(
                          image: AssetImage(
                            'assets/images/add.png',
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 20,
                        child: Image(
                          image: AssetImage(
                            'assets/images/group.png',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textColor: blackPurpleColor,
                color: whiteColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatGroupSelection(),
                    ),
                  );
                },
              ),
            ),
          ),
          _chatsList.isEmpty
              ? InkWell(
                  onTap: () {
                    print("чат");
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatContactsPage()))
                        .whenComplete(() {
                      // ChatRoom.shared.contactController.close();
                      // this is bool for check load more is needed or not
                      ChatRoom.shared.forceGetChat();

                      ChatRoom.shared.closeContactsStream();
                    });
                  },
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Image.asset("assets/chat_animation.gif"),
                          Container(
                            child: Text(
                              "${localization.noChats} \n${localization.clickToStart}",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!_isChatsLoading &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      _loadMore();
                    }
                  },
                  child: Flexible(
                    child: ScrollablePositionedList.builder(
                      itemCount: _chatsList.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption:
                                  '${_chatsList[i]['mute'].toString() == '0' ? localization.mute : localization.unmute}',
                              color: _chatsList[i]['mute'].toString() == '0'
                                  ? redColor
                                  : Colors.grey,
                              icon: _chatsList[i]['mute'].toString() == '0'
                                  ? Icons.volume_mute
                                  : Icons.settings_backup_restore,
                              onTap: () {
                                _chatsList[i]['mute'].toString() == '0'
                                    ? ChatRoom.shared
                                        .muteChat(_chatsList[i]['id'], 1)
                                    : ChatRoom.shared
                                        .muteChat(_chatsList[i]['id'], 0);

                                ChatRoom.shared.forceGetChat();
                              },
                            ),
                            IconSlideAction(
                              caption: '${localization.delete}',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () {
                                indigoCupertinoDialogAction(
                                  context,
                                  '${localization.delete} ${localization.chat} ${_chatsList[i]['name']}?',
                                  isDestructiveAction: true,
                                  rightButtonText: localization.delete,
                                  rightButtonCallBack: () {
                                    ChatRoom.shared
                                        .deleteChat(_chatsList[i]['id']);
                                    Navigator.pop(context);
                                  },
                                );
                                ChatRoom.shared.forceGetChat();
                              },
                            )
                          ],
                          child: _chatListTile(_chatsList[i]),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  listen() {
    ChatRoom.shared.onNewChatsChange.listen((e) async {
      var cmd = e.json["cmd"];
      var data = e.json["data"];
      print('C12312312HAT L123123ISTS M3123123AIN 12312312 ${e.json}');

      switch (cmd) {
        case "chats:get":
          setState(() {
            _chatsList = data;
          });
          _chatsPage++;
          _isChatsLoading = false;

          break;
        // case 'message:create':
        // print(e.json["data"]);
        // var senderId = e.json["data"]['user_id'].toString();
        // var userId = user.id.toString();
        // print('message create');
        // if (senderId != userId) {
        //   inAppPush(e.json["data"]);
        // }
        // break;
        // case 'chats:get':
        // setState(() {
        // this is bool for check load more is needed or not
        // if (globalBoolForForceGetChat == true) {
        // e.json['data'].toList().forEach((element) {
        // myList.add(element);
        // });
        // } else {
        // myList = e.json['data'].toList();
        // myList.map((element) {
        //   updateOrInsertChat(ChatsModel.fromJson(element));
        // }).toList();
        // }
        // chatsPage += 1;
        // });
        // break;
        // case 'user:check':
        // var data = e.json["data"];
        // if (data['status'].toString() == 'true') {
        //   // MyContact contact = MyContact(
        //   //   phone: data['phone'],
        //   //   id: data['user_id'],
        //   //   avatar: data['avatar'],
        //   //   name: data['name'],
        //   //   chatId: data['chat_id'],
        //   //   online: data['online'],
        //   // );
        //   // await _contactsDB.updateOrInsert(contact);
        // }
        // break;
        case "chat:delete":
          ChatRoom.shared.forceGetChat();
          break;
        case "chat:mute":
          ChatRoom.shared.forceGetChat();
          break;
        default:
          print("default in main ${e.json}");
          break;
      }
    });
  }

  ChatsDB _chatsDB = ChatsDB();

  Future _getChats() async {
    Future<List<ChatsModel>> chats = _chatsDB.getAllSortedByTime();
    chats.then((value) {
      setState(() {
        value.forEach((element) {
          _chatsList.add(element.toJson());
        });
      });
    });
  }
}
