import 'package:flutterproject/models/Users.dart';
import 'package:sqflite/sqflite.dart';

class DBContext {
  static final DBContext instance = DBContext.instance;
  late final Database? database;
  
}
