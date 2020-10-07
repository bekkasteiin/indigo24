import 'package:hive/hive.dart';
import 'package:indigo24/services/localization.dart';

@HiveType(typeId: 1)
class MessageModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  int chatId;
  @HiveField(2)
  int userId;
  @HiveField(3)
  String avatar;
  @HiveField(4)
  bool read;
  @HiveField(5)
  String username;
  @HiveField(6)
  String text;
  @HiveField(7)
  int type;
  @HiveField(8)
  int time;
  @HiveField(9)
  dynamic attachments;
  @HiveField(10)
  dynamic reply_data;
  @HiveField(11)
  dynamic forward_data;
  @HiveField(12)
  bool edited;
  @HiveField(13)
  dynamic moneyData;

  MessageModel({
    this.id,
    this.chatId,
    this.userId,
    this.avatar,
    this.read,
    this.username,
    this.text,
    this.type,
    this.time,
    this.attachments,
    this.reply_data,
    this.forward_data,
    this.edited,
    this.moneyData,
  });

  toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'userId': userId,
      'avatar': avatar,
      'read': read,
      'username': username,
      'text': text,
      'type': type,
      'time': time,
      'attachments': attachments,
      'reply_data': reply_data,
      'forward_data': forward_data,
      'edited': edited,
      'moneyData': moneyData
    };
  }

  @override
  String toString() =>
      'id: $id + chatId: $chatId + userId: $userId + avatar: $avatar + read: $read + username: $username + text: $text + type: $type + time: $time + attachments: $attachments + reply_data: $reply_data + forward_data: $forward_data + edited: $edited + money: $moneyData';
}
