import 'package:OneHand/services/user_service.dart';
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
      await prefs.setString(userIdKey, user['id']);
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
    final userId = prefs.getString(userIdKey);
    return userId != null;
  }

  // Get the current user's ID with better validation
  Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(userIdKey);

    // Log for debugging
    if (userId == null) {
      developer.log(
        'No valid user ID found in preferences',
        name: 'AuthService',
      );
    } else {
      developer.log('Retrieved user ID: $userId', name: 'AuthService');
    }

    return userId.toString();
  }

  // Get the current username
  Future<String?> getCurrentUsername() async {
    return await asyncpref.getString(usernameKey);
  }
}
