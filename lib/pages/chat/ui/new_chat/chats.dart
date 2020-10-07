import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:indigo24/pages/chat/ui/new_chat/chat.dart';
import 'package:indigo24/pages/chat/ui/new_widgets/new_widgets.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/helpers/day_helper.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/pages/chat/ui/new_extensions.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';

import '../../chat_contacts.dart';
import '../../chat_group_selection.dart';
import 'chat_models/hive_names.dart';
import 'chat_models/chat_model.dart';

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

  @override
  void initState() {
    super.initState();
    ChatRoom.shared.setNewChatsStream();
    listen();
    _isChatsLoading = false;
    _chatsPage = 2;
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadMore() {
    setState(() {
      _isChatsLoading = true;
    });
    ChatRoom.shared.forceGetChat(page: _chatsPage);
  }

  ListTile _chatListTile(ChatModel chat) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: int.parse(chat.chatId.toString()),
              chatName: chat.name,
              chatType: int.parse(chat.chatType.toString()),
              avatar: chat.avatar,
            ),
          ),
        ).whenComplete(() {
          ChatRoom.shared.forceGetChat();
        });
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          height: 40,
          width: 40,
          color: greyColor,
          child: CachedNetworkImage(
            errorWidget: (context, url, error) => Material(
              child: Image.asset(
                'assets/preloader.gif',
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
            imageUrl: (chat.avatar == null || chat.avatar == '')
                ? '${avatarUrl}noAvatar.png'
                : '$avatarUrl${chat.avatar.toString().replaceAll("AxB", "200x200")}',
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.7,
          ),
        ),
      ),
      title: Text(
        chat.name.toString().capitalize(),
        maxLines: 1,
        style: TextStyle(color: blackPurpleColor, fontWeight: FontWeight.w400),
      ),
      subtitle: Text(
        chat.messagePreview == null ? chat.message : chat.messagePreview,
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
            _time(chat.messageTime),
            style: TextStyle(
              color: blackPurpleColor,
            ),
            textAlign: TextAlign.right,
          ),
          chat.unreadCount == 0
              ? Container()
              : Container(
                  decoration: BoxDecoration(
                      color: brightGreyColor4,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    "${chat.unreadCount}",
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
      appBar: IndigoAppBarWidget(
        elevation: 0.5,
        leading: SizedBox(
          height: 0,
          width: 0,
        ),
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
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!_isChatsLoading &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                _loadMore();
              }
            },
            child: Flexible(
              child: ValueListenableBuilder(
                  valueListenable:
                      Hive.box<ChatModel>(HiveBoxes.chats).listenable(),
                  builder: (context, Box box, widget) {
                    List numbers = box.values.toList();
                    numbers.sort((a, b) {
                      return b.messageTime.compareTo(a.messageTime);
                    });
                    return ScrollablePositionedList.builder(
                      itemCount: numbers.length,
                      itemBuilder: (BuildContext context, int i) {
                        if (numbers.length == 0)
                          return SizedBox(height: 0, width: 0);
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption:
                                  '${numbers.elementAt(i).isMuted == true ? localization.unmute : localization.mute}',
                              color: numbers.elementAt(i).isMuted == true
                                  ? Colors.grey
                                  : redColor,
                              icon: numbers.elementAt(i).isMuted == true
                                  ? Icons.settings_backup_restore
                                  : Icons.volume_mute,
                              onTap: () {
                                numbers.elementAt(i).isMuted == true
                                    ? ChatRoom.shared.muteChat(
                                        numbers.elementAt(i).chatId, 1)
                                    : ChatRoom.shared.muteChat(
                                        numbers.elementAt(i).chatId, 0);
                              },
                            ),
                            IconSlideAction(
                              caption: '${localization.delete}',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () {
                                indigoCupertinoDialogAction(
                                  context,
                                  '${localization.delete} ${localization.chat} ${numbers.elementAt(i).name}?',
                                  isDestructiveAction: true,
                                  rightButtonText: localization.delete,
                                  rightButtonCallBack: () {
                                    ChatRoom.shared.deleteChat(
                                        numbers.elementAt(i).chatId);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            )
                          ],
                          child: _chatListTile(numbers.elementAt(i)),
                        );
                      },
                    );
                  }),
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
      print('Chats list listen $_chatsPage ${e.json}');
      switch (cmd) {
        case "chats:get":
          if (_isChatsLoading) {
            if (data.isNotEmpty) {
              setState(() {
                data.forEach((chat) {
                  Box<ChatModel> contactsBox =
                      Hive.box<ChatModel>(HiveBoxes.chats);
                  contactsBox.put(
                    int.parse(chat['id'].toString()),
                    ChatModel(
                      name: chat['name'] as String,
                      chatId: int.parse(chat['id'].toString()),
                      chatType: chat['type'] as int,
                      avatar: chat['avatar'] as String,
                      isMuted: chat['mute'] == 0 ? false : true,
                      unreadCount: chat['unread_messages'],
                      messageTime:
                          int.parse(chat['last_message']['time'].toString()),
                      messageId: chat['last_message']['message_id'],
                      messageAvatar: chat['last_message']['avatar'] as String,
                      messagePreview:
                          chat['last_message']['message_for_type'] as String,
                      messageUsername: '${chat['last_message']['user_name']}',
                      message: chat['last_message']['text'] as String,
                    ),
                  );
                });
              });
              _chatsPage++;
            }
          } else {
            setState(() {
              data.forEach((chat) {
                Box<ChatModel> contactsBox =
                    Hive.box<ChatModel>(HiveBoxes.chats);
                contactsBox.put(
                  int.parse(chat['id'].toString()),
                  ChatModel(
                    name: chat['name'] as String,
                    chatId: int.parse(chat['id'].toString()),
                    chatType: chat['type'] as int,
                    avatar: chat['avatar'] as String,
                    isMuted: chat['mute'] == 0 ? false : true,
                    unreadCount: chat['unread_messages'],
                    messageTime:
                        int.parse(chat['last_message']['time'].toString()),
                    messageId: chat['last_message']['message_id'],
                    messageAvatar: chat['last_message']['avatar'] as String,
                    messagePreview:
                        chat['last_message']['message_for_type'] as String,
                    messageUsername: '${chat['last_message']['user_name']}',
                    message: chat['last_message']['text'] as String,
                  ),
                );
              });
              _chatsPage = 2;
            });
          }

          _isChatsLoading = false;

          break;
        case "user:writing":
          Box<ChatModel> contactsBox = Hive.box<ChatModel>(HiveBoxes.chats);
          ChatModel updatedChatValue;
          int chatId;
          List<String> typers = [];
          data.forEach((element) {
            updatedChatValue =
                contactsBox.get(int.parse(element['chat_id'].toString()));
            typers.add(element['name']);
            chatId = element['chat_id'];
          });

          String messagePreview = updatedChatValue.messagePreview;

          updatedChatValue.messagePreview = 'Печатает ${typers.join(', ')}';

          Future.delayed(Duration(seconds: 3), () {
            updatedChatValue.messagePreview = messagePreview;
            contactsBox.put(chatId, updatedChatValue);
          });

          contactsBox.put(chatId, updatedChatValue);
          break;

        case "chat:delete":
          Box<ChatModel> contactsBox = Hive.box<ChatModel>(HiveBoxes.chats);
          contactsBox.delete(int.parse(data['chat_id'].toString()));
          break;

        case "chat:mute":
          Box<ChatModel> contactsBox = Hive.box<ChatModel>(HiveBoxes.chats);
          ChatModel updatedChatValue =
              contactsBox.get(int.parse(data['chat_id'].toString()));
          print('updates chat is ${data['chat_id']} $updatedChatValue');
          updatedChatValue.isMuted = '${data['mute']}' == '0' ? true : false;
          contactsBox.put(
              int.parse(data['chat_id'].toString()), updatedChatValue);
          ChatModel updatedChatValue2 =
              contactsBox.get(int.parse(data['chat_id'].toString()));
          print('updates chat is ${data['chat_id']} $updatedChatValue2');
          break;

        default:
          print("default in chats list ${e.json}");
          break;
      }
    });
  }
}
