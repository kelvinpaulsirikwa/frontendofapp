import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:flutter/material.dart';
import '../../services/near_me_service.dart';
import '../../models/bnbmodel.dart';
import '../bnbhome/bnbdetails.dart';
import '../../utility/navigateutility.dart';
import '../../utility/colors.dart';

class TopSearchMotel extends StatefulWidget {
  final Function(List<Map<String, dynamic>>)? onMotelsUpdated;

  const TopSearchMotel({super.key, this.onMotelsUpdated});

  @override
  State<TopSearchMotel> createState() => _TopSearchMotelState();
}

class _TopSearchMotelState extends State<TopSearchMotel> {
  List<Map<String, dynamic>> _topSearchedMotels = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadTopSearchedMotels();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resend data when tab becomes visible to ensure map updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _topSearchedMotels.isNotEmpty) {
        if (widget.onMotelsUpdated != null) {
          widget.onMotelsUpdated!(_topSearchedMotels);
        }
      }
    });
  }

  Future<void> _loadTopSearchedMotels({bool loadMore = false}) async {
    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final response = await NearMeService.getTopSearchedMotels(
        page: loadMore ? _currentPage + 1 : 1,
        limit: 10,
      );

      if (response['success'] == true) {
        final List<dynamic> newMotels = response['data'];
        final pagination = response['pagination'];

        setState(() {
          if (loadMore) {
            _topSearchedMotels.addAll(newMotels.cast<Map<String, dynamic>>());
            _currentPage++;
          } else {
            _topSearchedMotels = newMotels.cast<Map<String, dynamic>>();
            _currentPage = 1;
          }
          _hasMore = pagination['has_more'] ?? false;
        });

        // Notify parent about updated motels AFTER state update
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.onMotelsUpdated != null && mounted) {
            widget.onMotelsUpdated!(_topSearchedMotels);
          }
        });
      }
    } catch (e) {
      // Error loading top searched motels
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon
        // Content
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: deepTerracotta),
                )
              : _topSearchedMotels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 56,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No top searches yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _topSearchedMotels.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _topSearchedMotels.length) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _isLoadingMore
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: deepTerracotta,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : _hasMore
                            ? Center(
                                child: GestureDetector(
                                  onTap: () =>
                                      _loadTopSearchedMotels(loadMore: true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: earthGreen,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: earthGreen.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'Load More',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  'No more results',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      );
                    }

                    final motel = _topSearchedMotels[index];
                    final searchCount = motel['search_count'] ?? 0;

                    return GestureDetector(
                      onTap: () {
                        final simpleMotel = SimpleMotel(
                          id: motel['id'] ?? 0,
                          name: motel['name'] ?? 'Unknown Motel',
                          frontImage: motel['front_image'],
                          streetAddress:
                              motel['street_address'] ?? 'Unknown Street',
                          motelType: motel['motel_type'] ?? 'Unknown Type',
                          district: motel['district'] ?? 'Unknown District',
                          longitude: motel['longitude'] != null
                              ? double.tryParse(motel['longitude'].toString())
                              : null,
                          latitude: motel['latitude'] != null
                              ? double.tryParse(motel['latitude'].toString())
                              : null,
                        );

                        NavigationUtil.pushTo(
                          context,
                          BnBDetails(motel: simpleMotel),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Image with rank badge ---
                            Flexible(
                              flex: 3,
                              child: AspectRatio(
                                aspectRatio:
                                    0.75, // ensures square image, avoids overflow
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Showimage.networkImage(
                                          imageUrl: motel['front_image']?.toString() ?? '',
                                        ),
                                      ),
                                    ),
                                    // Rank badge
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: sunsetOrange,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // --- Content Section ---
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    motel['name'] ?? 'Unknown Motel',
                                    style: const TextStyle(
                                      color: textDark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          motel['street_address'] ??
                                              'Unknown Address',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sunsetOrange.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.search,
                                          size: 12,
                                          color: sunsetOrange,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '$searchCount searches',
                                            style: const TextStyle(
                                              color: sunsetOrange,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // --- Arrow icon safely aligned ---
                            Flexible(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
