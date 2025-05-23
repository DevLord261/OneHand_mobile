import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create your tables here
    // create user tables
    await db.execute('''
      CREATE TABLE users (
          id SERIAL PRIMARY KEY,
          first_name TEXT,
          last_name TEXT,
          username TEXT UNIQUE NOT NULL,
          email TEXT UNIQUE NOT NULL,
          password TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE campaign (
          id SERIAL PRIMARY KEY,
          title TEXT,
          description TEXT,
          image BYTEA,  -- store binary image data
          donation_goal DOUBLE PRECISION,
          category TEXT,
          user_id INT,
          CONSTRAINT fk_organizer FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET CASCADE
      );
      ''');
  }
}
