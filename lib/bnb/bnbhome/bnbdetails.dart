import 'package:bnbfrontendflutter/bnb/bnbhome/allamenities.dart';
import 'package:bnbfrontendflutter/bnb/bnbhome/amenitiesimages.dart';
import 'package:bnbfrontendflutter/bnb/bnbhome/bnbimages.dart';
import 'package:bnbfrontendflutter/bnb/bnbhome/bnbrooms.dart';
import 'package:bnbfrontendflutter/bnb/bnbhome/bnbrules.dart';
import 'package:bnbfrontendflutter/bnb/bnbhome/directme.dart';
import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'package:bnbfrontendflutter/models/bnb_motels_details_model.dart';
import 'package:bnbfrontendflutter/services/favorites_service.dart';
import 'package:bnbfrontendflutter/services/motel_detail_service.dart';
import 'package:bnbfrontendflutter/utility/amenities.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/errorcontentretry.dart';
import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:bnbfrontendflutter/utility/loading.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:bnbfrontendflutter/utility/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BnBDetails extends StatefulWidget {
  final SimpleMotel motel;
  const BnBDetails({super.key, required this.motel});

  @override
  State<BnBDetails> createState() => _BnBDetailsState();
}

class _BnBDetailsState extends State<BnBDetails> with TickerProviderStateMixin {
  bool _isFavorite = false;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  late AnimationController _loadingController;
  late final ValueListenable<Box<dynamic>> _favoritesListenable;
  late final VoidCallback _favoritesListener;

