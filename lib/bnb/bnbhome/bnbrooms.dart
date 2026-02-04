import 'package:bnbfrontendflutter/layouts/hotelcards.dart';
import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/layouts/loading.dart';
import 'package:bnbfrontendflutter/models/bnb_motels_details_model.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/errorcontentretry.dart';
import 'package:bnbfrontendflutter/utility/loading.dart';
import 'package:bnbfrontendflutter/models/bnbroommodel.dart';
import 'package:bnbfrontendflutter/services/room_service.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/utility/images.dart';

class BnBRooms extends StatefulWidget {
  final BnbMotelsDetailsModel motelsDetailsModel;
  const BnBRooms({super.key, required this.motelsDetailsModel});

  @override
  State<BnBRooms> createState() => _BnBRoomsState();
}

class _BnBRoomsState extends State<BnBRooms> with TickerProviderStateMixin {
  String _selectedFilter = 'All';
  List<String> _filters = ['All', 'Available'];
  bool _isInfoExpanded = false;

  // Real room data
  List<Room> _rooms = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  bool _hasError = false;
  String _errorMessage = '';
  final ScrollController _scrollController = ScrollController();
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _loadMotelRoomTypes();
    _loadRooms();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoading) {
        _loadMoreRooms();
      }
    }
  }

  Future<void> _loadMotelRoomTypes() async {
    try {
      final roomTypes = await RoomService.getMotelRoomTypes(
        widget.motelsDetailsModel.id,
      );
      setState(() {
        _filters = ['All', 'Available', ...roomTypes];
      });
    } catch (e) {
      print('Error loading motel room types: $e');
    }
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final rooms = await RoomService.getMotelRooms(
        widget.motelsDetailsModel.id,
        page: 1,
        limit: 10,
        status: _selectedFilter == 'Available' ? 'available' : null,
        roomType: _selectedFilter != 'All' && _selectedFilter != 'Available'
            ? _selectedFilter
            : null,
      );

      setState(() {
        _rooms = rooms;
        _currentPage = 1;
        _hasMore = rooms.length == 10;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print('Error loading rooms: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Failed to load rooms. Please check your internet connection.';
      });
    }
  }

  Future<void> _loadMoreRooms() async {
    if (_hasMore && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        _currentPage++;
        final moreRooms = await RoomService.getMotelRooms(
          widget.motelsDetailsModel.id,
          page: _currentPage,
          limit: 10,
          status: _selectedFilter == 'Available' ? 'available' : null,
          roomType: _selectedFilter != 'All' && _selectedFilter != 'Available'
              ? _selectedFilter
              : null,
        );

        setState(() {
          _rooms.addAll(moreRooms);
          _hasMore = moreRooms.length == 10;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading more rooms: $e');
        setState(() {
          _isLoading = false;
        });
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more rooms: ${e.toString()}'),
            backgroundColor: deepTerracotta,
          ),
        );
      }
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadRooms();
  }

  List<Room> get _filteredRooms {
    return _rooms;
  }

  @override
  Widget build(BuildContext context) {
    // Show error state
    if (_hasError) {
      return Scaffold(
        backgroundColor: warmSand,
        appBar: SingleMGAppBar(
          '${widget.motelsDetailsModel.name} Rooms',
          context: context,
        ),
        body: ErrorContent(
          message: _errorMessage,
          color: deepTerracotta,
          onRetry: _loadRooms,
        ),
      );
    }

    return Scaffold(
      backgroundColor: warmSand,
      appBar: SingleMGAppBar(
        '${widget.motelsDetailsModel.name} Rooms',
        context: context,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconContainer(
              icon: Icons.info,
              backgroundColor: softCream,
              iconColor: richBrown,
              onTap: () {
                setState(() {
                  _isInfoExpanded = !_isInfoExpanded;
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips - Fixed at top
          Container(
            color: softCream,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        _onFilterChanged(filter);
                      },
                      showCheckmark: false,
                      backgroundColor: Colors.white,
                      selectedColor: earthGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? softCream : textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? earthGreen
                              : richBrown.withOpacity(0.2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Scrollable content area
          Expanded(
            child: _isLoading && _rooms.isEmpty
                ? Center(
                    child: 
                    Loading.infiniteLoading(context),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(0),
                    itemCount: 1 + _filteredRooms.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // First item: Collapsible Motel Info Card
                      if (index == 0) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          color: softCream,
                          child: Column(
                            children: [
                              // Expandable content
                              AnimatedCrossFade(
                                firstChild: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Motel Image
                                      if (widget
                                              .motelsDetailsModel
                                              .frontImage !=
                                          null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: SizedBox(
                                            height: 140,
                                            width: double.infinity,
                                            child: Showimage.networkImage(
                                              imageUrl: widget
                                                  .motelsDetailsModel
                                                  .frontImage!,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 16),

                                      // Motel Name
                                      Text(
                                        widget.motelsDetailsModel.name,
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Location
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: deepTerracotta,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${widget.motelsDetailsModel.streetAddress}, ${widget.motelsDetailsModel.district}',
                                              style: const TextStyle(
                                                color: textLight,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Info Grid
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoCard(
                                              icon: Icons.hotel,
                                              label: 'Total Rooms',
                                              value:
                                                  '${widget.motelsDetailsModel.totalRooms ?? 0}',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildInfoCard(
                                              icon: Icons.check_circle,
                                              label: 'Available',
                                              value:
                                                  '${widget.motelsDetailsModel.availableRooms ?? 0}',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Motel Type
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: earthGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.category,
                                              size: 16,
                                              color: earthGreen,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              widget
                                                  .motelsDetailsModel
                                                  .motelType,
                                              style: const TextStyle(
                                                color: earthGreen,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Contact Info
                                      if (widget
                                                  .motelsDetailsModel
                                                  .contactPhone !=
                                              null ||
                                          widget
                                                  .motelsDetailsModel
                                                  .contactEmail !=
                                              null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 12,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (widget
                                                      .motelsDetailsModel
                                                      .contactPhone !=
                                                  null)
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.phone,
                                                      size: 16,
                                                      color: deepTerracotta,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      widget
                                                          .motelsDetailsModel
                                                          .contactPhone!,
                                                      style: const TextStyle(
                                                        color: textLight,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              if (widget
                                                      .motelsDetailsModel
                                                      .contactEmail !=
                                                  null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.email,
                                                        size: 16,
                                                        color: deepTerracotta,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          widget
                                                              .motelsDetailsModel
                                                              .contactEmail!,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    textLight,
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                      // Description
                                      if (widget
                                              .motelsDetailsModel
                                              .description !=
                                          null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 12,
                                          ),
                                          child: Text(
                                            widget
                                                .motelsDetailsModel
                                                .description!,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: textLight,
                                              fontSize: 13,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                secondChild: const SizedBox(
                                  width: double.infinity,
                                  height: 0,
                                ),
                                crossFadeState: _isInfoExpanded
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                duration: const Duration(milliseconds: 300),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      }

                      // Adjust index for room items
                      final roomIndex = index - 1;

                      // Loading indicator at the end
                      if (roomIndex >= _filteredRooms.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
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
                        );
                      }

                      // Room cards
                      final room = _filteredRooms[roomIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        child: HotelCards.verticalHotelRooms(
                          motelsDetailsModel: widget.motelsDetailsModel,
                          room: room,
                          context: context,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: richBrown.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: earthGreen),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: const TextStyle(color: textLight, fontSize: 11)),
        ],
      ),
    );
  }
}
