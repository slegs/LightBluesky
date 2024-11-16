import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/partials/icontext.dart';
import 'package:photo_view/photo_view.dart';

/// Helper class to handle images
class CustomImage {
  /// Adds standard image found in [url].
  ///
  /// Use [caching] to store the image for future usage.
  static Widget normal({
    required String url,
    required bool caching,
    double? ratio,
    BoxFit? fit,
    bool zoomable = false,
  }) {
    final p = provider(
      url: url,
      caching: caching,
    );

    if (zoomable) {
      return PhotoView(
        imageProvider: p,
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        minScale: PhotoViewComputedScale.contained,
      );
    }

    final img = Image(
      image: p,
      fit: fit,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: IconText(
            icon: Icons.warning,
            text: error.toString(),
          ),
        );
      },
    );

    if (ratio != null) {
      return AspectRatio(
        aspectRatio: ratio,
        child: img,
      );
    }

    return img;
  }

  static ImageProvider provider({
    required String url,
    required bool caching,
  }) {
    return caching
        ? CachedNetworkImageProvider(url, cacheManager: cache)
        : NetworkImage(url);
  }
}
