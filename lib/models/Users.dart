class Users {
  final String? id;
  final String username;
  final String email;

  Users({this.id, required this.username, required this.email});

  String get QueryTable {
    return ("CREATE TABLE Users(id TEXT PRIMARY KEY , username TEXT NOT NULL, email TEXT NOT NULL)");
  }
}
