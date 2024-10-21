import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/widgets/icontext.dart';

/// Wraps embed data for easier usage
class EmbedWrapper {
  /// Root element for embed
  final bsky.EmbedView root;

  /// Embed type
  final EmbedTypes type;

  const EmbedWrapper({required this.root, required this.type});

  /// Setup embed from API EmbedView
  factory EmbedWrapper.fromApi({required bsky.EmbedView root}) {
    return EmbedWrapper(
      root: root,
      type: _getType(root),
    );
  }

  /// Build widgets from current data
  List<Widget> getChildren({bool full = false}) {
    if (type == EmbedTypes.images) {
      return _handleImages(root as bsky.UEmbedViewImages, full);
    } else if (type == EmbedTypes.external) {
      return _handleExternal(root as bsky.UEmbedViewExternal);
    }

    return [
      const IconText(
        icon: Icons.warning,
        text: 'Embed type not supported! :(',
      ),
    ];
  }

  /// Guess embed type
  static EmbedTypes _getType(bsky.EmbedView root) {
    EmbedTypes type;

    if (root is bsky.UEmbedViewImages) {
      type = EmbedTypes.images;
    } else if (root is bsky.UEmbedViewExternal) {
      type = EmbedTypes.external;
    } else {
      type = EmbedTypes.unsupported;
    }

    return type;
  }

  /// Get widgets for images
  List<Widget> _handleImages(bsky.UEmbedViewImages typedRoot, bool full) {
    List<Widget> widgets = [];

    for (var img in typedRoot.data.images) {
      final widget = Padding(
        padding: const EdgeInsets.all(5.0),
        child: Image.network(
          full ? img.fullsize : img.thumbnail,
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
    }

    return widgets;
  }

  /// Get widgets for external (GIFs, Open Graph stuff...)
  List<Widget> _handleExternal(bsky.UEmbedViewExternal typedRoot) {
    final external = typedRoot.data.external;

    // Handle GIFs from tenor
    var thumb = external.thumbnail;

    final uri = Uri.parse(external.uri);

    if (uri.host == 'media.tenor.com') {
      thumb = external.uri;
    }

    return [
      InkWell(
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              if (thumb != null)
                Image.network(
                  thumb,
                  fit: BoxFit.fill,
                ),
              Text(
                external.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(external.description),
            ],
          ),
        ),
        onTap: () {
          Ui.openUrl(external.uri);
        },
      ),
    ];
  }
}
