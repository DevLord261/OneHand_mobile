import 'package:flutter/material.dart';
import 'package:flutterproject/data/DB.dart';
import 'package:flutterproject/screen/Home.dart';
import 'package:flutterproject/screen/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for SQLite

  // Initialize database
  await DBContext.instance.database;

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return Home();
  }
}
