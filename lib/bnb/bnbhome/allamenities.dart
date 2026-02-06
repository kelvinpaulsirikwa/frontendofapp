import 'package:bnbfrontendflutter/bnb/bnbhome/amenitiesimages.dart';
import 'package:bnbfrontendflutter/models/bnb_motels_details_model.dart';
import 'package:bnbfrontendflutter/services/motel_detail_service.dart';
import 'package:bnbfrontendflutter/bnb/reusablecomponent/iconslist.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:flutter/material.dart';

class BnBAllAmenities extends StatefulWidget {
  final int motelid;
  final List<BnbAmenityModel>? initialAmenities;

  const BnBAllAmenities({
    super.key,
    required this.motelid,
    this.initialAmenities,
  });

  @override
  State<BnBAllAmenities> createState() => _BnBAllAmenitiesState();
}

class _BnBAllAmenitiesState extends State<BnBAllAmenities> {
  final List<BnbAmenityModel> _amenities = [];
  bool _hasMoreAmenities = true;
  bool _isLoadingMoreAmenities = false;
  int _currentAmenityPage = 0;
  final ScrollController scrollController = ScrollController();

  Future<void> _loadMoreAmenities() async {
    if (!_hasMoreAmenities || _isLoadingMoreAmenities) return;

    setState(() {
      _isLoadingMoreAmenities = true;
    });

    try {
      _currentAmenityPage++;
      final newAmenities = await MotelDetailService.getMotelAmenities(
        widget.motelid,
        page: _currentAmenityPage,
        limit: 10,
      );

      setState(() {
        _amenities.addAll(newAmenities);
        _hasMoreAmenities =
            newAmenities.length == 10; // If we get less than 10, no more pages
        _isLoadingMoreAmenities = false;
      });
    } catch (e) {
      // Error loading more amenities
      setState(() {
        _isLoadingMoreAmenities = false;
      });
      // Show error message or handle gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load more amenities: ${e.toString()}'),
          backgroundColor: deepTerracotta,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialAmenities != null &&
        widget.initialAmenities!.isNotEmpty) {
      _amenities.addAll(widget.initialAmenities!);
      _currentAmenityPage = 1;
      _hasMoreAmenities = widget.initialAmenities!.length >= 10;
    } else {
      _loadMoreAmenities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SingleMGAppBar(
        "All Amenities ",
        context: context,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: softCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 25),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      _hasMoreAmenities) {
                    _loadMoreAmenities();
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _amenities.length + (_hasMoreAmenities ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _amenities.length) {
                      // Loading indicator for more amenities
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: const Center(),
                      );
                    }

                    final amenity = _amenities[index];
                      return GestureDetector(
                        onTap: () =>NavigationUtil.pushwithslideTo(
                                          context,
                                          AmenitiesImages(amenity: amenity),
                                  ),
                        child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: richBrown.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: earthGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                AmenityIcons.getIcon(amenity.name),
                                color: earthGreen,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    amenity.name,
                                    style: const TextStyle(
                                      color: textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (amenity.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      amenity.description!,
                                      style: TextStyle(
                                        color: textDark.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ,
                      );},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
