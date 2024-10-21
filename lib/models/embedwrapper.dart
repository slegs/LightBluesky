import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/widgets/icontext.dart';
import 'package:lightbluesky/widgets/genericimage.dart';
import 'package:lightbluesky/widgets/customplayer.dart';

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
    } else if (type == EmbedTypes.videos) {
      return _handleVideos(root as bsky.UEmbedViewUnknown);
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
    } else if (root is bsky.UEmbedViewUnknown &&
        root.data.containsKey("playlist")) {
      type = EmbedTypes.videos;
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
        child: GenericImage(
          src: full ? img.fullsize : img.thumbnail,
          aspectRatio: img.aspectRatio,
        ),
      );

      widgets.add(widget);
    }

    return widgets;
  }

  // Get widgets for videos
  List<Widget> _handleVideos(bsky.UEmbedViewUnknown typedRoot) {
    if (!typedRoot.data.keys
        .toSet()
        .containsAll(["playlist", "thumbnail", "aspectRatio"])) {
      return [const Text("Unable to process video!")];
    }

    return [
      CustomPlayer(
        cid: typedRoot.data['cid'],
        playlist: typedRoot.data['playlist'],
        thumbnail: typedRoot.data['thumbnail'],
        aspectRatio: typedRoot.data['aspectRatio'],
      ),
    ];
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
                GenericImage(
                  src: thumb,
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
