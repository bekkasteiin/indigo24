import 'dart:async';

import 'package:sembast/sembast.dart';
import '../database.dart';
import 'tape_model.dart';

class TapeDB {
  static const String folderName = "Contacts";
  final _tapeFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertOne(MyTape tape) async {
    await _tapeFolder.add(await _db, tape.toJson());
  }

  Future updateOrInsert(MyTape tape) async {
    await _tapeFolder.record(tape.id).put(await _db, tape.toJson());
  }

  Future insertList(List<MyTape> tapes) async {
    tapes.forEach((chat) async {
      await _tapeFolder.add(await _db, chat.toJson());
    });
  }

  Future<List<MyTape>> getAll() async {
    final recordSnapshot = await _tapeFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final tapes = MyTape.fromJson(snapshot.value);
      return tapes;
    }).toList();
  }

  Future deleteAll() async {
    await _tapeFolder.delete(await _db);
  }
}
