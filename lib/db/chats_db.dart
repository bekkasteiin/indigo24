import 'package:sembast/sembast.dart';
import '../db/chats_model.dart';
import 'DatabaseSetup.dart';

class ChatsDB {
  static const String folderName = "Chats";
  final _chatsFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertChat(ChatsModel chat) async {
    await _chatsFolder.add(await _db, chat.toJson());
    print('$chat Inserted successfully !!');
  }

  Future updateOrInsert(ChatsModel chat) async {
    await _chatsFolder
        .record(int.parse('${chat.id}'))
        .put(await _db, chat.toJson());
  }

  Future deleteChat(int chatId) async {
    await _chatsFolder.record(chatId).delete(await _db);
  }

  Future insertChats(List<ChatsModel> chats) async {
    chats.forEach((chat) async {
      await _chatsFolder.add(await _db, chat.toJson());
    });

    print('$chats Inserted successfully !!');
  }

  Future<List<ChatsModel>> getAllChats() async {
    final recordSnapshot = await _chatsFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final chats = ChatsModel.fromJson(snapshot.value);
      return chats;
    }).toList();
  }

  Future<List<ChatsModel>> getAllSortedByTime() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [
      SortOrder('time', false, false),
    ]);

    final recordSnapshots = await _chatsFolder.find(
      await _db,
      finder: finder,
    );

    // Making a List<ChatsModel> out of List<RecordSnapshot>
    return recordSnapshots.map((snapshot) {
      final chats = ChatsModel.fromJson(snapshot.value);
      return chats;
    }).toList();
  }

  Future deleteAll() async {
    print("Deleted all data from local db");
    await _chatsFolder.delete(await _db);
  }
}
