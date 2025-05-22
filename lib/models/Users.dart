class Users {
  final int? id;
  final String username;
  final String email;

  Users({this.id, required this.username, required this.email});

  String get QueryTable {
    return ("CREATE TABLE Users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, email TEXT NOT NULL)");
  }
}
