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
        version: 2, // Increase version to 2
        onCreate: _onCreate,
        onUpgrade: _onUpgrade, // Add upgrade handler
        onOpen: (db) {
          developer.log('Database opened successfully', name: 'DBContext');
        },
      );
    } catch (e) {
      developer.log('Error in _initDatabase: $e', name: 'DBContext');
      rethrow;
    }
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    developer.log(
      'Upgrading database from v$oldVersion to v$newVersion',
      name: 'DBContext',
    );

    if (oldVersion < 2) {
      // Add current_donations column to campaign table
      try {
        await db.execute(
          'ALTER TABLE campaign ADD COLUMN current_donations REAL DEFAULT 0.0',
        );
        developer.log(
          'Added current_donations column to campaign table',
          name: 'DBContext',
        );
      } catch (e) {
        developer.log(
          'Error adding current_donations column: $e',
          name: 'DBContext',
        );
        // If error is not about column already existing, rethrow it
        if (!e.toString().contains('duplicate column name')) {
          rethrow;
        }
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      developer.log('Creating database tables...', name: 'DBContext');

      // Create user table
      await db.execute('''
        CREATE TABLE users (
            id TEXT PRIMARY KEY ,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT
        );
      ''');
      developer.log('Users table created', name: 'DBContext');

      // Create campaign table - include current_donations column for new installs
      await db.execute('''
        CREATE TABLE campaign (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            image BLOB,
            donation_goal REAL,
            category TEXT,
            user_id INTEGER,
            current_donations REAL DEFAULT 0.0,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
      developer.log('Campaign table created', name: 'DBContext');
    } catch (e) {
      developer.log('Error creating database tables: $e', name: 'DBContext');
      rethrow;
    }
  }

  // Utility method to reset the database (for testing)
  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'database.db');

    await deleteDatabase(path);
    developer.log('Database deleted', name: 'DBContext');
  }
}
