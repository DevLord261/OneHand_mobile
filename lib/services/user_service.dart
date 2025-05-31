import 'dart:convert';

import 'package:OneHand/data/DB.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class UserService {
  final dbContext = DBContext.instance;

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String id) async {
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
    var randomid = Uuid().v4();
    final db = await dbContext.database;
    password = hashpassword(password);
    return await db.insert('users', {
      'id': randomid,
      'username': username,
      'email': email,
      'password': password, // Note: In a real app, this should be hashed
    });
  }

  // Login user
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await dbContext.database;
    password = hashpassword(password);
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

  String hashpassword(String password) {
    final bytes = utf8.encode(password);
    String hashedpassword = sha256.convert(bytes).toString();
    return hashedpassword;
  }
}
