import 'dart:typed_data';

import 'package:flutterproject/data/DB.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Category { medical, business, technology, resotring }

class Campaignservices {
  final dbContext = DBContext.instance;

  Future<int> CreateCampaign(
    String title,
    String desciption,
    Uint8List imagedata,
    Category category,
    int goal,
  ) async {
    final db = await dbContext.database;
    var userid = await SharedPreferencesAsync().getInt('user_id');
    return await db.insert('campaign', {
      "title": title,
      "description": desciption,
      "image": imagedata,
      'donation_goal': goal,
      "category": category.toString(),
      'user_id': userid,
    });
  }

  Future<Uint8List> getimage() async {
    final db = await dbContext.database;
    var row = await db.query('campaign', limit: 1);
    var result = row.first['image'] as Uint8List;
    return result;
  }
}
