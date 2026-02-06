import 'package:bnbfrontendflutter/layouts/loading.dart';
import 'package:bnbfrontendflutter/services/motel_detail_service.dart';
import 'package:bnbfrontendflutter/utility/alert.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/errorcontentretry.dart';
import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:flutter/material.dart';

class BnBHotelImages extends StatefulWidget {
  final int motelid;
  final List<MotelImageModel>? initialImages;

  const BnBHotelImages({
    super.key,
    required this.motelid,
    this.initialImages,
  });

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
      // Error loading motel data
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

    // Use passed-in images from bnbdetails to avoid duplicate page 1 fetch
    if (widget.initialImages != null &&
        widget.initialImages!.isNotEmpty &&
        _images.isEmpty &&
        !refresh) {
      setState(() {
        _images = List.from(widget.initialImages!);
        _currentPage = 1;
        _hasMore = _images.length >= 10;
        _isLoading = false;
      });
      return;
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
      appBar: SingleMGAppBar(
  'Showing ${_images.length} Images',
  context: context,
),

      backgroundColor: warmSand,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorContent(
            message: _errorMessage!,
            color: deepTerracotta,
            onRetry: () => _loadImages(refresh: true),
          ),
        ),
      );
    }

    if (_isLoading && _images.isEmpty) {
      return  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Loading.infiniteLoading(context),
            const SizedBox(height: 16),
            const Text(
              'Loading images...',
              style: TextStyle(color: textLight, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_images.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorContent(
            message: 'No images found',
            color: deepTerracotta,
            onRetry: () => _loadImages(refresh: true),
          ),
        ),
      );
    }

    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

    return RefreshIndicator(
      onRefresh: () => _loadImages(refresh: true),
      color: deepTerracotta,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final image = _images[index];
                  return _buildImageCard(image, index + 1);
                },
                childCount: _images.length,
              ),
            ),
          ),
          if (_isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Loading.infiniteLoading(context)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageCard(MotelImageModel image, int index) {
    return GestureDetector(
      onTap: () {
        Showimage.showFullScreenImage(
          context,
          image.fullImageUrl.toString(),
          "Image View",
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: richBrown.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Showimage.networkImage(
                imageUrl: image.fullImageUrl.toString(),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
