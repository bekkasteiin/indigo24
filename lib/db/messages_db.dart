import 'package:sembast/sembast.dart';
import 'DatabaseSetup.dart';
import 'messages_model.dart';

class MessagesDB {
  static const String folderName = "Messages";
  final _messagesFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertMessage(MessagesModel message) async {
    await _messagesFolder.add(await _db, message.toJson());
    print('$message Inserted successfully !!');
  }

  Future updateOrInsert(MessagesModel message) async {
    await _messagesFolder
        .record(int.parse('${message.id}'))
        .put(await _db, message.toJson());
  }

  Future deleteChat(int messageId) async {
    await _messagesFolder.record(messageId).delete(await _db);
  }

  Future insertMessages(List<MessagesModel> messages) async {
    messages.forEach((message) async {
      await _messagesFolder.add(await _db, message.toJson());
    });

    print('$messages Inserted successfully !!');
  }

  Future<List<MessagesModel>> getAllMessages() async {
    final recordSnapshot = await _messagesFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final chats = MessagesModel.fromJson(snapshot.value);
      return chats;
    }).toList();
  }

  Future<List<MessagesModel>> getAllSortedByTime() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('time', false, false),
    ]);

    final recordSnapshots = await _messagesFolder.find(
      await _db,
      finder: finder,
    );

    // Making a List<MessagesModel> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final chats = MessagesModel.fromJson(snapshot.value);
      return chats;
    }).toList();
  }

  Future deleteAll() async {
    print("Deleted all data from local db");
    await _messagesFolder.delete(await _db);
  }
}
