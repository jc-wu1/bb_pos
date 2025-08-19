import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbServices {
  static final DbServices _dbServices = DbServices._internal();

  factory DbServices() => _dbServices;

  DbServices._internal();

  static Database? _database;

  Future<Database> database() async {
    if (_database != null) return _database!;

    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final String dbPath = await getDatabasesPath();

    final completeDbPath = join(dbPath, "jcs_pos_db.db");

    final Database db = await openDatabase(
      completeDbPath,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async {
        return await db.execute("PRAGMA foreign_keys = ON");
      },
    );

    print("Db successfully created!");

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Run the CREATE {breeds} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE breeds(id INTEGER PRIMARY KEY, name TEXT, description TEXT)',
    );
    // Run the CREATE {dogs} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER, color INTEGER, breedId INTEGER, FOREIGN KEY (breedId) REFERENCES breeds(id) ON DELETE SET NULL)',
    );
  }
}
