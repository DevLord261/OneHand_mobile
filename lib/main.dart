import 'package:flutter/material.dart';
import 'package:flutterproject/data/DB.dart';
import 'package:flutterproject/screen/Home.dart';
import 'package:flutterproject/screen/Login.dart';
import 'package:flutterproject/services/AuthService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for SQLite

  // Initialize database
  await DBContext.instance.database;

  runApp(MaterialApp(home: AuthCheck()));
}

class AuthCheck extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          final bool isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const Home() : const Login();
        }
      },
    );
  }
}
