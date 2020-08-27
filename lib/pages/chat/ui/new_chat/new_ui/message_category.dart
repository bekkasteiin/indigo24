import 'package:flutter/material.dart';

import '../divider_message.dart';
import '../received_message.dart';
import '../sended_message.dart';

class MessageCategoryWidget extends StatefulWidget {
  final int messageCategory;
  final String avatar;
  final Widget child;

  const MessageCategoryWidget({
    Key key,
    this.messageCategory,
    this.avatar,
    this.child,
  }) : super(key: key);
  @override
  _MessageCategoryWidgetState createState() => _MessageCategoryWidgetState();
}

class _MessageCategoryWidgetState extends State<MessageCategoryWidget> {
  @override
  Widget build(BuildContext context) {
    switch (widget.messageCategory) {
      case 0:
        return ReceivedMessageWidget(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 5),
                child: CircleAvatar(
                  child: Image.network(widget.avatar),
                ),
              ),
              widget.child,
            ],
          ),
        );
        break;
      case 1:
        return DividerMessageWidget(child: widget.child);
        break;
      case 2:
        return SendedMessageWidget(child: widget.child);
        break;
      default:
        return Text('default category');
    }
  }
}
