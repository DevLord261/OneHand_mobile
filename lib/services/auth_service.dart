import 'package:flutterproject/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class AuthService {
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';

  final UserService _userService = UserService();
  final SharedPreferencesAsync asyncpref = SharedPreferencesAsync();

  // Login and save user info
  Future<bool> login(String username, String password) async {
    final user = await _userService.login(username, password);

    if (user != null && user['id'] != null) {
      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(userIdKey, user['id']);
      await prefs.setString(usernameKey, user['username']);

      // Log for debugging
      developer.log(
        'User logged in successfully. ID: ${user['id']}',
        name: 'AuthService',
      );
      return true;
    }
    developer.log('Login failed for username: $username', name: 'AuthService');
    return false;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdKey);
    await prefs.remove(usernameKey);
    developer.log('User logged out successfully', name: 'AuthService');
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    return await _userService.getUserById(userId);
  }

  // Check if user is logged in with a valid user ID
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(userIdKey);
    return userId != null && userId > 0;
  }

  // Get the current user's ID with better validation
  Future<int> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(userIdKey) ?? -1;

    // Log for debugging
    if (userId <= 0) {
      developer.log(
        'No valid user ID found in preferences',
        name: 'AuthService',
      );
    } else {
      developer.log('Retrieved user ID: $userId', name: 'AuthService');
    }

    return userId;
  }

  // Get the current username
  Future<String?> getCurrentUsername() async {
    return await asyncpref.getString(usernameKey);
  }
}
