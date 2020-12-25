import 'package:flutter/material.dart';
import 'message_category.dart';
import 'package:indigo24/services/localization/localization.dart';
import 'message_frame.dart';
import 'message_types/audio_message.dart';
import 'message_types/document_message.dart';
import 'message_types/forward_message.dart';
import 'message_types/image_message.dart';
import 'message_types/link_message.dart';
import 'message_types/money_message.dart';
import 'message_types/reply_message.dart';
import 'message_types/service_message.dart';
import 'message_types/sticker_message.dart';
import 'message_types/text_message.dart';
import 'message_types/video_message.dart';
import 'package:indigo24/style/colors.dart';

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
                  color: pendingColor,
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
  // const SYSTEM_MESSAGE_DIVIDER_TYPE = 8;
  // const GEO_POINT_MESSAGE_TYPE = 9;
  // const REPLY_MESSAGE_TYPE = 10;
  // const MONEY_MESSAGE_TYPE = 11;
  // const LINK_MESSAGE_TYPE = 12;
  // const FORWARD_MESSAGE_TYPE = 13;

  identifyMessageType(int messageType) {
    switch (messageType) {
      case 0:
        return TextMessageWidget(text: message);
        break;
      case 1:
        return ImageMessageWidget(
          text: '${message.text}',
          media: message.attachments != null && message.attachments != ''
              ? message.attachments[0]['filename']
              : null,
        );
        break;
      case 2:
        return DocumentMessageWidget(
          text:
              '${Localization.language.document}: ${Localization.language.error}',
        );
        break;
      case 3:
        return AudioMessageWidget(
          text: message.text,
          media: message.attachments != null
              ? message.attachments[0]['filename']
              : null,
        );
        break;
      // case 5:
      //   return ;
      //   break;
      case 4:
        return VideoMessageWidget(
          text: '${message.text}',
          media: message.attachments != null
              ? message.attachments[0]['filename']
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
          url: message.attachments[0]['link'],
        );
        break;
      case 13:
        return ForwardMessageWidget(
          text: 'forward: ${message.text}',
        );
        break;
      case 14:
        return StickerMessage(
          sticker: message.attachments[0]['path'],
        );
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
            checkForward(
              child: identifyMessageType(message.type),
            ),
          ),
        ),
      ),
    );
  }

  checkForward({Widget child}) {
    if (message.forwardData != null) {
      return ForwardMessageWidget(
        child: child,
        text: message,
      );
    } else {
      return child;
    }
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
