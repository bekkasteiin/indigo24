import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat/chat_models/messages_model.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'package:indigo24/style/colors.dart';

class MessageFrameWidget extends StatefulWidget {
  final Widget child;
  final String time;
  final int messageCategory;
  final bool read;
  final String messageId;
  final int chatId;
  final MessageModel message;
  const MessageFrameWidget({
    Key key,
    this.child,
    this.messageCategory,
    this.time,
    this.read,
    this.message,
    @required this.chatId,
    @required this.messageId,
  }) : super(key: key);
  @override
  _MessageFrameWidgetState createState() => _MessageFrameWidgetState();
}

class _MessageFrameWidgetState extends State<MessageFrameWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.message.type == 14 ? transparentColor : whiteColor,
        borderRadius: identifyBorderRadius(widget.messageCategory),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          widget.child,
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              widget.message.edited
                  ? Text(
                      '${Localization.language.editedMessage} ',
                      style: TextStyle(
                        fontSize: 10,
                        color: blackColor.withOpacity(0.6),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                      width: 0,
                    ),
              Text(
                widget.time,
                style: TextStyle(
                  fontSize: 10,
                  color: blackColor.withOpacity(0.6),
                ),
              ),
              identifyRead(widget.read, widget.messageCategory)
            ],
          )
        ],
      ),
    );
  }

  BorderRadius identifyBorderRadius(int messageCategory) {
    return messageCategory == 0
        ? BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(0),
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          )
        : BorderRadius.only(
            bottomRight: Radius.circular(0),
            bottomLeft: Radius.circular(15),
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          );
  }

  Widget identifyRead(bool read, int messageCategory) {
    if (messageCategory == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: 5),
          read
              ? Icon(
                  Icons.done_all,
                  size: 16,
                  color: brightBlueColor,
                )
              : Icon(
                  Icons.done,
                  size: 16,
                  color: brightBlueColor,
                )
        ],
      );
    } else {
      return SizedBox(height: 0, width: 0);
    }
  }
}
