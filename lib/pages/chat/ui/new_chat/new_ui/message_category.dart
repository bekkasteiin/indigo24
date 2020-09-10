import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/services/localization.dart' as localization;
import 'package:indigo24/style/colors.dart';

import '../../../chat_info.dart';
import '../divider_message.dart';
import '../received_message.dart';
import '../sended_message.dart';

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
                      padding: EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        onTap: () {
                          ChatRoom.shared.setChatInfoStream();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatProfileInfo(
                                chatType: 0,
                                chatName: '${widget.message['user_name']}',
                                chatAvatar: widget.avatar,
                                chatId: widget.chatId,
                                phone: widget.message['phone'],
                              ),
                            ),
                          ).whenComplete(() {
                            // ChatRoom.shared.closeCabinetInfoStream();
                          });
                        },
                        child: ClipOval(
                          child: Container(
                            color: greyColor,
                            child: Image.network(
                              widget.avatar.replaceAll('AxB', '200x200'),
                              width: 30,
                              height: 30,
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
                  _showMessageAction(context, actions: [
                    widget.child,
                    Container(
                      height: 50,
                      child: Theme(
                        data: ThemeData(),
                        child: FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                '${localization.reply}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Icon(CupertinoIcons.reply_thick_solid, size: 20)
                            ],
                          ),
                          onPressed: () {
                            ChatRoom.shared.replyingMessage(widget.message);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      child: Theme(
                        data: ThemeData(),
                        child: FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                '${localization.forward}',
                                style: TextStyle(fontSize: 14),
                              ),
                              Icon(CupertinoIcons.reply_all, size: 20)
                            ],
                          ),
                          onPressed: () {
                            print('Файлы');
                            if (widget.message['message_id'] == null) {
                              ChatRoom.shared.localForwardMessage(
                                widget.message['id'],
                              );
                            } else {
                              ChatRoom.shared.localForwardMessage(
                                widget.message['message_id'],
                              );
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ]);
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
            _showMessageAction(context, actions: [
              Container(
                child: widget.child,
              ),
              Container(
                height: 50,
                child: Theme(
                  data: ThemeData(),
                  child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${localization.delete}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Icon(CupertinoIcons.delete, size: 20)
                      ],
                    ),
                    onPressed: () {
                      ChatRoom.shared
                          .deleteFromAll(widget.chatId, widget.messageId);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Container(
                height: 50,
                child: Theme(
                  data: ThemeData(),
                  child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${localization.edit}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Icon(CupertinoIcons.pen, size: 20)
                      ],
                    ),
                    onPressed: () {
                      ChatRoom.shared.editingMessage(widget.message);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Container(
                height: 50,
                child: Theme(
                  data: ThemeData(),
                  child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${localization.reply}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Icon(CupertinoIcons.reply_thick_solid, size: 20)
                      ],
                    ),
                    onPressed: () {
                      ChatRoom.shared.replyingMessage(widget.message);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Container(
                height: 50,
                child: Theme(
                  data: ThemeData(),
                  child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${localization.forward}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Icon(CupertinoIcons.reply_all, size: 20)
                      ],
                    ),
                    onPressed: () {
                      ChatRoom.shared.localForwardMessage(widget.messageId);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ]);
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
      barrierColor: Colors.black.withOpacity(0.2),
      context: context,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
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
                  color: Colors.white.withOpacity(0.9),
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
        );
      },
    );
  }
}
