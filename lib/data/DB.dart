import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;

class DBContext {
  // Private constructor
  DBContext._();

  // shared instance
  static final DBContext instance = DBContext._();

  // Database instance
  Database? _database;

  // get database
  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      developer.log('Database initialization error: $e', name: 'DBContext');
      rethrow;
    }
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    try {
      String databasesPath = await getDatabasesPath();
      developer.log('Database path: $databasesPath', name: 'DBContext');
      String path = join(databasesPath, 'database.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) {
          developer.log('Database opened successfully', name: 'DBContext');
        },
      );
    } catch (e) {
      developer.log('Error in _initDatabase: $e', name: 'DBContext');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      developer.log('Creating database tables...', name: 'DBContext');

      // Create user table
      await db.execute('''
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT,
            last_name TEXT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT
        );
      ''');
      developer.log('Users table created', name: 'DBContext');

      // Create campaign table
      await db.execute('''
        CREATE TABLE campaign (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            image BLOB,
            donation_goal REAL,
            category TEXT,
            user_id INTEGER
        );
      ''');
      developer.log('Campaign table created', name: 'DBContext');
    } catch (e) {
      developer.log('Error creating database tables: $e', name: 'DBContext');
      rethrow;
    }
  }
}
