import 'dart:convert';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/services/location_service.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/variable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class DirectMe extends StatefulWidget {
  final String latitude;
  final String longtude;
  final String name;
  const DirectMe({
    super.key,
    required this.latitude,
    required this.longtude,
    required this.name,
  });

  @override
  State<DirectMe> createState() => _DirectMeState();
}

class _DirectMeState extends State<DirectMe> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _destination;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  bool _isLoadingRoute = false;
  String? _errorMessage;
  String _distance = '';
  String _duration = '';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      // Parse destination coordinates
      final destLat = double.tryParse(widget.latitude);
      final destLng = double.tryParse(widget.longtude);

      if (destLat == null || destLng == null) {
        setState(() {
          _errorMessage = 'Invalid destination coordinates';
          _isLoading = false;
        });
        return;
      }

      _destination = LatLng(destLat, destLng);

      // Get current location
      final position = await LocationService.getCurrentLocation();
      
      if (position != null) {
        _currentPosition = LatLng(position.latitude, position.longitude);
      }

      // Update markers
      _updateMarkers();

      // Get route/directions if both positions are available
      if (_currentPosition != null && _destination != null) {
        await _getDirections();
      }

      // Fit camera to show both points
      if (_currentPosition != null && _destination != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitCameraToPoints();
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing map: $e');
      setState(() {
        _errorMessage = 'Error loading map: $e';
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    _markers.clear();

    // Add current location marker
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(
            title: 'Current Location',
            snippet: 'Your current position',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    // Add destination marker
    if (_destination != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination!,
          infoWindow: InfoWindow(
            title: widget.name.isNotEmpty ? widget.name : 'Destination',
            snippet: 'Your target location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }
  }

  Future<void> _fitCameraToPoints() async {
    if (_mapController == null) return;

    if (_currentPosition != null && _destination != null) {
      // Calculate bounds
      final minLat = _currentPosition!.latitude < _destination!.latitude
          ? _currentPosition!.latitude
          : _destination!.latitude;
      final maxLat = _currentPosition!.latitude > _destination!.latitude
          ? _currentPosition!.latitude
          : _destination!.latitude;
      final minLng = _currentPosition!.longitude < _destination!.longitude
          ? _currentPosition!.longitude
          : _destination!.longitude;
      final maxLng = _currentPosition!.longitude > _destination!.longitude
          ? _currentPosition!.longitude
          : _destination!.longitude;

      // Calculate distance to determine appropriate padding
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _destination!.latitude,
        _destination!.longitude,
      );

      // Adjust padding based on distance
      double padding = 80.0; // Default padding
      if (distance > 10000) {
        // Far distance (>10km)
        padding = 50.0;
      } else if (distance > 1000) {
        // Medium distance (1-10km)
        padding = 80.0;
      } else {
        // Close distance (<1km)
        padding = 100.0;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, padding),
      );
    } else if (_destination != null) {
      // Only destination available, center on it
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_destination!, 15),
      );
    }
  }

  LatLng _getInitialCameraPosition() {
    if (_currentPosition != null && _destination != null) {
      // Center between both points
      final centerLat = (_currentPosition!.latitude + _destination!.latitude) / 2;
      final centerLng = (_currentPosition!.longitude + _destination!.longitude) / 2;
      return LatLng(centerLat, centerLng);
    } else if (_destination != null) {
      return _destination!;
    } else if (_currentPosition != null) {
      return _currentPosition!;
    }
    // Default to Tanzania center
    return const LatLng(-6.7924, 39.2083);
  }

  double _getInitialZoom() {
    if (_currentPosition != null && _destination != null) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _destination!.latitude,
        _destination!.longitude,
      );

      if (distance > 10000) {
        return 11.0; // Far
      } else if (distance > 1000) {
        return 13.0; // Medium
      } else {
        return 15.0; // Close
      }
    }
    return 13.0;
  }

  void _showInfoWindows() {
    if (_mapController == null) return;

    // Show both info windows automatically
    // Note: Google Maps shows only one info window at a time, 
    // but we can show them in sequence or show the destination by default
    
    // Show current location first
    if (_currentPosition != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _mapController?.showMarkerInfoWindow(const MarkerId('current_location'));
      });
    }

    // Then show destination (will replace current location info window)
    // You can tap either marker to switch between them
    if (_destination != null) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        _mapController?.showMarkerInfoWindow(const MarkerId('destination'));
      });
    }
  }

  Future<void> _getDirections() async {
    if (_currentPosition == null || _destination == null) {
      print('❌ Cannot get directions: Missing current position or destination');
      return;
    }

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      String origin =
          '${_currentPosition!.latitude},${_currentPosition!.longitude}';
      String dest = '${_destination!.latitude},${_destination!.longitude}';

      String url =
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=$origin&destination=$dest&key=${BnBVariables.googleapikey}';

      print('📡 Requesting directions from: $origin to $dest');

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      print('📥 Directions API Response Status: ${data['status']}');

      if (data['status'] == 'OK') {
        List<dynamic> routes = data['routes'];
        if (routes.isNotEmpty) {
          List<dynamic> legs = routes[0]['legs'];
          if (legs.isNotEmpty) {
            setState(() {
              _distance = legs[0]['distance']['text'] ?? '';
              _duration = legs[0]['duration']['text'] ?? '';
            });
            print('✅ Route found: Distance: $_distance, Duration: $_duration');
          }

          // Decode polyline
          String polylinePoints = routes[0]['overview_polyline']['points'];
          _routePoints = _decodePolyline(polylinePoints);
          print('✅ Decoded ${_routePoints.length} route points');

          // Add polyline to map
          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: deepTerracotta,
                width: 5,
                patterns: [],
              ),
            );
            _isLoadingRoute = false;
          });
        } else {
          throw Exception('No routes found in response');
        }
      } else {
        String errorMsg = _getDirectionsErrorMessage(data['status']);
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Error getting directions: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        print('❌ Network error: No internet connection or timeout');
      }
      
      setState(() {
        _isLoadingRoute = false;
      });

      // Just print error, no dialog
      print('❌ Failed to load route directions. Error details: ${e.toString()}');
    }
  }

  String _getDirectionsErrorMessage(String status) {
    switch (status) {
      case 'ZERO_RESULTS':
        return 'No route found between these locations';
      case 'NOT_FOUND':
        return 'Origin or destination not found';
      case 'INVALID_REQUEST':
        return 'Invalid request. Please check the coordinates';
      case 'OVER_QUERY_LIMIT':
        return 'Google Maps API quota exceeded';
      case 'REQUEST_DENIED':
        return 'Google Maps API request denied. Check API key';
      case 'UNKNOWN_ERROR':
        return 'Unknown error occurred. Please try again';
      default:
        return 'Directions error: $status';
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    try {
      while (index < polyline.length) {
        int b, shift = 0, result = 0;
        do {
          b = polyline.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          b = polyline.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        points.add(LatLng(lat / 1E5, lng / 1E5));
      }
    } catch (e) {
      print('❌ Error decoding polyline: $e');
      print('❌ Polyline string: $polyline');
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SingleMGAppBar("Direct Me", context: context),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: deepTerracotta,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: deepTerracotta,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: textDark,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _initializeMap();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: deepTerracotta,
                          foregroundColor: softCream,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (GoogleMapController controller) async {
                        _mapController = controller;
                        // Fit camera after map is ready
                        await _fitCameraToPoints();
                        // Show info windows automatically
                        _showInfoWindows();
                      },
                      initialCameraPosition: CameraPosition(
                        target: _getInitialCameraPosition(),
                        zoom: _getInitialZoom(),
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      mapType: MapType.normal,
                      myLocationEnabled: _currentPosition != null,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: false,
                      compassEnabled: true,
                    ),
                // Distance and Duration Overlay
                if ((_distance.isNotEmpty || _duration.isNotEmpty) && !_isLoadingRoute)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: softCream,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (_distance.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.straighten, color: deepTerracotta, size: 20),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Distance',
                                      style: TextStyle(
                                        color: textLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _distance,
                                      style: TextStyle(
                                        color: textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          if (_duration.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.access_time, color: deepTerracotta, size: 20),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Time',
                                      style: TextStyle(
                                        color: textLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _duration,
                                      style: TextStyle(
                                        color: textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                // Loading indicator for route
                if (_isLoadingRoute)
                  Positioned(
                    top: 80,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: softCream,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: deepTerracotta,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Loading route...',
                            style: TextStyle(
                              color: textDark,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ],
                ),
    );
  }
}
