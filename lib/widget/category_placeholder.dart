import 'package:flutter/material.dart';
import 'package:flutterproject/models/Campaign.dart';
import 'package:flutterproject/utils/category_utils.dart';

class CategoryPlaceholder extends StatelessWidget {
  final Category category;
  final double iconSize;

  const CategoryPlaceholder({
    super.key,
    required this.category,
    this.iconSize = 60,
  });

  @override
  Widget build(BuildContext context) {

    Color baseColor = CategoryUtils.getColor(category);

    Color backgroundColor = baseColor.withOpacity(0.7);

    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CategoryUtils.getIcon(category),
              color: Colors.white,
              size: iconSize,
            ),
            const SizedBox(height: 8),
            Text(
              CategoryUtils.getName(category),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
