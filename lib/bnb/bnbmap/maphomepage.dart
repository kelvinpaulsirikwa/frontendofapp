import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utility/variable.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String _distance = '';
  String _duration = '';
  bool _isLoading = false;
  TextEditingController _destinationController = TextEditingController();
  List<LatLng> _routePoints = [];

  // Default center (Dar es Salaam, Tanzania)
  static const LatLng _defaultCenter = LatLng(-6.7924, 39.2083);

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showToast('Location services are disabled. Please enable them.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showToast('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showToast('Location permissions are permanently denied');
      return;
    }

    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Add current location marker
      _addCurrentLocationMarker();

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 15),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showToast('Error getting location: $e');
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
              title: 'My Location',
              snippet: 'You are here',
            ),
          ),
        );
      });
    }
  }

  Future<void> _searchDestination() async {
    if (_destinationController.text.isEmpty) {
      _showToast('Please enter a destination');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(
        _destinationController.text,
      );

      if (locations.isNotEmpty) {
        LatLng destination = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );

        // Add destination marker
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Destination',
              snippet: _destinationController.text,
            ),
          ),
        );

        // Get directions
        await _getDirections(destination);

        // Move camera to show both locations
        if (_mapController != null && _currentPosition != null) {
          LatLngBounds bounds = _boundsFromLatLngList([
            _currentPosition!,
            destination,
          ]);
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 100),
          );
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showToast('Location not found');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showToast('Error searching location: $e');
    }
  }

  Future<void> _getDirections(LatLng destination) async {
    if (_currentPosition == null) {
      _showToast('Current location not available');
      return;
    }

    try {
      String origin =
          '${_currentPosition!.latitude},${_currentPosition!.longitude}';
      String dest = '${destination.latitude},${destination.longitude}';

      String url =
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=$origin&destination=$dest&key=${BnBVariables.googleapikey}';

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        List<dynamic> routes = data['routes'];
        if (routes.isNotEmpty) {
          List<dynamic> legs = routes[0]['legs'];
          if (legs.isNotEmpty) {
            setState(() {
              _distance = legs[0]['distance']['text'];
              _duration = legs[0]['duration']['text'];
            });
          }

          // Decode polyline
          String polylinePoints = routes[0]['overview_polyline']['points'];
          _routePoints = _decodePolyline(polylinePoints);

          // Add polyline to map
          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: Colors.blue,
                width: 5,
              ),
            );
          });
        }
      } else {
        _showToast('Directions not found');
      }
    } catch (e) {
      _showToast('Error getting directions: $e');
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

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
    return points;
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _clearMap() {
    setState(() {
      _markers.clear();
      _polylines.clear();
      _routePoints.clear();
      _distance = '';
      _duration = '';
      _destinationController.clear();
    });
    _addCurrentLocationMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? _defaultCenter,
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  hintText: 'Search destination...',
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  suffixIcon: _destinationController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _destinationController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                onSubmitted: (_) => _searchDestination(),
              ),
            ),
          ),

          // Floating action buttons
          Positioned(
            bottom: 120,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _clearMap,
                  child: const Icon(Icons.clear, color: Colors.red),
                ),
              ],
            ),
          ),

          // Search button
          Positioned(
            bottom: 120,
            left: 16,
            child: FloatingActionButton.extended(
              onPressed: _searchDestination,
              backgroundColor: Colors.blue,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.directions),
              label: Text(_isLoading ? 'Searching...' : 'Get Directions'),
            ),
          ),

          // Distance and duration info
          if (_distance.isNotEmpty && _duration.isNotEmpty)
            Positioned(
              bottom: 40,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.route, color: Colors.blue),
                        const SizedBox(height: 5),
                        Text(
                          _distance,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text('Distance'),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.access_time, color: Colors.green),
                        const SizedBox(height: 5),
                        Text(
                          _duration,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text('Duration'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
