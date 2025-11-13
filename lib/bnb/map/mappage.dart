import 'dart:async';
import 'package:bnbfrontendflutter/utility/componet.dart';
import 'package:bnbfrontendflutter/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  final Function(List<Map<String, dynamic>>)? onMotelsUpdated;
  final List<Map<String, dynamic>>? motels;
  final double? searchRadius;
  final LatLng? searchCenter;

  const MapPage({
    super.key,
    this.onMotelsUpdated,
    this.motels,
    this.searchRadius,
    this.searchCenter,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? currentPosition;
  final Completer<GoogleMapController> _mapcontroller =
      Completer<GoogleMapController>();
  Map<PolylineId, Polyline> polyliness = {};
  BitmapDescriptor? customMarkerIcon;

  // Motel data
  List<Map<String, dynamic>> motels = [];
  Set<Marker> motelMarkers = {};

  // Search radius circle
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    // Initialize with default marker immediately so map can show
    customMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueBlue,
    );
    _initializeLocation();
    _initializeMarkerIcon(); // Load custom icon in background
    if (widget.motels != null && widget.motels!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMotels(widget.motels!);
      });
    }
    // Initialize search circle if provided
    if (widget.searchRadius != null && widget.searchCenter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateSearchCircle();
      });
    }
  }

  @override
  void didUpdateWidget(MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if motels list has changed (by reference or length)
    final currentMotels = widget.motels ?? [];
    final oldMotels = oldWidget.motels ?? [];

    if (currentMotels != oldMotels ||
        currentMotels.length != oldMotels.length ||
        currentMotels.length != motels.length) {
      print(
        '🗺️ MapPage: Motels updated - old: ${oldMotels.length}, new: ${currentMotels.length}, current: ${motels.length}',
      );
      _updateMotels(currentMotels);
    }

    // Update search radius circle if changed
    if (widget.searchRadius != oldWidget.searchRadius ||
        widget.searchCenter != oldWidget.searchCenter) {
      _updateSearchCircle();
    }
  }

  void _updateSearchCircle() {
    setState(() {
      _circles.clear();
      if (widget.searchRadius != null &&
          widget.searchCenter != null &&
          widget.searchRadius! > 0) {
        // Convert radius from km to meters for Circle
        final radiusInMeters = widget.searchRadius! * 1000;
        _circles.add(
          Circle(
            circleId: const CircleId('search_radius'),
            center: widget.searchCenter!,
            radius: radiusInMeters,
            fillColor: Colors.blue.withOpacity(0.15),
            strokeColor: Colors.blue.withOpacity(0.5),
            strokeWidth: 2,
          ),
        );
      }
    });
  }

  Future<void> _initializeLocation() async {
    Position? position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });
    } else {
      // Use default location if location service fails
      setState(() {
        currentPosition = const LatLng(-6.7783, 39.2058); // Dar es Salaam
      });
    }
  }

  Future<void> _initializeMarkerIcon() async {
    // Try to load custom icon, but don't block map display
    try {
      final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/google.png',
      );
      if (mounted) {
        setState(() {
          customMarkerIcon = icon;
        });
        // Update motel markers with new icon if map is already showing
        _updateMotels(motels);
      }
    } catch (error) {
      print('Error loading custom marker icon: $error');
      // Keep default marker, map is already showing
    }
  }

  void _updateMotels(List<Map<String, dynamic>> newMotels) {
    print('🗺️ MapPage: Updating motels - count: ${newMotels.length}');
    setState(() {
      motels = List.from(
        newMotels,
      ); // Create a new list to ensure reference change
      motelMarkers.clear();

      // Create markers for each motel
      for (var motel in motels) {
        if (motel['latitude'] != null && motel['longitude'] != null) {
          final lat = double.tryParse(motel['latitude'].toString());
          final lng = double.tryParse(motel['longitude'].toString());

          if (lat != null && lng != null) {
            final motelId = motel['id'] ?? motel.hashCode;
            motelMarkers.add(
              Marker(
                markerId: MarkerId('motel_$motelId'),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: motel['name'] ?? 'Motel',
                  snippet: motel['street_address'] ?? '',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            );
          }
        }
      }
      print('🗺️ MapPage: Created ${motelMarkers.length} markers');
    });

    // Notify parent if callback exists
    if (widget.onMotelsUpdated != null) {
      widget.onMotelsUpdated!(motels);
    }
  }

  @override
  void dispose() {
    print("🗺️ MapPage: Disposing...");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
      "🔍 MapPage: Building widget - currentPosition: ${currentPosition != null}, customMarkerIcon: ${customMarkerIcon != null}, motels: ${motels.length}, markers: ${motelMarkers.length}",
    );

    return Scaffold(
      appBar: KivuliAppBar(),
      body: currentPosition == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    currentPosition == null
                        ? "Getting your location..."
                        : "Loading map...",
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (currentPosition == null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "Make sure:\n• Location is enabled on your device\n• You're connected to internet\n• Location permissions are granted",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        print("🔄 MapPage: Retrying location...");
                        _initializeLocation();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry Location"),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        print("📍 MapPage: Using default location...");
                        setState(() {
                          currentPosition = const LatLng(-6.7783, 39.2058);
                        });
                      },
                      child: const Text("Use Default Location (Dar es Salaam)"),
                    ),
                  ],
                ],
              ),
            )
          : GoogleMap(
              mapType: MapType.hybrid,
              onMapCreated: (GoogleMapController controller) =>
                  _mapcontroller.complete(controller),
              initialCameraPosition: CameraPosition(
                target: currentPosition!,
                zoom: 14,
              ),
              markers: {
                // Current location marker (blue)
                Marker(
                  markerId: const MarkerId('current_location'),
                  position: currentPosition!,
                  infoWindow: const InfoWindow(title: 'Your Location'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
                // Motel markers (already have red icons set in _updateMotels)
                ...motelMarkers,
              },
              polylines: Set<Polyline>.of(polyliness.values),
              circles: _circles,
            ),
    );
  }
}
