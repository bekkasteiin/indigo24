import 'package:hive/hive.dart';

import 'messages_model.dart';

class MessagesAdapter extends TypeAdapter<MessageModel> {
  @override
  final typeId = 1;

  @override
  MessageModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return MessageModel(
      id: fields[0] as String,
      chatId: fields[1] as int,
      userId: fields[2] as int,
      avatar: fields[3] as String,
      read: fields[4] as bool,
      username: fields[5] as String,
      text: fields[6] as String,
      type: fields[7] as int,
      time: fields[8] as int,
      attachments: fields[9],
      replyData: fields[10],
      forwardData: fields[11],
      edited: fields[12] as bool,
      moneyData: fields[13],
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chatId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.read)
      ..writeByte(5)
      ..write(obj.username)
      ..writeByte(6)
      ..write(obj.text)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.time)
      ..writeByte(9)
      ..write(obj.attachments)
      ..writeByte(10)
      ..write(obj.replyData)
      ..writeByte(11)
      ..write(obj.forwardData)
      ..writeByte(12)
      ..write(obj.edited)
      ..writeByte(13)
      ..write(obj.moneyData);
  }
}
