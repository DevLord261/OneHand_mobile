import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutterproject/data/DB.dart';
import 'package:flutterproject/models/Campaign.dart';
import 'package:flutterproject/services/auth_service.dart';

class Campaignservices {
  final dbContext = DBContext.instance;
  final AuthService _authService = AuthService();

  // Use Category from the Campaign file
  Future<Uint8List> _getDefaultImage(Category category) async {
    // Return different default images based on category
    String imagePath;

    switch (category) {
      default:
        imagePath = 'assets/images/default_campaign.png';
    }

    try {
      return await rootBundle
          .load(imagePath)
          .then((data) => data.buffer.asUint8List());
    } catch (e) {
      // If specific category default image not found, use general default
      return await rootBundle
          .load('assets/images/default_campaign.png')
          .then((data) => data.buffer.asUint8List());
    }
  }

  // For creating campaigns
  Future<int> createCampaign(
    String title,
    String description,
    Uint8List? imageData,
    Category category,
    int goal,
  ) async {
    final db = await dbContext.database;

    // Use AuthService to get userId
    final userId = await _authService.getCurrentUserId();

    if (userId <= 0) {
      developer.log(
        'Cannot create campaign: No valid user is logged in',
        name: 'CampaignServices',
      );
      throw Exception('You must be logged in to create a campaign');
    }

    // If no image was provided, use a default one
    imageData ??= await _getDefaultImage(category);

    return await db.insert('campaign', {
      "title": title,
      "description": description,
      "image": imageData,
      'donation_goal': goal,
      "category": category.toString(),
      'user_id': userId,
    });
  }

  Future<Uint8List> getImage([int? campaignId]) async {
    final db = await dbContext.database;
    try {
      var query =
          campaignId != null
              ? await db.query(
                'campaign',
                where: 'id = ?',
                whereArgs: [campaignId],
                limit: 1,
              )
              : await db.query('campaign', limit: 1);

      if (query.isNotEmpty && query.first['image'] != null) {
        return query.first['image'] as Uint8List;
      } else {
        // Return default image if no campaign or no image
        return await _getDefaultImage(Category.medical);
      }
    } catch (e) {
      developer.log('Error getting image: $e', name: 'CampaignServices');
      return await _getDefaultImage(Category.medical);
    }
  }

  Future<List<Campaign>> getUserCampaigns() async {
    try {
      // Use AuthService to get userId
      final userId = await _authService.getCurrentUserId();

      if (userId <= 0) {
        developer.log('User ID not found or invalid', name: 'CampaignServices');
        return [];
      }

      final db = await dbContext.database;
      final result = await db.query(
        'campaign',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // Safely convert maps to Campaign objects with null checks
      return result
          .map((map) {
            try {
              return Campaign.fromMap(map);
            } catch (e) {
              developer.log(
                'Error converting map to Campaign: $e',
                name: 'CampaignServices',
              );
              return null;
            }
          })
          .whereType<Campaign>()
          .toList(); // Filter out any nulls
    } catch (e) {
      developer.log(
        'Error getting user campaigns: $e',
        name: 'CampaignServices',
      );
      return [];
    }
  }

  Future<bool> deleteCampaign(int campaignId) async {
    try {
      // Get current user ID
      final userId = await _authService.getCurrentUserId();

      if (userId <= 0) {
        developer.log(
          'Cannot delete campaign: No valid user is logged in',
          name: 'CampaignServices',
        );
        return false;
      }

      final db = await dbContext.database;

      // First verify the campaign belongs to this user (security check)
      final campaign = await db.query(
        'campaign',
        where: 'id = ? AND user_id = ?',
        whereArgs: [campaignId, userId],
        limit: 1,
      );

      if (campaign.isEmpty) {
        developer.log(
          'Cannot delete campaign: Campaign not found or does not belong to this user',
          name: 'CampaignServices',
        );
        return false;
      }

      // Delete the campaign
      final deletedRows = await db.delete(
        'campaign',
        where: 'id = ?',
        whereArgs: [campaignId],
      );

      developer.log(
        'Deleted campaign id: $campaignId, rows affected: $deletedRows',
        name: 'CampaignServices',
      );

      return deletedRows > 0;
    } catch (e) {
      developer.log('Error deleting campaign: $e', name: 'CampaignServices');
      return false;
    }
  }

  Future<bool> updateCampaignDonation(int campaignId, double amount) async {
    try {
      final db = await dbContext.database;

      // First, get the current campaign
      final campaigns = await db.query(
        'campaign',
        where: 'id = ?',
        whereArgs: [campaignId],
        limit: 1,
      );

      if (campaigns.isEmpty) {
        return false;
      }

      final campaign = Campaign.fromMap(campaigns.first);
      final newDonationAmount = campaign.currentDonations + amount;

      // Update the campaign with new donation amount
      await db.update(
        'campaign',
        {'current_donations': newDonationAmount},
        where: 'id = ?',
        whereArgs: [campaignId],
      );

      return true;
    } catch (e) {
      developer.log(
        'Error updating campaign donation: $e',
        name: 'CampaignServices',
      );
      return false;
    }
  }

  Future<double> getCampaignTotalDonations(int campaignId) async {
    try {
      final db = await dbContext.database;
      final result = await db.query(
        'campaign',
        columns: ['current_donations'],
        where: 'id = ?',
        whereArgs: [campaignId],
      );

      if (result.isNotEmpty) {
        final currentDonations = result.first['current_donations'];
        if (currentDonations is double) return currentDonations;
        if (currentDonations is int) return currentDonations.toDouble();
        return 0.0;
      }
      return 0.0;
    } catch (e) {
      developer.log(
        'Error getting campaign donations: $e',
        name: 'CampaignServices',
      );
      return 0.0;
    }
  }
}
