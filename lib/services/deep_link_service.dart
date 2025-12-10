import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:bnbfrontendflutter/bnb/bnbhome/bnbdetails.dart';
import 'package:bnbfrontendflutter/bnb/bnbhome/bnbroomdetails.dart';
import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'package:bnbfrontendflutter/services/motel_detail_service.dart';
import 'package:bnbfrontendflutter/services/room_service.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';

class DeepLinkService {
  static StreamSubscription<Uri>? _linkSubscription;
  static final AppLinks _appLinks = AppLinks();
  static bool _initialUriHandled = false;

  /// Initialize deep link handling
  static Future<void> init(BuildContext context) async {
    // Handle initial URI if app was opened via deep link
    if (!_initialUriHandled) {
      _initialUriHandled = true;
      try {
        final initialUri = await _appLinks.getInitialLink();
        if (initialUri != null) {
          _handleDeepLink(context, initialUri);
        }
      } catch (e) {
        print('Error getting initial URI: $e');
      }
    }

    // Listen for incoming deep links while app is running
    _linkSubscription?.cancel();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        if (context.mounted) {
          _handleDeepLink(context, uri);
        }
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  /// Handle deep link and navigate to appropriate screen
  static Future<void> _handleDeepLink(BuildContext context, Uri uri) async {
    try {
      print('🔗 Handling deep link: $uri');

      final pathSegments = uri.pathSegments;
      
      if (pathSegments.isEmpty) {
        return;
      }

      // Pattern 1: Web URL - /motels/{id} (https://bnb.co.tz/motels/15)
      if (pathSegments.length == 2 && pathSegments[0] == 'motels') {
        final propertyId = int.tryParse(pathSegments[1]);
        if (propertyId != null) {
          await _navigateToProperty(context, propertyId);
        }
        return;
      }
      
      // Pattern 2: Web URL - /motels/{propertyId}/rooms/{roomId} (https://bnb.co.tz/motels/15/rooms/12)
      if (pathSegments.length == 4 &&
          pathSegments[0] == 'motels' &&
          pathSegments[2] == 'rooms') {
        final propertyId = int.tryParse(pathSegments[1]);
        final roomId = int.tryParse(pathSegments[3]);
        
        if (propertyId != null && roomId != null) {
          await _navigateToRoom(context, propertyId, roomId);
        }
        return;
      }
    } catch (e) {
      print('Error handling deep link: $e');
    }
  }

  /// Navigate to property details page
  static Future<void> _navigateToProperty(
      BuildContext context, int propertyId) async {
    try {
      // Fetch property details
      final propertyDetail = await MotelDetailService.getMotelDetails(propertyId);
      
      if (propertyDetail == null) {
        throw Exception('Property not found');
      }
      
      // Convert to SimpleMotel for navigation
      final simpleMotel = SimpleMotel(
        id: propertyDetail.id,
        name: propertyDetail.name,
        frontImage: propertyDetail.frontImage,
        streetAddress: propertyDetail.streetAddress,
        motelType: propertyDetail.motelType,
        district: propertyDetail.district,
        longitude: propertyDetail.longitude,
        latitude: propertyDetail.latitude,
      );

      if (context.mounted) {
        NavigationUtil.pushTo(context, BnBDetails(motel: simpleMotel));
      }
    } catch (e) {
      print('Error navigating to property: $e');
      // Show error message to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load property details: $e'),
          ),
        );
      }
    }
  }

  /// Navigate to room details page
  static Future<void> _navigateToRoom(
      BuildContext context, int propertyId, int roomId) async {
    try {
      // Fetch property details (needed for room details page)
      final propertyDetail =
          await MotelDetailService.getMotelDetails(propertyId);

      if (propertyDetail == null) {
        throw Exception('Property not found');
      }

      // Fetch room details
      final rooms = await RoomService.getMotelRooms(propertyId);
      final room = rooms.firstWhere(
        (r) => r.id == roomId,
        orElse: () => throw Exception('Room not found'),
      );

      if (context.mounted) {
        NavigationUtil.pushTo(
          context,
          BnBRoomDetails(
            room: room,
            motelsDetailsModel: propertyDetail,
          ),
        );
      }
    } catch (e) {
      print('Error navigating to room: $e');
      // Show error message to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load room details: $e'),
          ),
        );
      }
    }
  }

  /// Dispose deep link service
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}

