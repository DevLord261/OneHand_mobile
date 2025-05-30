import 'dart:typed_data';

enum Category { medical, business, technology, resotring }

class Campaign {
  final int? id;
  final String title;
  final String description;
  final int userId;
  final int donationGoal;
  final Category category;
  final Uint8List? image;
  final double currentDonations; // Add this field to track donations

  Campaign({
    this.id,
    required this.title,
    required this.description,
    required this.donationGoal,
    required this.userId,
    required this.category,
    this.image,
    this.currentDonations = 0.0, // Default to zero
  });

  factory Campaign.fromMap(Map<String, dynamic> map) {
    // Handle category conversion safely
    Category categoryValue;
    try {
      final categoryStr = map['category'] as String? ?? 'medical';
      // Remove 'Category.' prefix if present
      final cleanCategoryStr =
          categoryStr.contains('.') ? categoryStr.split('.').last : categoryStr;

      categoryValue = Category.values.firstWhere(
        (e) =>
            e.toString().toLowerCase().contains(cleanCategoryStr.toLowerCase()),
        orElse: () => Category.medical, // Default to medical if not found
      );
    } catch (_) {
      categoryValue = Category.medical;
    }

    // Safe numeric conversion helper functions
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Campaign(
      id: toInt(map['id']),
      title: map['title'] as String? ?? 'Untitled',
      description: map['description'] as String? ?? 'No description',
      userId: toInt(map['user_id']),
      donationGoal: toInt(map['donation_goal']),
      category: categoryValue,
      image: map['image'] as Uint8List?,
      currentDonations: toDouble(map['current_donations'] ?? 0.0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'user_id': userId,
      'donation_goal': donationGoal,
      'category': category.toString(),
      'image': image,
      'current_donations': currentDonations,
    };
  }

  // Create a copy of the campaign with updated donation amount
  Campaign copyWith({double? currentDonations}) {
    return Campaign(
      id: id,
      title: title,
      description: description,
      userId: userId,
      donationGoal: donationGoal,
      category: category,
      image: image,
      currentDonations: currentDonations ?? this.currentDonations,
    );
  }

  String QueryTable() {
    return ("CREATE TABLE Campaign(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, email TEXT NOT NULL)");
  }
}
