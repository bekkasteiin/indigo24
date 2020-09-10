import 'package:flutter/material.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/pages/chat/ui/new_chat/chat.dart';

class ReplyMessageWidget extends StatefulWidget {
  final text;

  const ReplyMessageWidget({Key key, this.text}) : super(key: key);
  @override
  _ReplyMessageWidgetState createState() => _ReplyMessageWidgetState();
}

class _ReplyMessageWidgetState extends State<ReplyMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.2,
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: GestureDetector(
        onTap: () {
          print(
              'added to find with deleted value ${widget.text['reply_data']}');
          replyMessage = widget.text['reply_data'];
          if (replyMessage != null) {
            print('going to ${(widget.text['reply_data']['is_deleted'])}');

            if (widget.text['reply_data']['is_deleted'] != true) {
              print('going to if');
              ChatRoom.shared.findMessage(widget.text['reply_data']);
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.blue,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        color: whiteColor,
                        margin: EdgeInsets.only(left: 3),
                        padding: EdgeInsets.only(left: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${widget.text['user_name']}',
                            ),
                            Text(
                              '${widget.text['reply_data']['text'].toString() != 'null' ? widget.text['reply_data']['text'].toString() : widget.text['reply_data']['message_text_for_type'].toString()}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              '${widget.text['text'].toString()}',
              maxLines: 35,
            ),
          ],
        ),
      ),
    );
  }
}
