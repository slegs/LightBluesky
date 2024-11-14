import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/post.dart';
import 'package:lightbluesky/partials/actor.dart';
import 'package:lightbluesky/partials/icontext.dart';
import 'package:lightbluesky/partials/customimage.dart';
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
  List<Widget> getChildren({bool full = false, BuildContext? context}) {
    if (type == EmbedTypes.images) {
      return _handleImages(root as bsky.UEmbedViewImages, full);
    } else if (type == EmbedTypes.videos) {
      return _handleVideos(root as bsky.UEmbedViewVideo);
    } else if (type == EmbedTypes.external) {
      return _handleExternal(root as bsky.UEmbedViewExternal);
    } else if (type == EmbedTypes.quote) {
      return _handleQuote(root as bsky.UEmbedViewRecord, context);
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
    } else if (root is bsky.UEmbedViewVideo) {
      type = EmbedTypes.videos;
    } else if (root is bsky.UEmbedViewRecord) {
      type = EmbedTypes.quote;
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
        child: CustomImage(
          full ? img.fullsize : img.thumbnail,
        ),
      );

      widgets.add(widget);
    }

    return widgets;
  }

  // Get widgets for videos
  List<Widget> _handleVideos(bsky.UEmbedViewVideo typedRoot) {
    return [
      CustomPlayer(
        playlist: typedRoot.data.playlist,
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
                CustomImage(
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

  List<Widget> _handleQuote(
    bsky.UEmbedViewRecord typedRoot,
    BuildContext? context,
  ) {
    if (context == null) {
      return const [
        Text("BuildContext not set!"),
      ];
    }

    if (typedRoot.data.record is bsky.UEmbedViewRecordViewRecord) {
      // Post quote
      final record =
          (typedRoot.data.record as bsky.UEmbedViewRecordViewRecord).data;

      return [
        Card.outlined(
          child: InkWell(
            onTap: () {
              Ui.nav(
                context,
                PostPage(uri: record.uri),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Actor(
                  actor: record.author,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                  ),
                  child: Text(
                    record.value.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    } else if (typedRoot.data.record
        is bsky.UEmbedViewRecordViewGeneratorView) {
      // Feed generator quote
      final record =
          (typedRoot.data.record as bsky.UEmbedViewRecordViewGeneratorView)
              .data;
      return [
        Card.outlined(
          child: InkWell(
            onTap: () {
              Ui.snackbar(context, "TODO: Add feed support");
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: record.avatar != null
                        ? Image.network(record.avatar!).image
                        : null,
                  ),
                  title: Text(record.displayName),
                  subtitle: record.description != null
                      ? Text(record.description!)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      const Text("Quote type not supported!"),
    ];
  }
}
