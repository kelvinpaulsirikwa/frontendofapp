import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/near_me_service.dart';
import '../../services/location_service.dart';
import '../../utility/distance_calculator.dart';
import '../../models/bnbmodel.dart';
import '../bnbhome/bnbdetails.dart';
import '../../utility/navigateutility.dart';
import 'topsearchmotel.dart';
import 'newrestmotel.dart';

class EnhancedMapHomePage extends StatefulWidget {
  const EnhancedMapHomePage({super.key});

  @override
  State<EnhancedMapHomePage> createState() => _EnhancedMapHomePageState();
}

class _EnhancedMapHomePageState extends State<EnhancedMapHomePage>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = false;
  bool _isLoadingMotels = false;
  List<Map<String, dynamic>> _allMotels = [];
  double _radius = 10.0;

  late TabController _tabController;

  // Default center (Dar es Salaam, Tanzania)
  static const LatLng _defaultCenter = LatLng(-6.7924, 39.2083);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool hasPermission = await LocationService.requestLocationPermission();
      if (!hasPermission) {
        _showSnackBar(
          'Location permission is required to show motels near you',
        );
        return;
      }

      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _addCurrentLocationMarker();

        // Move camera to current position
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_currentPosition!),
          );
        }

        await _loadMotelsForMap();
      } else {
        _showSnackBar('Unable to get your current location');
      }
    } catch (e) {
      print('Error getting location: $e');
      _showSnackBar('Error getting location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMotelsForMap() async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoadingMotels = true;
    });

    try {
      final response = await NearMeService.getNearMeMotels(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radius: _radius,
        page: 1,
        limit: 50, // Load more motels for the map
      );

      if (response['success'] == true) {
        final List<dynamic> motels = response['data'];
        setState(() {
          _allMotels = motels.cast<Map<String, dynamic>>();
        });
        _addMotelMarkers();
      }
    } catch (e) {
      print('Error loading motels for map: $e');
    } finally {
      setState(() {
        _isLoadingMotels = false;
      });
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: const InfoWindow(
              title: 'Your Location',
              snippet: 'Current position',
            ),
          ),
        );
      });
    }
  }

  void _addMotelMarkers() {
    setState(() {
      _markers.clear();
      _addCurrentLocationMarker();

      for (var motel in _allMotels) {
        if (motel['latitude'] != null && motel['longitude'] != null) {
          final lat = double.tryParse(motel['latitude'].toString());
          final lng = double.tryParse(motel['longitude'].toString());

          if (lat != null && lng != null) {
            final motelType = motel['motel_type'] ?? 'Unknown';
            final markerColor = _getMarkerColorForMotelType(motelType);

            _markers.add(
              Marker(
                markerId: MarkerId('motel_${motel['id']}'),
                position: LatLng(lat, lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
                infoWindow: InfoWindow(
                  title: motel['name'] ?? 'Unknown Motel',
                  snippet:
                      '${motel['motel_type']} • ${DistanceCalculator.formatDistance(motel['distance'] ?? 0.0)} away',
                ),
                onTap: () => _showMotelDetails(motel),
              ),
            );
          }
        }
      }
    });
  }

  double _getMarkerColorForMotelType(String motelType) {
    switch (motelType.toLowerCase()) {
      case 'hotel':
        return BitmapDescriptor.hueBlue;
      case 'resort':
        return BitmapDescriptor.hueGreen;
      case 'inn':
        return BitmapDescriptor.hueOrange;
      case 'guest house':
        return BitmapDescriptor.hueViolet;
      case 'apartment':
        return BitmapDescriptor.hueRed;
      case 'villa':
        return BitmapDescriptor.hueCyan;
      case 'cottage':
        return BitmapDescriptor.hueYellow;
      case 'hostel':
        return BitmapDescriptor.hueMagenta;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  void _showMotelDetails(Map<String, dynamic> motel) {
    final simpleMotel = SimpleMotel(
      id: motel['id'] ?? 0,
      name: motel['name'] ?? 'Unknown Motel',
      frontImage: motel['front_image'],
      streetAddress: motel['street_address'] ?? 'Unknown Street',
      motelType: motel['motel_type'] ?? 'Unknown Type',
      district: motel['district'] ?? 'Unknown District',
      longitude: motel['longitude'] != null
          ? double.tryParse(motel['longitude'].toString())
          : null,
      latitude: motel['latitude'] != null
          ? double.tryParse(motel['latitude'].toString())
          : null,
    );

    NavigationUtil.pushTo(context, BnBDetails(motel: simpleMotel));
  }

  void _onRadiusChanged(double newRadius) {
    setState(() {
      _radius = newRadius;
    });
    _loadMotelsForMap();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? _defaultCenter,
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'BnB Map',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _requestLocationPermission,
                  ),
                ],
              ),
            ),
          ),

          // Radius Selector
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search radius: ${_radius.round()}km',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _radius,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    label: '${_radius.round()}km',
                    onChanged: _onRadiusChanged,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Tab Bar with Motel Lists
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.blue,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(icon: Icon(Icons.location_on), text: 'Near Me'),
                        Tab(
                          icon: Icon(Icons.trending_up),
                          text: 'Top Searched',
                        ),
                        Tab(icon: Icon(Icons.new_releases), text: 'Newest'),
                      ],
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Near Me Tab
                        _isLoadingMotels
                            ? const Center(child: CircularProgressIndicator())
                            : _allMotels.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_off,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No motels found near you',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _allMotels.length,
                                itemBuilder: (context, index) {
                                  final motel = _allMotels[index];
                                  final distance = motel['distance'] ?? 0.0;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: motel['front_image'] != null
                                            ? Image.network(
                                                motel['front_image'],
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        width: 50,
                                                        height: 50,
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                        child: const Icon(
                                                          Icons.hotel,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    },
                                              )
                                            : Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.hotel,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                      title: Text(
                                        motel['name'] ?? 'Unknown Motel',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            motel['street_address'] ??
                                                'Unknown Address',
                                          ),
                                          Text(
                                            '${DistanceCalculator.formatDistance(distance)} away',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'Near You',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      onTap: () => _showMotelDetails(motel),
                                    ),
                                  );
                                },
                              ),

                        // Top Searched Tab
                        const TopSearchMotel(),

                        // Newest Tab
                        const NewRestMotel(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
