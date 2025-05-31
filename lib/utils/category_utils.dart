import 'package:flutter/material.dart';
import 'package:OneHand/models/Campaign.dart';

/// A utility class to handle category-related helper functions.
/// This centralizes the category display logic to avoid code duplication.
class CategoryUtils {
  /// Get the color associated with a specific category
  static Color getColor(Category category) {
    switch (category) {
      case Category.medical:
        return Colors.red[400]!;
      case Category.business:
        return Colors.blue[400]!;
      case Category.technology:
        return Colors.purple[400]!;
      case Category.resotring:
        return Colors.green[400]!;
    }
  }

  /// Get the icon associated with a specific category
  static IconData getIcon(Category category) {
    switch (category) {
      case Category.medical:
        return Icons.medical_services;
      case Category.business:
        return Icons.business;
      case Category.technology:
        return Icons.computer;
      case Category.resotring:
        return Icons.restore;
    }
  }

  /// Get the display name associated with a specific category
  static String getName(Category category) {
    switch (category) {
      case Category.medical:
        return "Medical";
      case Category.business:
        return "Business";
      case Category.technology:
        return "Technology";
      case Category.resotring:
        return "Restoration";
    }
  }
}
