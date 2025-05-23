import 'package:flutterproject/data/DB.dart';

class UserService {
  final dbContext = DBContext.instance;

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await dbContext.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Get user by username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await dbContext.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Create new user
  Future<int> createUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final db = await dbContext.database;

    return await db.insert('users', {
      'username': username,
      'email': email,
      'password': password, // Note: In a real app, this should be hashed
    });
  }

  // Update user
  Future<int> updateUser(
    int id, {
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? password,
  }) async {
    final db = await dbContext.database;

    final Map<String, dynamic> updates = {};
    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (username != null) updates['username'] = username;
    if (email != null) updates['email'] = email;
    if (password != null) updates['password'] = password;

    if (updates.isEmpty) return 0;

    return await db.update('users', updates, where: 'id = ?', whereArgs: [id]);
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    final db = await dbContext.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Login user
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await dbContext.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [
        username,
        password,
      ], // In a real app, verify hashed password instead
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await dbContext.database;
    return await db.query('users');
  }
}
