import 'package:sqflite/sqflite.dart';

class DBContext {
  static final DBContext instance = DBContext.instance;
  late final Database? database;
}
