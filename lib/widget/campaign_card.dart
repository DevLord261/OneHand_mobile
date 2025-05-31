import 'package:flutter/material.dart';
import 'package:OneHand/models/Campaign.dart';
import 'package:OneHand/utils/category_utils.dart';
import 'package:OneHand/widget/category_placeholder.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;
  final Widget? trailing;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onTap,
    this.trailing,
  });

  // Calculate progress percentage
  double get _progressPercentage {
    if (campaign.donationGoal <= 0) return 0.0;
    double result = campaign.currentDonations / campaign.donationGoal;
    return result.clamp(0.0, 1.0); // Ensure value is between 0.0 and 1.0
  }

  // Format percentage as string
  String get _percentageText {
    return "${(_progressPercentage * 100).toStringAsFixed(0)}%";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign image with error handling
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 180,
                child:
                    campaign.image != null
                        ? Image.memory(
                          campaign.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return CategoryPlaceholder(
                              category: campaign.category,
                            );
                          },
                        )
                        : CategoryPlaceholder(category: campaign.category),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          campaign.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CategoryUtils.getColor(campaign.category),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          CategoryUtils.getName(campaign.category),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campaign.description.length > 100
                        ? '${campaign.description.substring(0, 100)}...'
                        : campaign.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Progress indicator section
                  Row(
                    children: [
                      // Expanded progress indicator - will take available space
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progressPercentage,
                            backgroundColor: Colors.grey[200],
                            minHeight: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _progressPercentage >= 1.0
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      // Add some space between the progress bar and text
                      const SizedBox(width: 12),
                      // Percentage text with fixed width
                      Text(
                        _percentageText,
                        style: TextStyle(
                          color:
                              _progressPercentage >= 1.0
                                  ? Colors.green[700]
                                  : Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  const SizedBox(height: 12),

                  // Goal and action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Goal: ${campaign.donationGoal}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                          const Icon(
                            Icons.attach_money,
                            color: Colors.green,
                            size: 20,
                          ),
                        ],
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
