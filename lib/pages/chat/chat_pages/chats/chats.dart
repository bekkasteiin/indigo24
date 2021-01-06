import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:indigo24/pages/chat/chat_models/chat_model.dart';
import 'package:indigo24/pages/chat/chat_models/hive_names.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/widgets/alerts/indigo_alert.dart';
import 'package:indigo24/widgets/alerts/indigo_show_dialog.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_appbar_widget.dart';
import 'package:indigo24/widgets/indigo_ui_kit/indigo_search_widget.dart';

import '../chat_contacts.dart';
import '../chat_group_selection.dart';
import 'chats_element.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              height: 20,
              width: 20,
              child: Image(
                image: AssetImage(
                  'assets/images/group.png',
                ),
              ),
            ),
            iconSize: 30,
          ),
          title: Text(
            Localization.language.chats,
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
                top: 10.0,
                left: 10.0,
                right: 10,
                bottom: 0,
              ),
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
                return true;
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
                                color: transparentColor,
                                foregroundColor: blackPurpleColor,
                                iconWidget: Container(
                                  child: Center(
                                    child: Image.asset(
                                      numbers.elementAt(i).isMuted == true
                                          ? 'assets/images/muteChat.png'
                                          : 'assets/images/unmuteChat.png',
                                      width: 20,
                                      height: 20,
                                    ),
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
                                color: transparentColor,
                                foregroundColor: blackPurpleColor,
                                iconWidget: Container(
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/deleteChat.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  showIndigoDialog(
                                    context: context,
                                    builder: CustomDialog(
                                      description:
                                          '${Localization.language.delete} ${Localization.language.chat.toLowerCase()} "${numbers.elementAt(i).name}"?',
                                      yesCallBack: () {
                                        ChatRoom.shared.deleteChat(
                                          numbers.elementAt(i).chatId,
                                        );
                                        Navigator.pop(context);
                                      },
                                      noCallBack: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                              )
                            ],
                            child: Column(
                              children: [
                                ChatsElement(
                                  chat: numbers.elementAt(i),
                                ),
                              ],
                            ),
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
    subscription = ChatRoom.shared.chatsStream.listen((e) async {
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
        return Localization.language.textMessage;
        break;
      case 1:
        return Localization.language.photo;
        break;
      case 2:
        return Localization.language.document;
        break;
      case 3:
        return Localization.language.voiceMessage;
        break;
      case 4:
        return Localization.language.video;
        break;
      case 7:
        return Localization.language.systemMessage;
        break;
      // case 8:
      // return 'Дивайдер сообщение';
      // break;
      case 9:
        return Localization.language.location;
        break;
      case 10:
        return Localization.language.reply;
        break;
      case 11:
        return Localization.language.money;
        break;
      case 12:
        return Localization.language.link;
        break;
      case 13:
        return Localization.language.forwardedMessage;
        break;
      default:
        return Localization.language.message;
    }
  }
}
