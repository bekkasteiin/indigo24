import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:indigo24/chat/ui/new_chat/chat_models/chat_model.dart';
import 'package:indigo24/chat/ui/new_chat/chat_models/hive_names.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/helpers/day_helper.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/chat/ui/new_extensions.dart';
import 'package:indigo24/widgets/alerts.dart';
import 'package:indigo24/widgets/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/indigo_search_widget.dart';

import 'chat.dart';
import 'chat_contacts.dart';
import 'chat_group_selection.dart';

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
  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    listen();
    _isChatsLoading = false;
    _chatsPage = 2;
  }

  @override
  void dispose() async {
    super.dispose();
    _searchController.dispose();
    await subscription.cancel();
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
        ).whenComplete(
          () {
            ChatRoom.shared.forceGetChat();
          },
        );
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          height: 40,
          width: 40,
          color: greyColor,
          child: CachedNetworkImage(
            errorWidget: (context, url, error) => Material(
              child: Image.network(
                '${avatarUrl}noAvatar.png',
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
      title: Row(
        children: [
          Flexible(
            child: Text(
              chat.name.toString().capitalize(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: blackPurpleColor, fontWeight: FontWeight.w400),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Center(
                child: chat.isMuted
                    ? Image.asset(
                        'assets/images/unmuteChat.png',
                        width: 10,
                        height: 10,
                      )
                    : null),
          )
        ],
      ),
      subtitle: Text(
        chat.message == 'null' ? chat.messagePreview : chat.message,
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
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: IndigoAppBarWidget(
          elevation: 0.5,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatGroupSelection(),
                ),
              ).whenComplete(
                () {
                  ChatRoom.shared.forceGetChat();
                },
              );
            },
            icon: Container(
              child: Row(
                children: [
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
          ),
          title: Text(
            localization.chats,
            style: TextStyle(
              color: blackPurpleColor,
              fontSize: 22,
              fontWeight: FontWeight.w400,
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
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, left: 10.0, right: 10, bottom: 0),
              child: IndigoSearchWidget(
                onChangeCallback: (value) {
                  setState(() {});
                },
                searchController: _searchController,
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
                      List<ChatModel> numbers = box.values.where((element) {
                        return _searchController.text.isNotEmpty
                            ? element.name
                                .toString()
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase())
                            : true;
                      }).toList();
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
                                color: Colors.transparent,
                                foregroundColor: blackPurpleColor,
                                iconWidget: numbers.elementAt(i).isMuted == true
                                    ? Container(
                                        child: Center(
                                          child: Image.asset(
                                              'assets/images/muteChat.png'),
                                        ),
                                      )
                                    : Container(
                                        child: Center(
                                          child: Image.asset(
                                              'assets/images/unmuteChat.png'),
                                        ),
                                      ),
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
                                color: Colors.transparent,
                                foregroundColor: blackPurpleColor,
                                iconWidget: Container(
                                  child: Center(
                                    child: Image.asset(
                                        'assets/images/deleteChat.png'),
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialog(
                                        description:
                                            '${localization.delete} ${localization.chat} ${numbers.elementAt(i).name}?',
                                        yesCallBack: () {
                                          ChatRoom.shared.deleteChat(
                                            numbers.elementAt(i).chatId,
                                          );
                                          Navigator.pop(context);
                                        },
                                        noCallBack: () {
                                          Navigator.pop(context);
                                        },
                                      );
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
      ),
    );
  }

  StreamSubscription subscription;

  listen() {
    subscription = ChatRoom.shared.onNewChatsChange.listen((e) async {
      var cmd = e.json["cmd"];
      var data = e.json["data"];
      print('CHATS EVENT $cmd');
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
                      isMuted: int.parse(chat['mute'].toString()) == 0
                          ? false
                          : true,
                      unreadCount:
                          int.parse(chat['unread_messages'].toString()),
                      messageTime:
                          int.parse(chat['last_message']['time'].toString()),
                      messageId: chat['last_message']['message_id'],
                      messageAvatar: chat['last_message']['avatar'] as String,
                      messagePreview: identifyMessagePreview(
                          int.parse(chat['last_message']['type'].toString())),
                      messageUsername: '${chat['last_message']['user_name']}',
                      message: chat['last_message']['text'],
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
                    isMuted:
                        int.parse(chat['mute'].toString()) == 0 ? false : true,
                    unreadCount: int.parse(chat['unread_messages'].toString()),
                    messageTime:
                        int.parse(chat['last_message']['time'].toString()),
                    messageId: chat['last_message']['message_id'],
                    messageAvatar: chat['last_message']['avatar'],
                    messagePreview: identifyMessagePreview(
                        int.parse(chat['last_message']['type'].toString())),
                    messageUsername: '${chat['last_message']['user_name']}',
                    message: chat['last_message']['text'],
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
          updatedChatValue.isMuted = '${data['mute']}' == '0' ? true : false;
          contactsBox.put(
              int.parse(data['chat_id'].toString()), updatedChatValue);

          break;

        default:
          print("default in chats list ${e.json}");
          break;
      }
    });
  }

  String identifyMessagePreview(int messageType) {
    switch (messageType) {
      case 0:
        return localization.textMessage;
        break;
      case 1:
        return localization.photo;
        break;
      case 2:
        return localization.document;
        break;
      case 3:
        return localization.voiceMessage;
        break;
      case 4:
        return localization.video;
        break;
      case 7:
        return localization.systemMessage;
        break;
      // case 8:
      // return 'Дивайдер сообщение';
      // break;
      case 9:
        return localization.location;
        break;
      case 10:
        return localization.reply;
        break;
      case 11:
        return localization.money;
        break;
      case 12:
        return localization.link;
        break;
      case 13:
        return localization.forwardedMessage;
        break;
      default:
        return localization.message;
    }
  }
}
