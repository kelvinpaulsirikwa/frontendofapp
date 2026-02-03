import 'package:bnbfrontendflutter/bnb/bnbhome/ui.dart';
import 'package:bnbfrontendflutter/layouts/loading.dart';
import 'package:bnbfrontendflutter/services/home_data_service.dart';
import 'package:bnbfrontendflutter/services/region_service.dart';
import 'package:bnbfrontendflutter/services/location_service.dart';
import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'package:bnbfrontendflutter/utility/loading.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/alert.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All Regions';
  String _selectedType = 'All Types';
  bool _isDropdownOpen = false;
  bool _isLoading = true;

  // Animation controller for loading
  late AnimationController _controller;

  // Data
  List<Region> _regions = [];
  List<Map<String, dynamic>> _accommodationTypes = [];
  List<SimpleMotel> _featured = [];
  List<SimpleMotel> _popular = [];
  
  // Location
  Position? _currentPosition;
  bool _locationEnabled = false;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMorePages = true;
    });

    try {
      // Try to get current location
      _currentPosition = await LocationService.getCurrentLocation();
      _locationEnabled = _currentPosition != null;
      
      if (!_locationEnabled) {
        AlertReturn.showToast('ur location is off');
      }

      final data = await HomeDataService.loadAllData(
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
      );

      if (data['success'] == true) {
        final pagination = data['popularPagination'] as Map<String, dynamic>?;
        setState(() {
          _regions = data['regions'] as List<Region>;
          _accommodationTypes =
              data['accommodationTypes'] as List<Map<String, dynamic>>;
          // Load featured motels for "Near By" section (max 10 items)
          _featured = (data['featured'] as List<SimpleMotel>).take(10).toList();
          // Load popular motels for "Popular Destinations" section
          _popular = data['popular'] as List<SimpleMotel>;
          _hasMorePages = pagination?['has_more'] ?? false;
          _isLoading = false;
        });
      } else {
        print('Error loading data: ${data['error']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _onRegionSelected(String region) {
    setState(() {
      _selectedRegion = region;
      _isDropdownOpen = false;
    });
    // Reload motels with new region filter
    _loadMotelsWithFilters();
  }

  void _onTypeSelected(String type) {
    setState(() {
      _selectedType = type;
    });
    // Reload motels with new type filter
    _loadMotelsWithFilters();
  }

  Future<void> _loadMotelsWithFilters({bool loadMore = false}) async {
    if (_isLoading && !loadMore) return;
    if (_isLoadingMore && loadMore) return;
    if (loadMore && !_hasMorePages) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _currentPage = 1;
        _hasMorePages = true;
      }
    });

    try {
      // Get region ID and type ID from selected values
      int regionId = HomeDataService.getRegionIdByName(
        _regions,
        _selectedRegion,
      );
      int typeId = HomeDataService.getTypeIdByName(
        _accommodationTypes,
        _selectedType,
      );

      print('Filtering by region: $_selectedRegion (ID: $regionId)');
      print('Filtering by type: $_selectedType (ID: $typeId)');

      // Load filtered motels for "Near By" section based on region and type
      final filteredData = await HomeDataService.loadFilteredData(
        regionId: regionId > 0 ? regionId : null,
        typeId: typeId > 0 ? typeId : null,
        page: _currentPage,
        limit: 10,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
      );

      if (filteredData['success'] == true) {
        final pagination = filteredData['popularPagination'] as Map<String, dynamic>?;
        setState(() {
          if (loadMore) {
            // Append to existing list
            _popular.addAll(filteredData['popular'] as List<SimpleMotel>);
            _currentPage++;
          } else {
            // Replace list
            _featured = (filteredData['featured'] as List<SimpleMotel>).take(10).toList();
            _popular = filteredData['popular'] as List<SimpleMotel>;
            _currentPage = 2; // Next page for load more
          }
          _hasMorePages = pagination?['has_more'] ?? false;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        print('Error loading filtered data: ${filteredData['error']}');
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error loading filtered motels: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMorePopular() async {
    await _loadMotelsWithFilters(loadMore: true);
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Stack(
      children: [
        HomeLayout(
          selectedRegion: _selectedRegion,
          selectedType: _selectedType,
          isDropdownOpen: _isDropdownOpen,
          regions: HomeDataService.getRegionNames(_regions),
          accommodationTypes: _accommodationTypes,
          featured: _featured,
          popular: _popular,
          hasMorePages: _hasMorePages,
          isLoadingMore: _isLoadingMore,
          onToggleDropdown: _toggleDropdown,
          onRegionSelected: _onRegionSelected,
          onTypeSelected: _onTypeSelected,
          onRefresh: () {
            _loadData();
          },
          onLoadMore: _loadMorePopular,
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                elevation: 8,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Loading.infiniteLoading(context),
                      
                      const SizedBox(height: 16),
                      Text(
                        local.homeLoadingLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
