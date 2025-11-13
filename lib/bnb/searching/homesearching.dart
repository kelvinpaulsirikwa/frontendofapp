import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/services/search_service.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:bnbfrontendflutter/bnb/bnbhome/bnbdetails.dart';
import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'package:flutter/material.dart';

class HomeSearching extends StatefulWidget {
  const HomeSearching({super.key});

  @override
  State<HomeSearching> createState() => _HomeSearchingState();
}

class _HomeSearchingState extends State<HomeSearching> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'Top Searched';
  final List<String> _selectedAmenities = [];
  final List<String> _selectedRegions = [];

  // Loading states
  bool _isLoading = false;
  bool _isLoadingFilters = false;

  // Data from API
  List<dynamic> _searchResults = [];
  List<dynamic> _availableAmenities = [];
  List<dynamic> _availableRegions = [];

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  int _totalResults = 0;
  final ScrollController _scrollController = ScrollController();

  // Sort options
  final List<String> _sortOptions = ['All', 'Top Searched', 'New Listings'];

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _searchMotels();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoading && !_isLoadingMore) {
        _loadMoreResults();
      }
    }
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many API calls
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _currentPage = 1;
        _searchResults.clear();
        _searchMotels();
      }
    });
  }

  Future<void> _loadFilters() async {
    setState(() {
      _isLoadingFilters = true;
    });

    try {
      final regions = await SearchService.getRegions();
      final amenities = await SearchService.getAmenities();

      setState(() {
        _availableRegions = regions;
        _availableAmenities = amenities;
      });
    } catch (e) {
      print('Error loading filters: $e');
    } finally {
      setState(() {
        _isLoadingFilters = false;
      });
    }
  }

  Future<void> _searchMotels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SearchService.searchMotels(
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        regions: _selectedRegions.isNotEmpty ? _selectedRegions : null,
        amenities: _selectedAmenities.isNotEmpty ? _selectedAmenities : null,
        sortBy: _getSortByValue(_selectedSort),
        page: _currentPage,
      );

      if (result['success'] == true) {
        final newResults = List<dynamic>.from(result['data'] ?? []);
        final pagination = result['pagination'] ?? {};

        setState(() {
          if (_currentPage == 1) {
            _searchResults = newResults;
          } else {
            _searchResults.addAll(newResults);
          }
          _hasMore = pagination['has_more'] ?? false;
          _totalResults = pagination['total'] ?? 0;
          _isLoadingMore = false;
        });

        // Track search results
        if (newResults.isNotEmpty) {
          final motelIds = newResults
              .map((motel) => motel['id'] as int)
              .toList();
          SearchService.trackSearch(motelIds);
        }
      }
    } catch (e) {
      print('Error searching motels: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoading || !_hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    await _searchMotels();
  }

  String _getSortByValue(String sortOption) {
    switch (sortOption) {
      case 'Top Searched':
        return 'top_searched';
      case 'New Listings':
        return 'new_listings';
      default:
        return 'all';
    }
  }

  void _onSortChanged(String newSort) {
    setState(() {
      _selectedSort = newSort;
      _currentPage = 1;
      _searchResults.clear();
    });
    _searchMotels();
  }

  void _onFilterChanged() {
    setState(() {
      _currentPage = 1;
      _searchResults.clear();
    });
    _searchMotels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmSand,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [deepTerracotta, richBrown],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: softCream,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: softCream,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: deepTerracotta,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) => setState(() {}),
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Search accommodations...',
                                  hintStyle: TextStyle(
                                    color: textLight,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: textLight,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        // Navigate to account/profile
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: softCream,
                          child: Icon(
                            Icons.person,
                            color: deepTerracotta,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Sort Tabs
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: softCream,
                boxShadow: [
                  BoxShadow(
                    color: richBrown.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _sortOptions.length,
                itemBuilder: (context, index) {
                  final option = _sortOptions[index];
                  final isSelected = _selectedSort == option;
                  return GestureDetector(
                    onTap: () {
                      _onSortChanged(option);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? deepTerracotta : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? deepTerracotta
                              : Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? softCream : textDark,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Filter chips section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amenities filter
                  Row(
                    children: [
                      const Icon(
                        Icons.checkroom_outlined,
                        size: 16,
                        color: earthGreen,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Amenities',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedAmenities.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAmenities.clear();
                            });
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: deepTerracotta,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: _isLoadingFilters
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _availableAmenities.length,
                            itemBuilder: (context, index) {
                              final amenity = _availableAmenities[index];
                              final amenityName = amenity['name'] ?? '';
                              final isSelected = _selectedAmenities.contains(
                                amenityName,
                              );
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedAmenities.remove(amenityName);
                                    } else {
                                      _selectedAmenities.add(amenityName);
                                    }
                                  });
                                  _onFilterChanged();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? earthGreen
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected
                                          ? earthGreen
                                          : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: Icon(
                                            Icons.check,
                                            size: 14,
                                            color: softCream,
                                          ),
                                        ),
                                      Text(
                                        amenityName,
                                        style: TextStyle(
                                          color: isSelected
                                              ? softCream
                                              : Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  // Regions filter
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: sunsetOrange,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Regions',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedRegions.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRegions.clear();
                            });
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: deepTerracotta,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: _isLoadingFilters
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _availableRegions.length,
                            itemBuilder: (context, index) {
                              final region = _availableRegions[index];
                              final regionName = region['name'] ?? '';
                              final isSelected = _selectedRegions.contains(
                                regionName,
                              );
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedRegions.remove(regionName);
                                    } else {
                                      _selectedRegions.add(regionName);
                                    }
                                  });
                                  _onFilterChanged();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? sunsetOrange
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected
                                          ? sunsetOrange
                                          : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: Icon(
                                            Icons.check,
                                            size: 14,
                                            color: softCream,
                                          ),
                                        ),
                                      Text(
                                        regionName,
                                        style: TextStyle(
                                          color: isSelected
                                              ? softCream
                                              : Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(height: 1, color: Colors.grey.shade200),

            // Results count
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Text(
                    _totalResults > 0
                        ? '${_searchResults.length} of $_totalResults results'
                        : '${_searchResults.length} ${_searchResults.length == 1 ? 'result' : 'results'}',
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedAmenities.isNotEmpty ||
                      _selectedRegions.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAmenities.clear();
                          _selectedRegions.clear();
                        });
                        _onFilterChanged();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: deepTerracotta.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.clear_all,
                              size: 14,
                              color: deepTerracotta,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Clear All',
                              style: TextStyle(
                                color: deepTerracotta,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Results list - Play Store style
            Expanded(
              child: _isLoading && _searchResults.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.travel_explore,
                            size: 64,
                            color: textLight.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No matches found',
                            style: TextStyle(
                              color: textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              color: textLight.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _searchResults.length + (_hasMore ? 1 : 0),
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Colors.grey.shade200, height: 1),
                      ),
                      itemBuilder: (context, index) {
                        if (index == _searchResults.length) {
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                if (_isLoadingMore)
                                  CircularProgressIndicator()
                                else if (_hasMore)
                                  Column(
                                    children: [
                                      Text(
                                        'Scroll down to load more results',
                                        style: TextStyle(
                                          color: textLight.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: _loadMoreResults,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: deepTerracotta,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Load More',
                                            style: TextStyle(
                                              color: softCream,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else if (_searchResults.isNotEmpty)
                                  Text(
                                    'No more results to load',
                                    style: TextStyle(
                                      color: textLight.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }
                        final hotel = _searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            // Convert search result to SimpleMotel and navigate to details
                            final simpleMotel = SimpleMotel(
                              id: hotel['id'] ?? 0,
                              name: hotel['name'] ?? 'Unknown Motel',
                              frontImage: hotel['front_image'],
                              streetAddress:
                                  hotel['street_address'] ?? 'Unknown Street',
                              motelType: hotel['type'] ?? 'Unknown Type',
                              district: hotel['location'] ?? 'Unknown District',
                              longitude: hotel['longitude'] != null
                                  ? double.tryParse(
                                      hotel['longitude'].toString(),
                                    )
                                  : null,
                              latitude: hotel['latitude'] != null
                                  ? double.tryParse(
                                      hotel['latitude'].toString(),
                                    )
                                  : null,
                            );

                            NavigationUtil.pushTo(
                              context,
                              BnBDetails(motel: simpleMotel),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image placeholder
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        earthGreen.withOpacity(0.3),
                                        sunsetOrange.withOpacity(0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: richBrown.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.home_outlined,
                                            size: 28,
                                            color: richBrown.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                      if (hotel['isNew'] == true)
                                        Positioned(
                                          top: 6,
                                          left: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: sunsetOrange,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'NEW',
                                              style: TextStyle(
                                                color: softCream,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              hotel['name'] ?? '',
                                              style: const TextStyle(
                                                color: textDark,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: earthGreen.withOpacity(
                                                0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              hotel['badge'] ?? '',
                                              style: const TextStyle(
                                                color: earthGreen,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        hotel['type'] ?? '',
                                        style: const TextStyle(
                                          color: textLight,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: warmSand,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 11,
                                                  color: sunsetOrange,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  '${hotel['rating']}',
                                                  style: const TextStyle(
                                                    color: textDark,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.reviews_outlined,
                                                  size: 11,
                                                  color: textLight.withOpacity(
                                                    0.7,
                                                  ),
                                                ),
                                                const SizedBox(width: 3),
                                                Flexible(
                                                  child: Text(
                                                    '${hotel['reviews']} reviews',
                                                    style: TextStyle(
                                                      color: textLight
                                                          .withOpacity(0.8),
                                                      fontSize: 11,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 12,
                                            color: textLight,
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              hotel['location'] ?? '',
                                              style: const TextStyle(
                                                color: textLight,
                                                fontSize: 11,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Action button
                                Column(
                                  children: [
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: deepTerracotta,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: softCream,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
