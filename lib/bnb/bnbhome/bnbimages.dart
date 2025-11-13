import 'package:bnbfrontendflutter/services/motel_detail_service.dart';
import 'package:bnbfrontendflutter/utility/alert.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/errorcontentretry.dart';
import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:flutter/material.dart';

class BnBHotelImages extends StatefulWidget {
  final int motelid;
  const BnBHotelImages({super.key, required this.motelid});

  @override
  State<BnBHotelImages> createState() => _BnBHotelImagesState();
}

class _BnBHotelImagesState extends State<BnBHotelImages> {
  List<MotelImageModel> _images = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMotelData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMotelData() async {
    try {
      _loadImages();
    } catch (e) {
      debugPrint('Error loading motel data: $e');
      setState(() {
        _errorMessage = 'Error loading motel data: $e';
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoadingMore) {
        _loadMoreImages();
      }
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
      final response = await MotelDetailService.getpaginghotelimage(
        widget.motelid,
        page: _currentPage,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> imagesData = response['data'];
        final List<MotelImageModel> newImages = imagesData
            .map((item) => MotelImageModel.fromJson(item))
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

  Future<void> _loadMoreImages() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final response = await MotelDetailService.getpaginghotelimage(
        widget.motelid,
        page: _currentPage,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> imagesData = response['data'];
        final List<MotelImageModel> newImages = imagesData
            .map((item) => MotelImageModel.fromJson(item))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SingleMGAppBar("All Images", context: context),

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
                imageUrl: image.fullImageUrl.toString(),
              ),
            ),
          );
        },
      ),
    );
  }
}
