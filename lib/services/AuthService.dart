import 'package:flutterproject/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String USER_ID_KEY = 'user_id';
  static const String USERNAME_KEY = 'username';

  final UserService _userService = UserService();
  final SharedPreferencesAsync asyncpref = SharedPreferencesAsync();

  // Login and save user info
  Future<bool> login(String username, String password) async {
    final user = await _userService.login(username, password);

    if (user != null) {
      await asyncpref.setInt(USER_ID_KEY, user['id']);
      await asyncpref.setString(USERNAME_KEY, user['username']);
      return true;
    }
    return false;
  }

  // Logout user
  Future<void> logout() async {
    await asyncpref.remove(USER_ID_KEY);
    await asyncpref.remove(USERNAME_KEY);
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId != null) {
      return await _userService.getUserById(userId);
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await asyncpref.containsKey(USER_ID_KEY);
  }

  // Get the current user's ID
  Future<int?> getCurrentUserId() async {
    return await asyncpref.getInt(USER_ID_KEY);
  }

  // Get the current username
  Future<String?> getCurrentUsername() async {
    return await asyncpref.getString(USERNAME_KEY);
  }
}
