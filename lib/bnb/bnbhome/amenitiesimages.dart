import 'package:bnbfrontendflutter/models/bnb_motels_details_model.dart';
import 'package:bnbfrontendflutter/services/amenititesimage.dart';
import 'package:bnbfrontendflutter/utility/alert.dart'; 
import 'package:bnbfrontendflutter/utility/errorcontentretry.dart';
import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:flutter/material.dart';

class AmenitiesImages extends StatefulWidget {
  final BnbAmenityModel amenity;
  const AmenitiesImages({super.key, required this.amenity});

  @override
  State<AmenitiesImages> createState() => _AmenitiesImagesState();
}

class _AmenitiesImagesState extends State<AmenitiesImages> {
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<AmenitiesAllImages> _images = [];
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  Future<void> _loadMoreImages() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final response = await AmenitiesImagesService.getamenitiesimage(
        widget.amenity.id,
        page: _currentPage,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> imagesData = response['data'];
        final List<AmenitiesAllImages> newImages = imagesData
            .map((item) => AmenitiesAllImages.fromJson(item))
            .toList();

        setState(() {
          _images.addAll(newImages);
          _hasMore = newImages.length >= 10;
        });
      }
    } catch (e) {
      AlertReturn.showToast('Error loading more images: $e');
      setState(() {
        _currentPage--; // Revert page increment on error
      });
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadImages({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _images.clear();
        _errorMessage = null;
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AmenitiesImagesService.getamenitiesimage(
        widget.amenity.id,
        page: _currentPage,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> imagesData = response['data'];
        final List<AmenitiesAllImages> newImages = imagesData
            .map((item) => AmenitiesAllImages.fromJson(item))
            .toList();

        setState(() {
          if (refresh) {
            _images = newImages;
          } else {
            _images.addAll(newImages);
          }
          _hasMore = newImages.length >= 10;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load images';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading images: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMoreImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show error if there's an error message
    if (_errorMessage != null && !_isLoading) {
      return ErrorContent(
        message: _errorMessage!,
        color: Colors.red,
        onRetry: () {
          _loadImages(refresh: true);
        },
      );
    }

    // Show loading indicator
    if (_isLoading && _images.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show empty state
    if (_images.isEmpty) {
      return ErrorContent(
        message: 'No images found',
        color: Colors.blue,
        onRetry: () {
          _loadImages(refresh: true);
        },
      );
    }

    // Show images list ONLY
    return RefreshIndicator(
      onRefresh: () => _loadImages(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _images.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final image = _images[index];
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Showimage.networkImage(
                imageUrl: image.filepath.toString(),
              ),
            ),
          );
        },
      ),
    );
  }
}
