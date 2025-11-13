import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/services/bnbconnection.dart';

class Showimage {
  static String _resolve(String urlOrPath) {
    if (urlOrPath.isEmpty) return urlOrPath;
    final lower = urlOrPath.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return urlOrPath;
    }
    // strip possible leading slashes
    final path = urlOrPath
        .replaceAll('\\', '/')
        .replaceFirst(RegExp('^/+'), '');
    final base = baseUrl.replaceFirst(RegExp('/api/?'), '');
    return '$base/storage/$path';
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
              IconContainer(
                icon: Icons.share,
                backgroundColor: softCream,
                iconColor: textDark,
                onTap: () {},
              ),
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
    return Image.network(
      _resolve(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
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
      ),
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
