import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:indigo24/pages/chat/ui/new_chat/divider_message.dart';
import 'package:indigo24/pages/chat/ui/new_chat/new_ui/audio_message.dart';
import 'package:indigo24/pages/chat/ui/new_chat/new_ui/image_message.dart';
import 'package:indigo24/pages/chat/ui/new_chat/new_ui/message_category.dart';
import 'package:indigo24/pages/chat/ui/new_chat/new_ui/service_message.dart';
import 'package:indigo24/pages/chat/ui/new_chat/new_ui/text_message.dart';
import 'package:indigo24/pages/chat/ui/new_chat/new_ui/video_message.dart';
import 'package:indigo24/pages/chat/ui/new_chat/received_message.dart';
import 'package:indigo24/pages/chat/ui/new_chat/sended_message.dart';
import 'package:indigo24/style/colors.dart';
import 'package:indigo24/services/localization.dart' as localization;

import 'new_ui/document_message.dart';
import 'new_ui/forward_message.dart';
import 'new_ui/link_message.dart';
import 'new_ui/message_frame.dart';
import 'new_ui/money_message.dart';
import 'new_ui/reply_message.dart';
import 'new_ui/sticker_message.dart';

class MessageWidget extends StatelessWidget {
  final int messageCategory;
  final int chatType;
  final dynamic message;

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
                message['user_name'],
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
    // return Text('$message');
    switch (messageType) {
      case 0:
        return TextMessageWidget(text: message);
        break;
      case 1:
        return ImageMessageWidget(
          text: '${message['text']}',
          url: message['attachment_url'],
          media: message['attachments'] != null && message['attachments'] != ''
              ? json.decode(message['attachments'])[0]['filename']
              : null,
        );
        break;
      case 2:
        return DocumentMessageWidget(
            text: '${localization.document}: ${localization.error}');
        break;
      case 3:
        return AudioMessageWidget(
          text: '${message['text']}',
          mediaUrl: message['attachment_url'],
          media: json.decode(message['attachments'])[0]['filename'],
        );
        break;
      // case 5:
      //   return ;
      //   break;
      case 4:
        return VideoMessageWidget(
          text: '${message['text']}',
          mediaUrl: message['attachment_url'],
          media: message['attachments'] != null
              ? json.decode(message['attachments'])[0]['filename']
              : null,
        );
        break;
      case 7:
        return DeviderMessageWidget(text: message['text']);
        break;
      case 10:
        return ReplyMessageWidget(text: message);
        break;
      case 11:
        return MoneyMessageWidget(
          amount: message['text'],
          username: message['another_user_name'],
          category: messageCategory,
          userAvatar: message['another_user_avatar'],
        );
        break;
      case 12:
        return LinkMessageWidget(
            url: json.decode(message['attachments'])[0]['link']);
        break;
      case 13:
        return ForwardMessageWidget(text: 'forward: ${message['text']}');
        break;
      case 14:
        return StickerMessage(
            stickerUrl: '${message['attachment_url']}',
            // stickerUrl: 'https://media.chat.indigo24.xyz/media/stickers/',
            sticker: '${json.decode(message['attachments'])[0]['path']}');
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
        avatar: message['avatar_url'] + message['avatar'],
        chatType: chatType,
        messageId:
            message['id'] != null ? message['id'] : message['message_id'],
        read: '${message['write'].toString()}' == '1' ? true : false,
        chatId: int.parse(message['chat_id'].toString()),
        child: MessageFrameWidget(
          message: message,
          messageCategory: messageCategory,
          messageId:
              message['id'] != null ? message['id'] : message['message_id'],
          chatId: int.parse(message['chat_id'].toString()),
          time: time(int.parse(message['time'].toString())),
          read: '${message['write'].toString()}' == '1' ? true : false,
          child: identifyChatType(
            chatType,
            identifyMessageType(
              int.parse(
                message['type'].toString(),
              ),
            ),
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