  // Real data from API
  BnbMotelsDetailsModel? _motelDetail;
  List<BnbImageModel> _images = [];
  List<BnbAmenityModel> _amenities = [];

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoritesService.isFavorite(widget.motel.id);
    _favoritesListenable = FavoritesService.listenable();
    _favoritesListener = () {
      final isFav = FavoritesService.isFavorite(widget.motel.id);
      if (mounted && isFav != _isFavorite) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    };
    _favoritesListenable.addListener(_favoritesListener);
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showTitle) {
        setState(() {
          _showTitle = true;
        });
      } else if (_scrollController.offset <= 200 && _showTitle) {
        setState(() {
          _showTitle = false;
        });
      }
    });
    _loadMotelData();
  }

  Future<void> _loadMotelData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Load motel details, images, and amenities in parallel
      final results = await Future.wait([
        MotelDetailService.getMotelDetails(widget.motel.id),
        MotelDetailService.getMotelImages(widget.motel.id, page: 1, limit: 5),
        MotelDetailService.getMotelAmenities(
          widget.motel.id,
          page: 1,
          limit: 10,
        ),
      ]);

      setState(() {
        _motelDetail = results[0] as BnbMotelsDetailsModel?;
        _images = results[1] as List<BnbImageModel>;
        _amenities = results[2] as List<BnbAmenityModel>;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print('Error loading motel data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Failed to load motel details. Please check your internet connection.';
      });
    }
  }

  @override
  void dispose() {
    _favoritesListenable.removeListener(_favoritesListener);
    _scrollController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _showAmenityDetails(BuildContext context, BnbAmenityModel amenity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) =>
            AmenitiesImages(amenity: amenity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show error state
    if (_hasError) {
      return Scaffold(
        backgroundColor: warmSand,
        appBar: AppBar(
          backgroundColor: richBrown,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: softCream),
            onPressed: () => NavigationUtil.pop(context),
          ),
          title: Text(
            widget.motel.name,
            style: const TextStyle(
              color: softCream,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: ErrorContent(
          message: _errorMessage,
          color: deepTerracotta,
          onRetry: _loadMotelData,
        ),
      );
    }

    return Scaffold(
      backgroundColor: warmSand,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with Image Gallery
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: richBrown,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconContainer(
                    icon: Icons.arrow_back,
                    backgroundColor: softCream,
                    iconColor: textDark,
                    onTap: () => NavigationUtil.pop(context),
                  ),
                ),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: _showTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Text(
                        widget.motel.name,
                        style: const TextStyle(
                          color: softCream,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconContainer(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  backgroundColor: softCream,
                  iconColor: _isFavorite ? Colors.red : richBrown,
                  onTap: () async {
                    final messenger = ScaffoldMessenger.maybeOf(context);
                    final added = await FavoritesService.toggleFavorite(
                      widget.motel,
                    );
                    if (!mounted) return;
                    setState(() {
                      _isFavorite = added;
                    });
                    if (messenger != null) {
                      final message = added
                          ? '${widget.motel.name} added to favorites'
                          : '${widget.motel.name} removed from favorites';
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(message),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                    }
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () => Showimage.showFullScreenImage(
                  context,
                  widget.motel.frontImage.toString(),
                  widget.motel.name,
                ),
                child: Showimage.networkImage(
                  imageUrl: widget.motel.frontImage.toString(),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  color: softCream,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: earthGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.motel.motelType,
                              style: const TextStyle(
                                color: softCream,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: deepTerracotta,
                          ),
                          const SizedBox(width: 4),
                          // Wrap the text in Flexible to prevent overflow
                          Flexible(
                            child: Text(
                              '${widget.motel.streetAddress}, ${widget.motel.district}',
                              style: const TextStyle(
                                color: textLight,
                                fontSize: 14,
                              ),
                              maxLines: 2, // Limit to 2 lines
                              overflow: TextOverflow
                                  .ellipsis, // Add ellipsis if text too long
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.motel.name,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Loading state for Photos section
                      if (_isLoading)
                        Container(
                          color: softCream,
                          padding: const EdgeInsets.fromLTRB(0, 20, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidgets.iconTextRow(
                                    icon: Icons.photo_library,
                                    text: 'Photos',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 80,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedBuilder(
                                        animation: _loadingController,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            size: const Size(40, 40),
                                            painter: TanzanianLoadingPainter(
                                              animationValue:
                                                  _loadingController.value,
                                              terracotta: deepTerracotta,
                                              green: earthGreen,
                                              orange: sunsetOrange,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Loading photos...',
                                        style: TextStyle(
                                          color: textLight,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Photo Gallery Section
                      if (!_isLoading)
                        Container(
                          color: softCream,
                          padding: const EdgeInsets.fromLTRB(0, 20, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidgets.iconTextRow(
                                    icon: Icons.photo_library,
                                    text: 'Photos',
                                  ),
                                  SmallContainer(
                                    whatToShow: 'View All',
                                    showArrow: true,
                                    onTap: () {
                                      NavigationUtil.pushwithslideTo(
                                        context,
                                        BnBHotelImages(
                                          motelid: widget.motel.id,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images.length > 5
                                      ? 5
                                      : _images.length,
                                  itemBuilder: (context, index) {
                                    if (index == 4 && _images.length > 5) {
                                      // Last item shows "+X more"
                                      return Showimage.showSmallImage(
                                        _images[index].imageUrl,
                                        context,
                                        widget.motel.name,
                                      );
                                    }
                                    return Showimage.showSmallImage(
                                      _images[index].imageUrl,
                                      context,
                                      widget.motel.name.toString(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),
                      TextWidgets.iconTextRow(
                        icon: Icons.stadium_outlined,
                        text: "Status",
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          TextWidgets.iconTextColumn(
                            icon: Icons.bed, // Total Rooms icon
                            text: 'Rooms',
                            number: _motelDetail?.totalRooms ?? 2,
                          ),
                          const SizedBox(width: 12),
                          TextWidgets.iconTextColumn(
                            icon: Icons.meeting_room, // Occupied Rooms icon
                            text: 'Occupied',
                            number:
                                (_motelDetail?.totalRooms ?? 2) -
                                (_motelDetail?.availableRooms ?? 0),
                          ),
                          const SizedBox(width: 12),
                          TextWidgets.iconTextColumn(
                            number: _motelDetail?.availableRooms ?? 2,
                            icon: Icons.hotel, // Free Rooms icon
                            text: 'Free',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Container(
                  color: softCream,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidgets.iconTextRow(
                        icon: Icons.description,
                        text: 'Description',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _motelDetail?.description ??
                            _motelDetail?.description ??
                            'Loading Description...',
                        style: TextStyle(
                          color: textLight.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Amenities
                Container(
                  color: softCream,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidgets.iconTextRow(
                            icon: Icons.star_border,
                            text: "Amenities",
                          ),
                          if (_amenities.isNotEmpty)
                            SmallContainer(
                              whatToShow: 'View All',
                              showArrow: true,
                              onTap: () {
                                NavigationUtil.pushwithslideTo(
                                  context,
                                  BnBAllAmenities(motelid: widget.motel.id),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _amenities.length > 8
                              ? 8
                              : _amenities.length,
                          itemBuilder: (context, index) {
                            final amenity = _amenities[index];
                            return AmenityCard(
                              amenity: amenity,
                              onTap: () =>
                                  _showAmenityDetails(context, amenity),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Host Information
                Container(
                  color: softCream,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidgets.iconTextRow(
                        icon: Icons.merge_outlined,
                        text: "Office Details",
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Contact: ${_motelDetail?.contactPhone ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: textLight,
                                    fontSize: 12,
                                  ),
                                ),
                                if (_motelDetail?.contactEmail != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Email: ${_motelDetail?.contactEmail}',
                                    style: const TextStyle(
                                      color: textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SmallContainer(
                            whatToShow: 'Rules',
                            showArrow: false,
                            onTap: () {
                              NavigationUtil.pushwithslideTo(
                                context,
                                BnBRules(
                                  motelid: widget.motel.id,
                                  moteldetails: widget.motel,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Reviews
                // Location Section
                Container(
                  color: softCream,
                  padding: const EdgeInsets.fromLTRB(5, 20, 5, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidgets.iconTextRow(
                            icon: Icons.map,
                            text: "Location",
                          ),
                          SmallContainer(
                            whatToShow: 'Direct Me',
                            showArrow: false,
                            onTap: () {
                              NavigationUtil.pushwithslideTo(
                                context,
                                DirectMe(
                                  latitude: widget.motel.latitude.toString(),
                                  longtude: widget.motel.longitude.toString(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // Add a Container with fixed height for the map
                      SizedBox(
                        height: 500, // Fixed height for the map
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Optional: rounded corners
                          child: GoogleMap(
                            mapType: MapType.hybrid,
                            onMapCreated: (GoogleMapController controller) {},
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                widget.motel.latitude ?? 0.0,
                                widget.motel.longitude ?? 0.0,
                              ),
                              zoom: 13,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('motel_location'),
                                position: LatLng(
                                  widget.motel.latitude ?? 0.0,
                                  widget.motel.longitude ?? 0.0,
                                ),
                                infoWindow: InfoWindow(
                                  title: widget.motel.name,
                                ),
                              ),
                            },
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: true,
                            mapToolbarEnabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //share
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.share,
                                color: richBrown,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Share This ${widget.motel.motelType}',
                                style: const TextStyle(
                                  color: richBrown,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom booking bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: softCream,
          boxShadow: [
            BoxShadow(
              color: richBrown.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_motelDetail?.availableRooms ?? 0} Available',
                      style: const TextStyle(
                        color: deepTerracotta,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'View Rooms &',
                      style: TextStyle(
                        color: textLight.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_motelDetail?.id != null) {
                      NavigationUtil.pushTo(
                        context,
                        BnBRooms(motelsDetailsModel: _motelDetail!),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [earthGreen, deepTerracotta],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: earthGreen.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Book Now',
                          style: TextStyle(
                            color: softCream,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: softCream, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
