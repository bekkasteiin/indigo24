import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat/ui/new_chat/message.dart';
import 'package:indigo24/pages/chat/ui/new_widgets/new_widgets.dart';
import 'package:indigo24/pages/chat/ui/new_extensions.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/user.dart' as user;
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/widgets/backgrounds.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatPage extends StatefulWidget {
  final int chatId;
  final int chatType;
  final String chatName;

  const ChatPage({
    Key key,
    this.chatId,
    this.chatType,
    this.chatName,
  }) : super(key: key);
  @override
  _NewChatPageState createState() => _NewChatPageState();
}

class _NewChatPageState extends State<ChatPage> {
  bool _sending;

  int _messagesPage;
  List _messagesList;
  bool _isMessagesLoading;
  TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _sending = false;
    _isMessagesLoading = false;
    _messagesPage = 1;
    _messagesList = [];
    _messageController = TextEditingController();
    ChatRoom.shared.setNewChatStream();
    listen();
    ChatRoom.shared.getMessages(widget.chatId, page: _messagesPage);
  }

  @override
  void dispose() {
    ChatRoom.shared.closeNewChatStream();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: indigoAppBar(
        context,
        title: Text(
          widget.chatName.capitalize(),
          style: TextStyle(
            color: blackPurpleColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      backgroundColor: greyColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: user.chatBackground == 'ligth'
                  ? AssetImage("assets/images/background_chat.png")
                  : AssetImage("assets/images/background_chat_2.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!_isMessagesLoading &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    _loadMore();
                  }
                },
                child: Expanded(
                  child: ScrollablePositionedList.builder(
                    itemCount: _messagesList.length,
                    reverse: true,
                    itemBuilder: (BuildContext context, int i) {
                      var message = _messagesList[i];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 5,
                        ),
                        child: MessageWidget(
                          messageCategory: identifyCategory(
                            int.parse(
                              message['user_id'],
                            ),
                          ),
                          chatType: widget.chatType,
                          message: message,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                color: whiteColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.attach_file),
                      onPressed: () {
                        print("Прикрепить 2");
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                    ),
                    Flexible(
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 6,
                        minLines: 1,
                        controller: _messageController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.all(0),
                        ),
                        onChanged: (value) {
                          if (!_sending) {
                            ChatRoom.shared.typing(widget.chatId);
                            _sending = true;
                            Future.delayed(Duration(seconds: 3), () {
                              _sending = false;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          ChatRoom.shared.sendMessage(
                            widget.chatId,
                            _messageController.text,
                          );
                          setState(() {
                            _messageController.text = '';
                          });
                        }
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  identifyCategory(int messageUserId) {
    if (messageUserId == null) {
      return 1;
    } else {
      return messageUserId == int.parse(user.id) ? 2 : 0;
    }
  }

  _loadMore() {
    setState(() {
      _isMessagesLoading = true;
    });

    ChatRoom.shared.getMessages(widget.chatId, page: _messagesPage);
  }

  listen() {
    ChatRoom.shared.onNewChatChange.listen((e) {
      print("NEW CHAT EVENT ${e.json}");
      var cmd = e.json['cmd'];
      var data = e.json['data'];
      switch (cmd) {
        case "chat:get":
          _messagesPage++;
          setState(() {
            _messagesList.addAll(data);
            _isMessagesLoading = false;
          });
          break;
        case "message:create":
          setState(() {
            _messagesList.insert(0, data);
          });
          break;
      }
    });
  }
}
