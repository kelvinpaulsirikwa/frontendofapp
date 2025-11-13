import 'package:bnbfrontendflutter/utility/alert.dart';
import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/near_me_service.dart';
import '../../services/location_service.dart';
import '../../utility/distance_calculator.dart';
import '../../models/bnbmodel.dart';
import '../bnbhome/bnbdetails.dart';
import '../../utility/navigateutility.dart';
import '../../utility/colors.dart';

class NearMeMotel extends StatefulWidget {
  final Function(List<Map<String, dynamic>>)? onMotelsUpdated;
  final Function(double radius, Position? position)? onRadiusChanged;

  const NearMeMotel({super.key, this.onMotelsUpdated, this.onRadiusChanged});

  @override
  State<NearMeMotel> createState() => _NearMeMotelState();
}

class _NearMeMotelState extends State<NearMeMotel> {
  List<Map<String, dynamic>> _nearMeMotels = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  Position? _currentPosition;
  double _radius = 10.0; // Default 10km radius

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndLoadMotels();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resend data when tab becomes visible to ensure map updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _nearMeMotels.isNotEmpty) {
        // Resend motels to ensure map is updated
        if (widget.onMotelsUpdated != null) {
          widget.onMotelsUpdated!(_nearMeMotels);
        }
        // Resend radius if available
        if (widget.onRadiusChanged != null && _currentPosition != null) {
          widget.onRadiusChanged!(_radius, _currentPosition);
        }
      }
    });
  }

  Future<void> _getCurrentLocationAndLoadMotels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request location permission
      bool hasPermission = await LocationService.requestLocationPermission();
      if (!hasPermission) {
        _showLocationPermissionDialog();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current location
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
        // Notify parent about radius and position
        if (widget.onRadiusChanged != null) {
          widget.onRadiusChanged!(_radius, position);
        }
        await _loadNearMeMotels();
      } else {
        AlertReturn.showerror(context, 'Error getting location');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      AlertReturn.showerror(context, 'Error getting location');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearMeMotels({bool loadMore = false}) async {
    if (_currentPosition == null) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else if (!_isLoading) {
        _isLoading = true;
      }
    });

    try {
      final response = await NearMeService.getNearMeMotels(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radius: _radius,
        page: loadMore ? _currentPage + 1 : 1,
        limit: 10,
      );

      if (response['success'] == true) {
        final List<dynamic> newMotels = response['data'];
        final pagination = response['pagination'];

        setState(() {
          if (loadMore) {
            _nearMeMotels.addAll(newMotels.cast<Map<String, dynamic>>());
            _currentPage++;
          } else {
            _nearMeMotels = newMotels.cast<Map<String, dynamic>>();
            _currentPage = 1;
          }
          _hasMore = pagination['has_more'] ?? false;
        });

        // Notify parent about updated motels AFTER state update
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.onMotelsUpdated != null && mounted) {
            print(
              '📍 NearMeMotel: Notifying parent with ${_nearMeMotels.length} motels',
            );
            widget.onMotelsUpdated!(_nearMeMotels);
          }
        });
      }
    } catch (e) {
      print('Error loading near me motels: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: deepTerracotta, size: 28),
            SizedBox(width: 12),
            Text(
              'Location Required',
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Please enable location permission to discover amazing stays near you.',
          style: TextStyle(color: textDark, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _getCurrentLocationAndLoadMotels();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: earthGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onRadiusChanged(double newRadius) {
    setState(() {
      _radius = newRadius;
    });
    // Notify parent about radius change
    if (widget.onRadiusChanged != null) {
      widget.onRadiusChanged!(_radius, _currentPosition);
    }
    _loadNearMeMotels();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Radius selector
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.adjust, size: 16, color: earthGreen),
                      SizedBox(width: 6),
                      Text(
                        'Search Radius',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: earthGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_radius.round()} km',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: earthGreen,
                      ),
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: earthGreen,
                  inactiveTrackColor: earthGreen.withOpacity(0.2),
                  thumbColor: earthGreen,
                  overlayColor: earthGreen.withOpacity(0.2),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: _radius,
                  min: 1.0,
                  max: 400.0,
                  divisions: 49,
                  onChanged: _onRadiusChanged,
                ),
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: earthGreen,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Finding stays near you...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : _nearMeMotels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_searching,
                        size: 56,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No stays found nearby',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try increasing the search radius',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _nearMeMotels.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _nearMeMotels.length) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _isLoadingMore
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: earthGreen,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : _hasMore
                            ? Center(
                                child: GestureDetector(
                                  onTap: () =>
                                      _loadNearMeMotels(loadMore: true),
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

                    final motel = _nearMeMotels[index];
                    final distance = motel['distance'] ?? 0.0;

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
                            // Image with distance badge
                            Flexible(
                              flex: 3,
                              child: AspectRatio(
                                aspectRatio: 0.75, // keeps the image square
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Showimage.networkImage(
                                          imageUrl: motel['front_image'],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      left: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: warmSand.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(
                                            6,
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
                                          DistanceCalculator.formatDistance(
                                            distance,
                                          ),
                                          style: const TextStyle(
                                            color: richBrown,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Content area
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
                                      color: earthGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      motel['motel_type'] ?? 'Unknown',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Arrow icon aligned safely
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
