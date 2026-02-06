import 'package:bnbfrontendflutter/bnb/bnbmap/draggablesheet.dart';
import 'package:bnbfrontendflutter/bnb/map/mappage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RoomsMaps extends StatefulWidget {
  const RoomsMaps({super.key});

  @override
  State<RoomsMaps> createState() => _RoomsMapsState();
}

class _RoomsMapsState extends State<RoomsMaps> {
  List<Map<String, dynamic>> motels = [];
  String _currentTabType = 'near_me'; // Default tab
  double? _searchRadius;
  LatLng? _searchCenter;

  void _onLocationSelected(String location) {
    // You can update state or navigate based on selection
  }

  void _onMotelsUpdated(
    List<Map<String, dynamic>> updatedMotels,
    String tabType,
  ) {
    setState(() {
      // Always update motels if they match the current tab
      // This ensures markers stay in sync when switching tabs
      if (tabType == _currentTabType) {
        motels = List.from(
          updatedMotels,
        ); // Create new list to ensure reference change
      } else {
        // If we're switching tabs but the old tab sends an update, we can optionally
        // clear the motels if the new tab hasn't loaded yet
        // But it's better to keep the old markers visible until new ones load
      }
    });
  }

  void _onTabChanged(String tabType) {
    setState(() {
      _currentTabType = tabType;
      // Clear search radius when switching away from near_me tab
      if (tabType != 'near_me') {
        _searchRadius = null;
        _searchCenter = null;
      }
      // Don't clear motels immediately - let the new tab's data replace them
      // This prevents the map from showing 0 markers briefly
      // The motels will be replaced when the new tab loads its data
    });
  }

  void _onRadiusChanged(double radius, Position? position) {
    setState(() {
      _searchRadius = radius;
      if (position != null) {
        _searchCenter = LatLng(position.latitude, position.longitude);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapPage(
            onMotelsUpdated: (updatedMotels) {
              // Optional: handle if needed
            },
            motels: motels, // Pass motels to MapPage
            searchRadius: _searchRadius,
            searchCenter: _searchCenter,
          ), // The map in the background

          DraggableBottomSheet(
            onLocationSelected: _onLocationSelected,
            motels: motels,
            onMotelsUpdated: _onMotelsUpdated,
            onTabChanged: _onTabChanged,
            onRadiusChanged: _onRadiusChanged,
          ),
        ],
      ),
    );
  }
}
