import 'package:sembast/sembast.dart';
import '../db/chats_model.dart';
import 'DatabaseSetup.dart';

class ChatsDB{
  static const String folderName = "Chats";
  final _chatsFolder = intMapStoreFactory.store(folderName);


  Future<Database> get  _db  async => await AppDatabase.instance.database;

  Future insertChat(ChatsModel chat) async{
    await  _chatsFolder.add(await _db, chat.toJson() );
    print('$chat Inserted successfully !!');
  }

  Future insertChats(List<ChatsModel> chats) async{
    chats.forEach((chat) async{ 
      await  _chatsFolder.add(await _db, chat.toJson() );
    });
    
    print('$chats Inserted successfully !!');
  }

  Future<List<ChatsModel>> getAllChats()async{
    final recordSnapshot = await _chatsFolder.find(await _db);
    return recordSnapshot.map((snapshot){
      final chats = ChatsModel.fromJson(snapshot.value);
      return chats;
    }).toList();
  }



  Future deleteAll() async{
    print("Deleted all data from local db");
    await _chatsFolder.delete(await _db);
  }
}