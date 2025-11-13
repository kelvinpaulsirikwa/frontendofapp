import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/models/bnb_motels_details_model.dart';
import 'package:bnbfrontendflutter/models/bnbroommodel.dart';
import 'package:bnbfrontendflutter/models/room_detail_model.dart';
import 'package:bnbfrontendflutter/services/room_detail_service.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:bnbfrontendflutter/bnb/bookingpage/booking.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/errorcontentretry.dart';
import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:bnbfrontendflutter/utility/loading.dart';
import 'package:bnbfrontendflutter/utility/text.dart';
import 'package:flutter/material.dart';

class BnBRoomDetails extends StatefulWidget {
  final Room room;
  final BnbMotelsDetailsModel motelsDetailsModel;
  const BnBRoomDetails({
    super.key,
    required this.room,
    required this.motelsDetailsModel,
  });

  @override
  State<BnBRoomDetails> createState() => _BnBRoomDetailsState();
}

class _BnBRoomDetailsState extends State<BnBRoomDetails>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  late AnimationController _loadingController;

  // Real data from API
  List<RoomImageModel> _images = [];
  List<RoomItemModel> _items = [];

  @override
  void initState() {
    super.initState();
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
    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Load room details, images, and items in parallel
      final results = await Future.wait([
        RoomDetailService.getRoomImages(widget.room.id, page: 1, limit: 5),
        RoomDetailService.getRoomItems(widget.room.id, page: 1, limit: 10),
      ]);

      setState(() {
        _images = results[0] as List<RoomImageModel>;
        _items = results[1] as List<RoomItemModel>;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print('Error loading room data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Failed to load room details. Please check your internet connection.';
      });
    }
  }

  void _showAllImages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: softCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: richBrown.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Room Images (${_images.length})',
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: richBrown.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: richBrown,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final image = _images[index];
                    return GestureDetector(
                      onTap: () => Showimage.showFullScreenImage(
                        context,
                        image.imageUrl,
                        widget.room.roomnumber,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          image.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: richBrown.withOpacity(0.1),
                                child: const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: richBrown,
                                ),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: richBrown.withOpacity(0.05),
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: _loadingController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      size: const Size(30, 30),
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
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _loadingController.dispose();
    super.dispose();
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
            widget.room.roomnumber,
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
          onRetry: _loadRoomData,
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
                        _showTitle ? widget.room.roomnumber : '',
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
                  icon: Icons.share,
                  backgroundColor: softCream,
                  iconColor: richBrown,
                  onTap: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () => Showimage.showFullScreenImage(
                  context,
                  widget.room.frontimage.toString(),
                  widget.room.roomnumber,
                ),
                child: Showimage.networkImage(
                  imageUrl: widget.room.frontimage.toString(),
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
                      Text(
                        widget.room.roomnumber,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: deepTerracotta,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.motelsDetailsModel.name,
                              style: const TextStyle(
                                color: textLight,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TZS ${widget.room.pricepernight.toStringAsFixed(0)}',
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: widget.room.status == 'free'
                                  ? earthGreen.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.room.status == 'free'
                                  ? 'Available'
                                  : 'Occupied',
                              style: TextStyle(
                                color: widget.room.status == 'free'
                                    ? earthGreen
                                    : Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Container(
                  color: softCream,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      TextWidgets.iconTextRow(
                        icon: Icons.bed,
                        text: 'Room Information',
                      ),
                      const SizedBox(height: 16),

                      // Total Rooms
                      TextWidgets.simpleText(
                        text: 'BnB name: ${widget.motelsDetailsModel.name}',
                      ),

                      const SizedBox(height: 12),
                      TextWidgets.simpleText(
                        text:
                            'BnB type: ${widget.motelsDetailsModel.motelType}',
                      ),

                      const SizedBox(height: 12),
                      TextWidgets.simpleText(
                        text:
                            'Bnb District: ${widget.motelsDetailsModel.district}',
                      ),

                      const SizedBox(height: 12),
                      TextWidgets.simpleText(
                        text:
                            'BnB address: ${widget.motelsDetailsModel.streetAddress}',
                      ),

                      const SizedBox(height: 12),
                      TextWidgets.simpleText(
                        text: 'Room Type: ${widget.room.roomtype}',
                      ),

                      const SizedBox(height: 12),

                      // Available Rooms
                      TextWidgets.simpleText(
                        text: 'Available Rooms: ${widget.room.status}',
                      ),
                      const SizedBox(height: 12),

                      // Motel Type
                      if (widget.motelsDetailsModel.contactPhone != null) ...[
                        TextWidgets.simpleText(
                          text:
                              'Contact: ${widget.motelsDetailsModel.contactPhone}',
                        ),
                      ],

                      if (widget.motelsDetailsModel.contactEmail != null) ...[
                        const SizedBox(height: 12),
                        TextWidgets.simpleText(
                          text:
                              'Email: ${widget.motelsDetailsModel.contactEmail}',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Room Items Section
                Container(
                  color: softCream,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidgets.iconTextRow(
                        icon: Icons.room_service,
                        text: 'Room Items',
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: warmSand,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: earthGreen.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _loadingController,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: const Size(40, 40),
                                  painter: TanzanianLoadingPainter(
                                    animationValue: _loadingController.value,
                                    terracotta: deepTerracotta,
                                    green: earthGreen,
                                    orange: sunsetOrange,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      else if (_items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: warmSand,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: earthGreen.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'No room items available',
                              style: TextStyle(
                                color: textLight.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _items
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: earthGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: earthGreen.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (item.description != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          item.description!,
                                          style: TextStyle(
                                            color: textLight.withOpacity(0.8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Room Images Section
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
                            icon: Icons.image,
                            text: 'Room Images',
                          ),
                          if (_images.isNotEmpty)
                            GestureDetector(
                              onTap: () => _showAllImages(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: earthGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: earthGreen.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        color: earthGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: earthGreen,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isLoading)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: warmSand,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: earthGreen.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _loadingController,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: const Size(40, 40),
                                  painter: TanzanianLoadingPainter(
                                    animationValue: _loadingController.value,
                                    terracotta: deepTerracotta,
                                    green: earthGreen,
                                    orange: sunsetOrange,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      else if (_images.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: warmSand,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: earthGreen.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: textLight.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No images found for this room',
                                  style: TextStyle(
                                    color: textLight.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length > 5 ? 5 : _images.length,
                            itemBuilder: (context, index) {
                              if (index == 4 && _images.length > 5) {
                                // Last item shows "+X more"
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          _images[index].imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: earthGreen
                                                        .withOpacity(0.1),
                                                    child: const Icon(
                                                      Icons.image,
                                                      color: earthGreen,
                                                      size: 24,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '+${_images.length - 4}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () => Showimage.showFullScreenImage(
                                    context,
                                    _images[index].imageUrl,
                                    widget.room.roomnumber,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _images[index].imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 80,
                                                height: 80,
                                                color: earthGreen.withOpacity(
                                                  0.1,
                                                ),
                                                child: const Icon(
                                                  Icons.image,
                                                  color: earthGreen,
                                                  size: 24,
                                                ),
                                              ),
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              color: earthGreen.withOpacity(
                                                0.05,
                                              ),
                                              child: Center(
                                                child: AnimatedBuilder(
                                                  animation: _loadingController,
                                                  builder: (context, child) {
                                                    return CustomPaint(
                                                      size: const Size(30, 30),
                                                      painter:
                                                          TanzanianLoadingPainter(
                                                            animationValue:
                                                                _loadingController
                                                                    .value,
                                                            terracotta:
                                                                deepTerracotta,
                                                            green: earthGreen,
                                                            orange:
                                                                sunsetOrange,
                                                          ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
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
                      '${widget.room.pricepernight.toStringAsFixed(0)} Tsh',
                      style: const TextStyle(
                        color: deepTerracotta,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Per Night',
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
                    NavigationUtil.pushTo(
                      context,
                      BookingPage(room: widget.room),
                    );
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
