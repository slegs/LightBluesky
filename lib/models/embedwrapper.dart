import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/widgets/icontext.dart';

/// Wraps embed data for easier usage
class EmbedWrapper {
  final bsky.EmbedView root;
  final EmbedTypes type;

  const EmbedWrapper({required this.root, required this.type});

  factory EmbedWrapper.fromApi({required bsky.EmbedView root}) {
    return EmbedWrapper(
      root: root,
      type: _getType(root),
    );
  }

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

  List<Widget> _handleExternal(bsky.UEmbedViewExternal typedRoot) {
    final external = typedRoot.data.external;
    return [
      InkWell(
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              if (external.thumbnail != null)
                Image.network(
                  external.thumbnail!,
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
