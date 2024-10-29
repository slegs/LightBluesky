import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/partials/icontext.dart';

/// Provides some standard functions to Image
/// Adds loading indicator and error
class CustomImage extends StatelessWidget {
  const CustomImage(
    this.src, {
    super.key,
    this.aspectRatio,
    this.fit,
  });

  final String src;
  final bsky.ImageAspectRatio? aspectRatio;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final widget = Image.network(
      src,
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

    return widget;
  }
}
