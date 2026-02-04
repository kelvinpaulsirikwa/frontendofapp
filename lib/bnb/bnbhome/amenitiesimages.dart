import 'package:bnbfrontendflutter/layouts/loading.dart';
import 'package:bnbfrontendflutter/models/bnb_motels_details_model.dart';
import 'package:bnbfrontendflutter/services/amenititesimage.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
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

      if (response['success'] == true) {
        final rawData = response['data'];
        final List<dynamic> imagesData =
            rawData is List ? rawData : (rawData != null ? [rawData] : []);
        final List<AmenitiesAllImages> newImages = imagesData
            .map((item) => AmenitiesAllImages.fromJson(item))
            .toList();

        setState(() {
          _images.addAll(newImages);
          _hasMore = newImages.length >= 10;
        });
      }
    } catch (e) {
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

      if (response['success'] == true) {
        final rawData = response['data'];
        final List<dynamic> imagesData =
            rawData is List ? rawData : (rawData != null ? [rawData] : []);
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
          _errorMessage =
              _parseErrorMessage(response, 'Failed to load images');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = _parseErrorMessage(
          {'message': e.toString()},
          'Failed to load images',
        );
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
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !_isLoadingMore) {
        _loadMoreImages();
      }
    }
  }

  String _imageUrl(AmenitiesAllImages image) {
    return (image.description ?? image.filepath).toString();
  }

  String _parseErrorMessage(dynamic response, String fallback) {
    final msg = response['message']?.toString() ?? '';
    if (msg.contains('Connection closed') ||
        msg.contains('Connection refused') ||
        msg.contains('SocketException') ||
        msg.contains('Network error')) {
      return 'Connection failed. Check your network and try again.';
    }
    if (msg.contains('Invalid') ||
        msg.contains('invalid') ||
        msg.contains('bnb_amenities_id') ||
        msg.contains('422')) {
      return 'This amenity has no images or is no longer available.';
    }
    return msg.isNotEmpty ? msg : fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SingleMGAppBar(
        "Showing ${widget.amenity.name} Images",
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

    if ((_isLoading || _isLoadingMore) && _images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Loading.infiniteLoading(context),
            const SizedBox(height: 16),
            Text(
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

  Widget _buildImageCard(AmenitiesAllImages image, int index) {
    final url = _imageUrl(image);
    return GestureDetector(
      onTap: () {
        Showimage.showFullScreenImage(
          context,
          url,
          '${widget.amenity.name} #$index',
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
              Showimage.networkImage(imageUrl: url),
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
