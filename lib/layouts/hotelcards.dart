import 'package:bnbfrontendflutter/bnb/bnbhome/bnbdetails.dart';
import 'package:bnbfrontendflutter/bnb/bnbhome/bnbroomdetails.dart';
import 'package:bnbfrontendflutter/bnb/bookingpage/booking.dart';
import 'package:bnbfrontendflutter/bnb/reusablecomponent/buttons.dart';
import 'package:bnbfrontendflutter/services/favorites_service.dart';
import 'package:bnbfrontendflutter/services/location_service.dart';
import 'package:bnbfrontendflutter/models/bnb_motels_details_model.dart';
import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'package:bnbfrontendflutter/models/bnbroommodel.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:bnbfrontendflutter/utility/distance_calculator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class HotelCards {
  static Widget horizontalHotelCard({
    required SimpleMotel motel,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        NavigationUtil.pushTo(context, BnBDetails(motel: motel));
      },
      child: SingleChildScrollView(
        child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: softCream,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: richBrown.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    sunsetOrange.withOpacity(0.3),
                    earthGreen.withOpacity(0.3),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: richBrown.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Showimage.networkImage(
                        imageUrl: motel.frontImage?.toString() ?? '',
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: earthGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (motel.motelType),
                        style: const TextStyle(
                          color: softCream,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FavoriteToggleButton(motel: motel),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Motel name
        Text(
          motel.name,
          style: const TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 6),

        // Address row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15,
              color: textLight,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${motel.streetAddress}, ${motel.district}',
                style: const TextStyle(
                  color: textLight,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Distance and View button row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Distance info
            Row(
              children: [
                const Icon(
                  Icons.directions_sharp,
                  size: 14,
                  color: textLight,
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 120, // Fixed width to prevent overflow
                  child: FutureBuilder<Position?>(
                    future: LocationService.getCurrentLocation(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Calculating...',
                          style: TextStyle(color: textLight, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }

                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data == null ||
                          motel.latitude == null ||
                          motel.longitude == null) {
                        return const Text(
                          'Distance unavailable',
                          style: TextStyle(color: textLight, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }

                      final currentPosition = snapshot.data!;
                      final distance = DistanceCalculator.calculateDistance(
                        currentPosition.latitude,
                        currentPosition.longitude,
                        motel.latitude!,
                        motel.longitude!,
                      );
                      final formattedDistance = DistanceCalculator.formatDistance(distance);

                      return Text(
                        '$formattedDistance away',
                        style: const TextStyle(color: textLight, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    },
                  ),
                ),
              ],
            ),

            // View button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: earthGreen, width: 1.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: earthGreen,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 12,
                    color: earthGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
)

          ],
        ),
      ),
    ));
  }

static Widget verticalHotelCard({
  required SimpleMotel motel,
  required BuildContext context,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => NavigationUtil.pushTo(context, BnBDetails(motel: motel)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Hotel Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: motel.frontImage != null && motel.frontImage!.isNotEmpty
                          ? Showimage.networkImage(imageUrl: motel.frontImage!)
                          : Container(
                              color: earthGreen.withOpacity(0.1),
                              child: const Icon(Icons.hotel, size: 32, color: earthGreen),
                            ),
                    ),
                  ),
                  // Favorite toggle
                  Positioned(
                    top: 4,
                    right: 4,
                    child: FavoriteToggleButton(motel: motel),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Right: Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Motel type badge + Name
                    Row(
                      children: [
                       
                        const SizedBox(width: 0.18),
                        Expanded(
                          child: Text(
                            motel.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Address
                    Text(
                      '${motel.streetAddress}, ${motel.district}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Rating or additional info (optional)
                   
                   Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: earthGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            motel.motelType,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: earthGreen,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: earthGreen, width: 1.5),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: earthGreen,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: earthGreen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ), 
                   
                   ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  static Widget verticalHotelRooms({
    required BnbMotelsDetailsModel motelsDetailsModel,
    required Room room,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        NavigationUtil.pushTo(
          context,
          BnBRoomDetails(
            room: room,
            motelsDetailsModel: motelsDetailsModel,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: softCream,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: richBrown.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: room.frontimage.isNotEmpty
                    ? SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Showimage.networkImage(
                          imageUrl: room.frontimage,
                        ),
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: earthGreen.withOpacity(0.1),
                        child: const Icon(
                          Icons.bed,
                          size: 60,
                          color: earthGreen,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: room.status == 'free'
                        ? earthGreen
                        : Colors.red.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    room.status == 'free' ? 'Available' : 'Occupied',
                    style: const TextStyle(
                      color: softCream,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Room details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Room: ${room.roomnumber}',
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: deepTerracotta.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        room.roomtype,
                        style: const TextStyle(
                          color: deepTerracotta,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Room details row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TZS ${room.pricepernight.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: earthGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'per night',
                          style: TextStyle(
                            color: textLight.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Buttons.bookNowButton(
                      text: 'View Details',
                      onTap: () {
                        NavigationUtil.pushTo(
                          context,
                          BnBRoomDetails(
                            room: room,
                            motelsDetailsModel: motelsDetailsModel,
                          ),
                        );
                      },
                    ),
                    Buttons.bookNowButton(
                      text: 'Book Now',
                      onTap: () {
                        NavigationUtil.pushTo(context, BookingPage(room: room));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class FavoriteToggleButton extends StatelessWidget {
  final SimpleMotel motel;

  const FavoriteToggleButton({super.key, required this.motel});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FavoritesService.listenable(),
      builder: (context, box, _) {
        final isFavorite = FavoritesService.isFavorite(motel.id);

        return GestureDetector(
          onTap: () async {
            final messenger = ScaffoldMessenger.maybeOf(context);

            if (isFavorite) {
              final confirm =
                  await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        'Remove "${motel.name}" from your favorites?',
                      ),

                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (!confirm) return;
            }

            final added = await FavoritesService.toggleFavorite(motel);
            messenger
              ?..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    '${motel.name} ${added ? 'added to' : 'removed from'} favorites',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: softCream,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: isFavorite ? sunsetOrange : deepTerracotta,
            ),
          ),
        );
      },
    );
  }
}
