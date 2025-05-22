class Campaign {
  final int id;
  final String username;
  final String email;

  Campaign({required this.id, required this.username, required this.email});

  String QueryTable() {
    return ("CREATE TABLE Campaign(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, email TEXT NOT NULL)");
  }
}
