import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';

/// Provides some standard functions to Image
/// Adds loading indicator and error
class GenericImage extends StatelessWidget {
  const GenericImage({
    super.key,
    required this.src,
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
        return const Center(
          child: Icon(Icons.warning),
        );
      },
    );

    return widget;
  }
}
