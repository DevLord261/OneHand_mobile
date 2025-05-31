import 'package:flutter/material.dart';
import 'package:OneHand/models/Campaign.dart';
import 'package:OneHand/services/campaign_services.dart';
import 'package:OneHand/utils/category_utils.dart';
import 'package:OneHand/widget/category_placeholder.dart';

class CampaignDetails extends StatefulWidget {
  final Campaign campaign;

  const CampaignDetails({super.key, required this.campaign});

  @override
  State<CampaignDetails> createState() => _CampaignDetailsState();
}

class _CampaignDetailsState extends State<CampaignDetails> {
  final TextEditingController _donationAmountController =
      TextEditingController();
  final Campaignservices _campaignService = Campaignservices();
  late Campaign _campaign;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _campaign = widget.campaign;
    _refreshDonationData();
  }

  @override
  void dispose() {
    _donationAmountController.dispose();
    super.dispose();
  }

  // Method to refresh donation data
  Future<void> _refreshDonationData() async {
    if (_campaign.id == null) return;

    final donations = await _campaignService.getCampaignTotalDonations(
      _campaign.id!,
    );
    if (mounted) {
      setState(() {
        _campaign = _campaign.copyWith(currentDonations: donations);
      });
    }
  }

  // Calculate progress percentage
  double get _progressPercentage {
    if (_campaign.donationGoal <= 0) return 0.0;
    double result = _campaign.currentDonations / _campaign.donationGoal;
    return result.clamp(0.0, 1.0);
  }

  // Format percentage as string
  String get _percentageText {
    return "${(_progressPercentage * 100).toStringAsFixed(1)}%";
  }

  // Method to show donation dialog
  void _showDonationDialog() {
    _donationAmountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Make a Donation",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _donationAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Amount (\$)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _processDonation(),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Donate Now',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  // Process donation
  Future<void> _processDonation() async {
    final amount = double.tryParse(_donationAmountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if campaign ID is valid
    if (_campaign.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to process donation - invalid campaign'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Navigator.pop(context);
      final success = await _campaignService.updateCampaignDonation(
        _campaign.id!,
        amount,
      );

      if (success) {
        await _refreshDonationData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Thank you for your donation of \$${amount.toStringAsFixed(2)}!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to process donation. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Sliver app bar with campaign image as background and improved back button
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background:
                    widget.campaign.image != null
                        ? Image.memory(
                          widget.campaign.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return CategoryPlaceholder(
                              category: widget.campaign.category,
                            );
                          },
                        )
                        : CategoryPlaceholder(
                          category: widget.campaign.category,
                        ),
              ),
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // Campaign content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.campaign.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            CategoryUtils.getName(widget.campaign.category),
                          ),
                          backgroundColor: CategoryUtils.getColor(
                            widget.campaign.category,
                          ),
                          labelStyle: const TextStyle(color: Colors.white),
                          avatar: Icon(
                            CategoryUtils.getIcon(widget.campaign.category),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Goal progress indicator
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.campaign.donationGoal}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text(" goal", style: TextStyle(fontSize: 16)),
                        const Spacer(),
                        Text(
                          "$_percentageText funded",
                          style: TextStyle(
                            color:
                                _progressPercentage > 0
                                    ? Colors.green[700]
                                    : Colors.grey[600],
                            fontWeight:
                                _progressPercentage > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Raised: \$${_campaign.currentDonations.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          " of \$${_campaign.donationGoal}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Updated progress indicator with real progress
                    LinearProgressIndicator(
                      value: _progressPercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progressPercentage >= 1.0 ? Colors.green : Colors.blue,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),

                    const SizedBox(height: 24),

                    // Campaign description
                    const Text(
                      "About this campaign",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.campaign.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          // The Expanded was directly inside Container which is not allowed
          child: ElevatedButton.icon(
            onPressed: _showDonationDialog,
            icon: const Icon(Icons.favorite),
            label: const Text("Donate Now"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
    );
  }
}
