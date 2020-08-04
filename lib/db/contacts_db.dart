import 'package:sembast/sembast.dart';
import '../db/contact.dart';
import 'DatabaseSetup.dart';

class ContactsDB {
  static const String folderName = "Contacts";
  final _contactsFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertOne(MyContact contact) async {
    final finder = Finder(filter: Filter.equals('id', contact.id));
    print("finder $finder");
    await _contactsFolder.add(await _db, contact.toJson());
    // print('$contact Inserted successfully !!');
  }

  Future updateOrInsert(MyContact contact) async {
    await _contactsFolder.record(int.parse('${contact.id}')).put(await _db, contact.toJson());
  }

  Future insertList(List<MyContact> contacts) async {
    contacts.forEach((chat) async {
      await _contactsFolder.add(await _db, chat.toJson());
    });

    print('$contacts Inserted successfully !!');
  }

  Future<List<MyContact>> getAll() async {
    final recordSnapshot = await _contactsFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final contacts = MyContact.fromJson(snapshot.value);
      return contacts;
    }).toList();
  }

  Future deleteAll() async {
    print("Deleted all data from local db");
    await _contactsFolder.delete(await _db);
  }
}
