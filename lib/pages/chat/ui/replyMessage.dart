import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat/chat.dart';
import 'package:indigo24/style/colors.dart';

class ReplyMessage extends StatefulWidget {
  final text;
  final replyData;

  ReplyMessage(this.text, this.replyData);
  @override
  _ReplyMessageState createState() => _ReplyMessageState();
}

class _ReplyMessageState extends State<ReplyMessage> {
  @override
  void initState() {
    super.initState();
    print("Reply data ${widget.replyData}");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              var id = widget.replyData['message_id'];
              int i = listMessages.indexWhere(
                  (e) => e['id'] == null ? e['message_id'] : e['id'] == id);
              print("index of message is $i");
              // ChatRoom.shared.scrolling(i);
            },
            child: Container(
              height: 50,
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 2.5, height: 45, color: primaryColor),
                  Container(width: 5),
                  widget.replyData == null
                      ? Container()
                      : widget.replyData['attachments'] == null
                          ? Container()
                          : Container(
                              width: 40,
                              height: 40,
                              child: Image.network(
                                  "${widget.replyData['attachments_url']}${widget.replyData['attachments']["r_filename"]}"),
                            ),
                  Container(width: 5),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "${widget.replyData == null ? "" : widget.replyData["user_name"]}",
                            style: TextStyle(color: primaryColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false),
                        Text(
                            "${widget.replyData == null ? "" : widget.replyData["message_text_for_type"] == null ? widget.replyData["text"] : widget.replyData["message_text_for_type"]}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text("${widget.text}")
        ],
      ),
    );
  }
}
