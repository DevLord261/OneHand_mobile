import 'package:flutter/material.dart';
import 'package:OneHand/models/Campaign.dart';
import 'package:OneHand/services/campaign_services.dart';
import 'package:OneHand/widget/campaign_card.dart';
import 'package:OneHand/screen/campaign_details.dart';
import 'package:OneHand/utils/category_utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Campaignservices _campaignService = Campaignservices();
  Category? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Campaign>? _allCampaigns;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Listen for search query changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  // Filter campaigns based on search query and selected category
  List<Campaign> _getFilteredCampaigns(List<Campaign> campaigns) {
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      return campaigns;
    }

    return campaigns.where((campaign) {
      // Check if campaign matches category filter
      bool matchesCategory =
          _selectedCategory == null || campaign.category == _selectedCategory;

      // Check if campaign matches search query
      bool matchesSearch =
          _searchQuery.isEmpty ||
          campaign.title.toLowerCase().contains(_searchQuery) ||
          campaign.description.toLowerCase().contains(_searchQuery);

      // Campaign must match both filters
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OneHand"),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search TextField
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search campaigns',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category Filter Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Campaigns",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildCategoryFilter(),
                ],
              ),
              const SizedBox(height: 16),

              // Category filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(null, "All"),
                    const SizedBox(width: 8),
                    ...Category.values.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          category,
                          CategoryUtils.getName(category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Campaigns list with filtering
              FutureBuilder<List<Campaign>>(
                future: _campaignService.getAllCampaigns(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          "Error loading campaigns: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  _allCampaigns = snapshot.data ?? [];

                  final filteredCampaigns = _getFilteredCampaigns(
                    _allCampaigns!,
                  );

                  if (filteredCampaigns.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? "No results found for \"$_searchQuery\""
                                  : _selectedCategory != null
                                  ? "No ${CategoryUtils.getName(_selectedCategory!)} campaigns found"
                                  : "No campaigns available",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchQuery.isNotEmpty ||
                                _selectedCategory != null) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _clearFilters,
                                child: const Text("Clear filters"),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show count of results if filtering is active
                      if (_searchQuery.isNotEmpty || _selectedCategory != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "${filteredCampaigns.length} campaign${filteredCampaigns.length != 1 ? 's' : ''} found",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // List of filtered campaigns
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredCampaigns.length,
                        itemBuilder: (context, index) {
                          return CampaignCard(
                            campaign: filteredCampaigns[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CampaignDetails(
                                        campaign: filteredCampaigns[index],
                                      ),
                                ),
                              ).then((_) {
                                setState(() {});
                              });
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build category dropdown filter
  Widget _buildCategoryFilter() {
    return DropdownButton<Category?>(
      value: _selectedCategory,
      hint: const Text("Filter"),
      icon: const Icon(Icons.filter_list),
      underline: Container(height: 0),
      onChanged: (Category? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      items: [
        const DropdownMenuItem<Category?>(
          value: null,
          child: Text("All Categories"),
        ),
        ...Category.values.map<DropdownMenuItem<Category>>((Category category) {
          return DropdownMenuItem<Category>(
            value: category,
            child: Text(CategoryUtils.getName(category)),
          );
        }).toList(),
      ],
    );
  }

  // Build a filter chip for category selection
  Widget _buildFilterChip(Category? category, String label) {
    final isSelected = category == _selectedCategory;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      checkmarkColor: Colors.white,
      selectedColor:
          category != null
              ? CategoryUtils.getColor(category)
              : Colors.lightBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[200],
      onSelected: (bool selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
    );
  }
}
