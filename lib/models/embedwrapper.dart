import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/widgets/icontext.dart';

/// Wraps embed data for easier usage
class EmbedWrapper {
  final List<Widget> widgets;
  final List<String>? downloadUrls;
  final EmbedTypes type;

  const EmbedWrapper({
    required this.widgets,
    required this.type,
    this.downloadUrls,
  });

  /// Handles widgets usage for embed from API data
  factory EmbedWrapper.fromApi(bsky.EmbedView embed) {
    if (embed is bsky.UEmbedViewImages) {
      return _handleImages(embed);
    }

    return _handleUnsupported();
  }

  static EmbedWrapper _handleImages(bsky.UEmbedViewImages embed) {
    List<Widget> widgets = [];
    List<String> downloadUrls = [];

    for (var img in embed.data.images) {
      final widget = Padding(
        padding: const EdgeInsets.all(5.0),
        child: Image.network(
          img.thumbnail,
          // Show progress while downloading image
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
        ),
      );

      widgets.add(widget);
      downloadUrls.add(img.fullsize);
    }

    return EmbedWrapper(
      widgets: widgets,
      downloadUrls: downloadUrls,
      type: EmbedTypes.images,
    );
  }

  static EmbedWrapper _handleUnsupported() {
    return const EmbedWrapper(
      widgets: [
        IconText(
          icon: Icons.warning,
          text: 'Embed type not supported! :(',
        ),
      ],
      type: EmbedTypes.unsupported,
    );
  }
}
