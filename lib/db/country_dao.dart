import 'dart:async';

import 'package:sembast/sembast.dart';
import 'DatabaseSetup.dart';
import 'country_model.dart';

class CountryDao {
  static const String folderName = "Countries";
  final _countryFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertOne(Country country) async {
    await _countryFolder.add(await _db, country.toJson());
  }

  Future updateOrInsert(Country country) async {
    await _countryFolder.record(country.id).put(await _db, country.toJson());
  }

  Future insertList(List<Country> countries) async {
    countries.forEach((country) async {
      await _countryFolder.add(await _db, country.toJson());
    });
  }

  Future<List<Country>> getAll() async {
    final recordSnapshot = await _countryFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final countries = Country.fromJson(snapshot.value);
      return countries;
    }).toList();
  }

  Future deleteAll() async {
    await _countryFolder.delete(await _db);
  }
}
