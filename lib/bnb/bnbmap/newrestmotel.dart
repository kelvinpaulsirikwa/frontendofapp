import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:flutter/material.dart';
import '../../services/near_me_service.dart';
import '../../models/bnbmodel.dart';
import '../bnbhome/bnbdetails.dart';
import '../../utility/navigateutility.dart';
import '../../utility/colors.dart';

class NewRestMotel extends StatefulWidget {
  final Function(List<Map<String, dynamic>>)? onMotelsUpdated;

  const NewRestMotel({super.key, this.onMotelsUpdated});

  @override
  State<NewRestMotel> createState() => _NewRestMotelState();
}

class _NewRestMotelState extends State<NewRestMotel> {
  List<Map<String, dynamic>> _newestMotels = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadNewestMotels();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resend data when tab becomes visible to ensure map updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _newestMotels.isNotEmpty) {
        if (widget.onMotelsUpdated != null) {
          widget.onMotelsUpdated!(_newestMotels);
        }
      }
    });
  }

  Future<void> _loadNewestMotels({bool loadMore = false}) async {
    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final response = await NearMeService.getNewestMotels(
        page: loadMore ? _currentPage + 1 : 1,
        limit: 10,
      );

      if (response['success'] == true) {
        final List<dynamic> newMotels = response['data'];
        final pagination = response['pagination'];

        setState(() {
          if (loadMore) {
            _newestMotels.addAll(newMotels.cast<Map<String, dynamic>>());
            _currentPage++;
          } else {
            _newestMotels = newMotels.cast<Map<String, dynamic>>();
            _currentPage = 1;
          }
          _hasMore = pagination['has_more'] ?? false;
        });

        // Notify parent about updated motels AFTER state update
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.onMotelsUpdated != null && mounted) {
            widget.onMotelsUpdated!(_newestMotels);
          }
        });
      }
    } catch (e) {
      // Error loading newest motels
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
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: deepTerracotta),
                )
              : _newestMotels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'No new listings yet',
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
                  itemCount: _newestMotels.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _newestMotels.length) {
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
                                      _loadNewestMotels(loadMore: true),
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

                    final motel = _newestMotels[index];
                    final createdAt = motel['created_at'] != null
                        ? DateTime.tryParse(motel['created_at'])
                        : null;
                    final daysAgo = createdAt != null
                        ? DateTime.now().difference(createdAt).inDays
                        : 0;

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
                            // Image with NEW badge
                            Flexible(
                              flex: 3,
                              child: AspectRatio(
                                aspectRatio: 1,
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
                                    if (daysAgo < 7)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: deepTerracotta,
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
                                          child: const Text(
                                            'NEW',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Content
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
                                ],
                              ),
                            ),

                            // Arrow icon safely wrapped
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
