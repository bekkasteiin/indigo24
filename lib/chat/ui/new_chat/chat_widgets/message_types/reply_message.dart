import 'package:flutter/material.dart';
import 'package:indigo24/chat/ui/new_chat/chat_pages/chat.dart';
import 'package:indigo24/services/socket.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;

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
          replyMessage = widget.text.reply_data;
          if (replyMessage != null) {
            ChatRoom.shared.findMessage(widget.text.reply_data['message_id']);
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
                              '${widget.text.username}',
                            ),
                            widget.text.reply_data != null
                                ? widget.text.reply_data['type'] == 0
                                    ? Text(
                                        '${widget.text.reply_data['text']}',
                                        maxLines: 3,
                                      )
                                    : Text(
                                        '${_identifyType(widget.text.reply_data['type'])}',
                                        maxLines: 3,
                                      )
                                : Text("")
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
              '${widget.text.text}',
              maxLines: 35,
            ),
          ],
        ),
      ),
    );
  }

  _identifyType(type) {
    // const TEXT_MESSAGE_TYPE = 0;
    // const IMAGE_MESSAGE_TYPE = 1;
    // const DOCUMENT_MESSAGE_TYPE = 2;
    // const VOICE_MESSAGE_TYPE = 3;
    // const VIDEO_MESSAGE_TYPE = 4;
    // const SYSTEM_MESSAGE_TYPE = 7;
    // const SYSTEM_MESSAGE_DIVIDER_TYPE = 8;
    // const GEO_POINT_MESSAGE_TYPE = 9;
    // const REPLY_MESSAGE_TYPE = 10;
    // const MONEY_MESSAGE_TYPE = 11;
    // const LINK_MESSAGE_TYPE = 12;
    // const FORWARD_MESSAGE_TYPE = 13;
    switch ('$type') {
      case '0':
        return '${localization.textMessage}';
        break;
      case '1':
        return '${localization.photo}';
        break;
      case '2':
        return '${localization.document}';
        break;
      case '3':
        return '${localization.voiceMessage}';
        break;
      case '4':
        return '${localization.video}';
        break;
      case '7':
        return '${localization.systemMessage}';
        break;
      // case '8':
      // return 'Дивайдер сообщение';
      // break;
      case '9':
        return '${localization.location}';
        break;
      case '10':
        return '${localization.reply}';
        break;
      case '11':
        return '${localization.money}';
        break;
      case '12':
        return '${localization.link}';
        break;
      case '13':
        return '${localization.forwardedMessage}';
        break;
      default:
        return '${localization.message}';
    }
  }
}