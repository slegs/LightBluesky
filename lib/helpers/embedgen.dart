import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/models/embedwrapper.dart';
import 'package:lightbluesky/widgets/icontext.dart';

/// Generates widgets from embed data
class EmbedGenerator {
  /// Handles widgets usage for embed
  static EmbedWrapper fromApi(bsky.EmbedView embed) {
    List<Widget> widgets;
    EmbedTypes type;

    if (embed is bsky.UEmbedViewImages) {
      widgets = _handleImages(embed);
      type = EmbedTypes.images;
    } else {
      widgets = [
        const IconText(
          icon: Icons.warning,
          text: 'Embed type not supported! :(',
        ),
      ];
      type = EmbedTypes.unsupported;
    }

    return EmbedWrapper(
      widgets: widgets,
      type: type,
    );
  }

  static List<Widget> _handleImages(bsky.UEmbedViewImages embed) {
    List<Widget> widgets = [];

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
    }

    return widgets;
  }
}
