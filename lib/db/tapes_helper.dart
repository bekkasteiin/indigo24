import 'dart:async';

import 'package:sembast/sembast.dart';
import 'DatabaseSetup.dart';

class TapeDB {
  static const String folderName = "Contacts";
  final _tapeFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertOne(MyTape tape) async {
    final finder = Finder(filter: Filter.equals('id', tape.id));
    print("finder $finder");
    await _tapeFolder.add(await _db, tape.toJson());
  }

  Future updateOrInsert(MyTape tape) async {
    await _tapeFolder.record(tape.id).put(await _db, tape.toJson());
  }

  Future insertList(List<MyTape> tapes) async {
    tapes.forEach((chat) async {
      await _tapeFolder.add(await _db, chat.toJson());
    });

    print('$tapes Inserted successfully !!');
  }

  Future<List<MyTape>> getAll() async {
    final recordSnapshot = await _tapeFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final tapes = MyTape.fromJson(snapshot.value);
      return tapes;
    }).toList();
  }

  Future deleteAll() async {
    print("Deleted all data from local db");
    await _tapeFolder.delete(await _db);
  }
}

class MyTape {
  // var avatar;
  // var commentsCount;
  // var created;
  // var description;
  bool isBlocked = false;
  var id;
  // var likes = [];
  // var likesCount;
  // var media;
  // var myLike;
  // var name;
  // var title;
  // var type;

  MyTape({
    this.id,
    this.isBlocked,
    // this.commentsCount,
    // this.avatar,
    // this.created,
    // this.description,
    // this.likes,
    // this.likesCount,
    // this.media,
    // this.myLike,
    // this.name,
    // this.title,
    // this.type,
  });

  factory MyTape.fromJson(Map<String, dynamic> json) => MyTape(
        id: json["id"],
        isBlocked: json['isBlocked'],
        //   commentsCount: json["commentsCount"],
        //   avatar: json["avatar"],
        //   created: json["created"],
        //   description: json["description"],
        //   likes: json["likes"].toList(),
        //   likesCount: json["likesCount"],
        //   media: json["media"],
        //   myLike: json["myLike"],
        //   name: json["name"],
        //   title: json["title"],
        //   type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "isBlocked": isBlocked,
        // commentsCount: commentsCount,
        // avatar: avatar,
        // created: created,
        // description: description,
        // likes: likes,
        // likesCount: likesCount,
        // media: media,
        // myLike: myLike,
        // name: name,
        // title: title,
        // type: type,
      };
}
