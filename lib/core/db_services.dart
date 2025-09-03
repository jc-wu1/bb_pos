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
      singleInstance: true,
      onConfigure: (db) async {
        return await db.execute("PRAGMA foreign_keys = ON");
      },
    );

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tbl_categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      description TEXT
    )
    ''');

    /// is_active = 1 = available, 0 = not available
    await db.execute('''
    CREATE TABLE tbl_menu_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER,
      name TEXT NOT NULL,
      description TEXT,
      img_url TEXT,
      price REAL NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (category_id) REFERENCES tbl_categories(id)
    )
    ''');

    /// status text = OPEN, PAID, CANCELED
    await db.execute('''
    CREATE TABLE tbl_orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_number TEXT NOT NULL UNIQUE,
      customer_name TEXT,
      order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      status TEXT NOT NULL DEFAULT 'OPEN', 
      total_amount REAL DEFAULT 0
    )
    ''');

    await db.execute('''
    CREATE TABLE tbl_order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER NOT NULL,
      menu_item_id INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      subtotal REAL NOT NULL,
      FOREIGN KEY (order_id) REFERENCES tbl_orders(id),
      FOREIGN KEY (menu_item_id) REFERENCES tbl_menu_items(id)
    );
    ''');

    /// method = CASH, CARD, QR, etc.
    await db.execute('''
    CREATE TABLE tbl_payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER NOT NULL,
      payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      amount REAL NOT NULL,
      method TEXT NOT NULL,
      FOREIGN KEY (order_id) REFERENCES tbl_orders(id)
    );
    ''');
  }
}
