import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/pages/chat/chat_pages/chat_info.dart';
import 'package:indigo24/services/constants.dart';
import 'package:indigo24/services/api/socket/socket.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';

import 'message_categories/divider_message.dart';
import 'message_categories/received_message.dart';
import 'message_categories/sended_message.dart';
import 'package:indigo24/services/user.dart' as user;

class MessageCategoryWidget extends StatefulWidget {
  final int messageCategory;
  final int chatId;
  final String avatar;
  final String messageId;
  final Widget child;
  final bool read;
  final int chatType;
  final dynamic message;

  const MessageCategoryWidget({
    Key key,
    this.messageCategory,
    this.avatar,
    this.child,
    this.chatId,
    @required this.messageId,
    @required this.chatType,
    @required this.message,
    this.read,
  }) : super(key: key);
  @override
  _MessageCategoryWidgetState createState() => _MessageCategoryWidgetState();
}

class _MessageCategoryWidgetState extends State<MessageCategoryWidget> {
  @override
  void initState() {
    super.initState();
  }

  final bgChat = AssetImage("assets/images/background_chat.png");
  final bgChat2 = AssetImage("assets/images/background_chat_2.png");

  @override
  Widget build(BuildContext context) {
    switch (widget.messageCategory) {
      case 0:
        if (widget.read == false) {
          ChatRoom.shared.readMessage(widget.chatId, widget.messageId);
        }
        return ReceivedMessageWidget(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.chatType == 1
                  ? Container(
                      padding: EdgeInsets.only(right: 2),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatProfileInfo(
                                chatType: 0,
                                chatName: '${widget.message.username}',
                                chatAvatar: widget.avatar,
                                userId: widget.message.userId,
                              ),
                            ),
                          ).whenComplete(() {
                            // ChatRoom.shared.closeCabinetInfoStream();
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25.0),
                            child: CachedNetworkImage(
                              errorWidget: (context, url, error) =>
                                  Image.network(
                                '${avatarUrl}noAvatar.png',
                              ),
                              imageUrl: avatarUrl +
                                  widget.avatar.replaceAll('AxB', '200x200'),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                      width: 0,
                    ),
              GestureDetector(
                child: widget.child,
                onLongPress: () {
                  _showMessageAction(
                    context,
                    actions: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                          image: DecorationImage(
                            image: user.chatBackground == 'ligth'
                                ? bgChat
                                : bgChat2,
                            fit: BoxFit.cover,
                          ),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: widget.child,
                      ),
                      MessageActionElement(
                        callback: () {
                          ChatRoom.shared.replyingMessage(widget.message);
                          Navigator.pop(context);
                        },
                        title: '${Localization.language.reply}',
                        icon: CupertinoIcons.reply_thick_solid,
                      ),
                      MessageActionElement(
                        callback: () {
                          ChatRoom.shared.localForwardMessage(
                            widget.message.id,
                          );
                          Navigator.pop(context);
                        },
                        title: '${Localization.language.forward}',
                        icon: CupertinoIcons.reply_all,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
        break;
      case 1:
        return DividerMessageWidget(child: widget.child);
        break;
      case 2:
        return GestureDetector(
          onLongPress: () {
            _showMessageAction(
              context,
              actions: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                    image: DecorationImage(
                      image: user.chatBackground == 'ligth' ? bgChat : bgChat2,
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: widget.child,
                ),
                MessageActionElement(
                  callback: () {
                    ChatRoom.shared.replyingMessage(widget.message);
                    Navigator.pop(context);
                  },
                  title: '${Localization.language.reply}',
                  icon: CupertinoIcons.reply_thick_solid,
                ),
                MessageActionElement(
                  callback: () {
                    ChatRoom.shared.localForwardMessage(widget.messageId);
                    Navigator.pop(context);
                  },
                  title: '${Localization.language.forward}',
                  icon: CupertinoIcons.reply_all,
                ),
                widget.message.type == 11 && widget.message.forwardData != null
                    ? SizedBox(height: 0, width: 0)
                    : MessageActionElement(
                        callback: () {
                          ChatRoom.shared.editingMessage(widget.message);
                          Navigator.pop(context);
                        },
                        title: '${Localization.language.edit}',
                        icon: CupertinoIcons.pen,
                      ),
                MessageActionElement(
                  callback: () {
                    ChatRoom.shared.deleteFromAll(
                      widget.chatId,
                      widget.messageId,
                    );
                    Navigator.pop(context);
                  },
                  title: '${Localization.language.delete}',
                  icon: CupertinoIcons.delete,
                ),
              ],
            );
          },
          child: SendedMessageWidget(child: widget.child),
        );
        break;
      default:
        return Text('default category');
    }
  }

  _showMessageAction(context, {List<Widget> actions}) {
    showModalBottomSheet(
      barrierColor: blackPurpleColor.withOpacity(0.3),
      context: context,
      enableDrag: false,
      backgroundColor: transparentColor,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Theme(
            data: ThemeData(
              splashColor: transparentColor,
              highlightColor: transparentColor,
            ),
            child: InkWell(
              onTap: () {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                Navigator.of(context).pop();
              },
              child: SafeArea(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: whiteColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: actions,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MessageActionElement extends StatelessWidget {
  const MessageActionElement({
    Key key,
    @required this.callback,
    @required this.title,
    @required this.icon,
  }) : super(key: key);
  final Function callback;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: FlatButton(
        highlightColor: primaryColor.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: blackPurpleColor,
            ),
            Text('   '),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: blackPurpleColor,
              ),
            )
          ],
        ),
        onPressed: callback,
      ),
    );
  }
}
