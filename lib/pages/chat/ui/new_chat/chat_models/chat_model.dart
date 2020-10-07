import 'package:hive/hive.dart';
part 'chat_model.g.dart';

@HiveType(typeId: 0)
class ChatModel extends HiveObject {
  @HiveField(0)
  int chatId;
  @HiveField(1)
  int chatType;
  @HiveField(2)
  int unreadCount;
  @HiveField(3)
  bool isMuted;
  @HiveField(4)
  String name;
  @HiveField(5)
  String avatar;
  @HiveField(6)
  int messageTime;
  @HiveField(7)
  int messageType;
  @HiveField(8)
  String messagePreview;
  @HiveField(9)
  String messageUsername;
  @HiveField(10)
  String messageAvatar;
  @HiveField(11)
  String messageId;
  @HiveField(12)
  String message;

  ChatModel({
    this.name,
    this.chatId,
    this.chatType,
    this.unreadCount,
    this.isMuted,
    this.avatar,
    this.messageTime,
    this.messageType,
    this.messagePreview,
    this.messageUsername,
    this.messageAvatar,
    this.messageId,
    this.message,
  });

  @override
  String toString() =>
      '$name $chatId $chatType $unreadCount $isMuted $avatar $messageTime $messagePreview $messageUsername $messageAvatar $messageId $message';
}
