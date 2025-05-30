import 'package:flutter/material.dart';
import 'package:flutterproject/models/Campaign.dart';
import 'package:flutterproject/screen/create_campaign.dart';
import 'package:flutterproject/screen/campaign_details.dart';
import 'package:flutterproject/services/campaign_services.dart';
import 'package:flutterproject/widget/campaign_card.dart';
import 'package:flutterproject/services/auth_service.dart';
import 'package:flutterproject/main.dart';

class MyCampaigns extends StatefulWidget {
  const MyCampaigns({super.key});

  @override
  State<MyCampaigns> createState() => _MyCampaignsState();
}

class _MyCampaignsState extends State<MyCampaigns> {
  final Campaignservices _campaignServices = Campaignservices();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.logout();

      if (!mounted) return;

      // Navigate to the AuthCheck which will redirect to Login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthCheck()),
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Campaigns"),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<Campaign>>(
                future: _campaignServices.getUserCampaigns(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Error: ${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => setState(() {}), // Simple refresh
                            child: const Text("Try Again"),
                          ),
                        ],
                      ),
                    );
                  }

                  final campaigns = snapshot.data ?? [];

                  if (campaigns.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.campaign_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "You haven't created any campaigns yet",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Create Campaign"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateCampaign(),
                                ),
                              ).then(
                                (_) => setState(() {}),
                              ); // Refresh after returning
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: campaigns.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(campaigns[index].id.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmationDialog(
                            campaigns[index],
                          );
                        },
                        onDismissed: (direction) {
                          _deleteCampaign(campaigns[index].id!);
                        },
                        child: CampaignCard(
                          campaign: campaigns[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CampaignDetails(
                                      campaign: campaigns[index],
                                    ),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              if (await _showDeleteConfirmationDialog(
                                campaigns[index],
                              )) {
                                _deleteCampaign(campaigns[index].id!);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(Campaign campaign) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Campaign'),
                content: Text(
                  'Are you sure you want to delete "${campaign.title}"? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('DELETE'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _deleteCampaign(int campaignId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _campaignServices.deleteCampaign(campaignId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete campaign'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
