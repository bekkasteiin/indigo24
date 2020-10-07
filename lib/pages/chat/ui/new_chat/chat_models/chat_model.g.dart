part of 'chat_model.dart';

class ChatAdapter extends TypeAdapter<ChatModel> {
  @override
  final typeId = 0;

  @override
  ChatModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatModel(
      chatId: fields[0] as int,
      chatType: fields[1] as int,
      unreadCount: fields[2] as int,
      isMuted: fields[3] as bool,
      name: fields[4] as String,
      avatar: fields[5] as String,
      messageTime: fields[6] as int,
      messageType: fields[7] as int,
      messagePreview: fields[8] as String,
      messageUsername: fields[9] as String,
      messageAvatar: fields[10] as String,
      messageId: fields[11] as String,
      message: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChatModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.chatId)
      ..writeByte(1)
      ..write(obj.chatType)
      ..writeByte(2)
      ..write(obj.unreadCount)
      ..writeByte(3)
      ..write(obj.isMuted)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.avatar)
      ..writeByte(6)
      ..write(obj.messageTime)
      ..writeByte(7)
      ..write(obj.messageType)
      ..writeByte(8)
      ..write(obj.messagePreview)
      ..writeByte(9)
      ..write(obj.messageUsername)
      ..writeByte(10)
      ..write(obj.messageAvatar)
      ..writeByte(11)
      ..write(obj.messageId)
      ..writeByte(12)
      ..write(obj.message);
  }
}
