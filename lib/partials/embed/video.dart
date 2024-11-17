import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/partials/dialogs/embed.dart';
import 'package:lightbluesky/widgets/customplayer.dart';

/// Embed for a video
class VideoEmbed extends StatelessWidget {
  const VideoEmbed({
    super.key,
    required this.root,
    required this.open,
  });

  final UEmbedViewVideo root;
  final bool open;

  @override
  Widget build(BuildContext context) {
    double? ratio;

    if (root.data.aspectRatio != null) {
      ratio = root.data.aspectRatio!.width / root.data.aspectRatio!.height;
    }

    return InkWell(
      onLongPress: open
          ? () {
              showDialog(
                context: context,
                builder: (_) => EmbedDialog(
                  item: root,
                ),
              );
            }
          : null,
      child: CustomPlayer(
        playlist: root.data.playlist,
        thumb: root.data.thumbnail,
        ratio: ratio,
      ),
    );
  }
}
