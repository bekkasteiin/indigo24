import 'dart:convert';

import 'package:flutter/material.dart';
import '../new_chat/message_types/audio_message.dart';
import '../new_chat/message_types/image_message.dart';
import 'message_category.dart';
import '../new_chat/message_types/service_message.dart';
import '../new_chat/message_types/text_message.dart';
import '../new_chat/message_types/video_message.dart';
import 'package:indigo24/services/localization.dart' as localization;

import '../new_chat/message_types/document_message.dart';
import '../new_chat/message_types/forward_message.dart';
import '../new_chat/message_types/link_message.dart';
import 'message_frame.dart';
import '../new_chat/message_types/money_message.dart';
import '../new_chat/message_types/reply_message.dart';
import '../new_chat/message_types/sticker_message.dart';

class MessageWidget extends StatelessWidget {
  final int messageCategory;
  final int chatType;
  final message;

  const MessageWidget({
    Key key,
    this.messageCategory,
    this.message,
    this.chatType,
  }) : super(key: key);

  identifyChatType(int chatType, Widget child) {
    return chatType == 1 && messageCategory == 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message.username,
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child,
            ],
          )
        : child;
  }

  // const TEXT_MESSAGE_TYPE = 0;
  // const IMAGE_MESSAGE_TYPE = 1;
  // const DOCUMENT_MESSAGE_TYPE = 2;
  // const VOICE_MESSAGE_TYPE = 3;
  // const VIDEO_MESSAGE_TYPE = 4;
  // const SYSTEM_MESSAGE_TYPE = 7;
  // const SYSTEM_MESSAGE_DIVIDER_TYPE = 8; --
  // const GEO_POINT_MESSAGE_TYPE = 9;
  // const REPLY_MESSAGE_TYPE = 10;
  // const MONEY_MESSAGE_TYPE = 11;
  // const LINK_MESSAGE_TYPE = 12;
  // const FORWARD_MESSAGE_TYPE = 13;

  identifyMessageType(int messageType) {
    // print('identifying type $messageType');
    // if (message['forward_data'] != null) {
    //   ForwardMessageWidget(
    //       child: identifyMessageType(
    //         int.parse(
    //           message['type'].toString(),
    //         ),
    //       ),
    //       text: '$message');
    //   return ForwardMessageWidget(text: 'forward: ${message}');
    // }
    switch (messageType) {
      case 0:
        return TextMessageWidget(text: message);
        break;
      case 1:
        return ImageMessageWidget(
          text: '${message.text}',
          media: message.attachments != null && message.attachments != ''
              ? json.decode(message.attachments)[0]['filename']
              : null,
        );
        break;
      case 2:
        return DocumentMessageWidget(
            text: '${localization.document}: ${localization.error}');
        break;
      case 3:
        return AudioMessageWidget(
          text: '${message.text}',
          media: message.attachments != null
              ? json.decode(message.attachments)[0]['filename']
              : null,
        );
        break;
      // case 5:
      //   return ;
      //   break;
      case 4:
        return VideoMessageWidget(
          text: '${message.text}',
          media: '${message.attachments}' != 'null'
              ? json.decode(message.attachments)[0]['filename']
              : null,
        );
        break;
      case 7:
        return DeviderMessageWidget(text: message.text);
        break;
      case 10:
        return ReplyMessageWidget(text: message);
        break;
      case 11:
        return MoneyMessageWidget(
          amount: message.text,
          moneyData: message.moneyData,
          category: messageCategory,
        );
        break;
      case 12:
        return LinkMessageWidget(
            url: json.decode(message.attachments)[0]['link']);
        break;
      case 13:
        return ForwardMessageWidget(text: 'forward: ${message.text}');
        break;
      case 14:
        return StickerMessage(
            sticker: '${json.decode(message.attachments)[0]['path']}');
        break;
      default:
        return Text('default type $messageType');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MessageCategoryWidget(
        message: message,
        messageCategory: messageCategory,
        avatar: message.avatar,
        chatType: chatType,
        messageId: message.id,
        read: message.read,
        chatId: message.chatId,
        child: MessageFrameWidget(
          message: message,
          messageCategory: messageCategory,
          messageId: message.id,
          chatId: message.chatId,
          time: time(message.time),
          read: message.read,
          child: identifyChatType(
            chatType,
            identifyMessageType(message.type),
          ),
        ),
      ),
    );
  }

  time(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    TimeOfDay roomBooked = TimeOfDay.fromDateTime(DateTime.parse('$date'));
    String hours = '${roomBooked.hour}';
    String minutes = '${roomBooked.minute}';

    return '${validate(hours)}:${validate(minutes)}';
  }

  validate(String time) {
    if (time != null && time.length == 1) return '0$time';
    return time;
  }
}
