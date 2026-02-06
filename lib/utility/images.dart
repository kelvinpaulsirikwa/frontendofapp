import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/services/bnbconnection.dart';

class Showimage {
  static String _resolve(String urlOrPath) {
    if (urlOrPath.isEmpty || urlOrPath == 'null') {
      return '';
    }

    final lower = urlOrPath.toLowerCase();
    String cleanUrl = urlOrPath;

    // If already a full URL, check if it needs cleaning
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      // Remove /api/ from URLs that already have it
      if (cleanUrl.contains('/api/storage/')) {
        cleanUrl = cleanUrl.replaceAll('/api/storage/', '/storage/');
      } else if (cleanUrl.contains('/api/storage')) {
        cleanUrl = cleanUrl.replaceAll('/api/storage', '/storage');
      }
      return cleanUrl;
    }

    // strip possible leading slashes
    final path = urlOrPath
        .replaceAll('\\', '/')
        .replaceFirst(RegExp('^/+'), '');

    // Remove /api or /api/ from baseUrl
    String base = baseUrl;
    if (base.endsWith('/api')) {
      base = base.substring(0, base.length - 4); // Remove '/api'
    } else if (base.endsWith('/api/')) {
      base = base.substring(0, base.length - 5); // Remove '/api/'
    } else if (base.contains('/api/')) {
      base = base.replaceAll('/api/', '/');
    } else if (base.contains('/api')) {
      base = base.replaceAll('/api', '');
    }

    // Ensure base doesn't end with a slash
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    final resolved = '$base/storage/$path';
    return resolved;
  }

  static void showFullScreenImage(
    BuildContext context,
    String imageUrl,
    String imagecontent,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: SingleMGAppBar(
            imagecontent,
            context: context,
            actions: [
              
            ],
          ),
          body: Center(
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              child: networkImage(imageUrl: imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  static Widget showSmallImage(
    String imageUrl,
    BuildContext context,
    String imagecontent,
  ) {
    return GestureDetector(
      onTap: () {
        showFullScreenImage(context, imageUrl, imagecontent);
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            _resolve(imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget networkImage({required String imageUrl}) {
    // Handle null or empty imageUrl
    if (imageUrl.isEmpty || imageUrl == 'null') {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              sunsetOrange.withOpacity(0.4),
              earthGreen.withOpacity(0.4),
            ],
          ),
        ),
        child: const Center(
          child: Icon(Icons.apartment, size: 80, color: richBrown),
        ),
      );
    }

    final resolvedUrl = _resolve(imageUrl);

    if (resolvedUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              sunsetOrange.withOpacity(0.4),
              earthGreen.withOpacity(0.4),
            ],
          ),
        ),
        child: const Center(
          child: Icon(Icons.apartment, size: 80, color: richBrown),
        ),
      );
    }

    return Image.network(
      resolvedUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                sunsetOrange.withOpacity(0.4),
                earthGreen.withOpacity(0.4),
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.apartment, size: 80, color: richBrown),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: richBrown.withOpacity(0.1),
          child: const Center(
            child: CircularProgressIndicator(color: softCream),
          ),
        );
      },
    );
  }
}
