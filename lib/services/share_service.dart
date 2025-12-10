import 'package:share_plus/share_plus.dart';
import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'package:bnbfrontendflutter/models/bnb_motels_details_model.dart';
import 'package:bnbfrontendflutter/models/bnbroommodel.dart';
import 'package:bnbfrontendflutter/services/bnbconnection.dart';

class ShareService {
  /// Generate shareable web URL for a property/motel
  /// Format: https://bnb.co.tz/motels/{id}
  static String generatePropertyUrl(int propertyId) {
    return '$domain/motels/$propertyId';
  }

  /// Generate shareable web URL for a room
  /// Format: https://bnb.co.tz/motels/{propertyId}/rooms/{roomId}
  static String generateRoomUrl(int roomId, int propertyId) {
    return '$domain/motels/$propertyId/rooms/$roomId';
  }

  /// Share a property with text and deep link
  static Future<void> shareProperty({
    required SimpleMotel motel,
    String? description,
  }) async {
    try {
      final url = generatePropertyUrl(motel.id);
      final shareText = '''
🏨 ${motel.name}

📍 ${motel.streetAddress}, ${motel.district}
🏷️ Type: ${motel.motelType}

${description ?? 'Check out this amazing BnB property!'}

🔗 View Details: $url

Download $appname App for the best experience!
📱 $googleplayurl
      ''';

      await Share.share(
        shareText,
        subject: 'Check out ${motel.name} on Tanzania BnB',
      );
    } catch (e) {
      print('Error sharing property: $e');
      rethrow;
    }
  }

  /// Share a room with text and deep link
  static Future<void> shareRoom({
    required Room room,
    required BnbMotelsDetailsModel property,
  }) async {
    try {
      final url = generateRoomUrl(room.id, property.id);
      final shareText = '''
🛏️ ${room.roomnumber}

📍 ${property.name}
🏷️ ${room.roomtype}
💰 TZS ${room.pricepernight.toStringAsFixed(0)} per night
✅ Status: ${room.status == 'free' ? 'Available' : 'Occupied'}

Check out this room and book now!

🔗 View Room: $url

Download $appname App for the best experience!
📱 $googleplayurl
      ''';

      await Share.share(
        shareText,
        subject: 'Check out ${room.roomnumber} at ${property.name}',
      );
    } catch (e) {
      print('Error sharing room: $e');
      rethrow;
    }
  }

  /// Share an image (can be used for property images, room images, etc.)
  static Future<void> shareImage({
    required String imageUrl,
    String? text,
  }) async {
    try {
      // For sharing images, you can use Share.shareXFiles
      // But first you need to download the image
      // This is a simplified version - you may need to download the image first
      final shareText = text ?? 'Check out this image from Tanzania BnB!';
      
      await Share.share(
        shareText,
        subject: 'Image from Tanzania BnB',
      );
      
      // Note: To share actual image files, you would need to:
      // 1. Download the image using http package
      // 2. Save it temporarily using path_provider
      // 3. Use Share.shareXFiles([XFile(imagePath)])
      // This requires additional implementation
    } catch (e) {
      print('Error sharing image: $e');
      rethrow;
    }
  }

  /// Share property with image (if you want to share both text and image)
  static Future<void> sharePropertyWithImage({
    required SimpleMotel motel,
    String? imageUrl,
    String? description,
  }) async {
    // For now, we'll share text with link
    // Full image sharing implementation would require downloading the image first
    await shareProperty(motel: motel, description: description);
  }
}

