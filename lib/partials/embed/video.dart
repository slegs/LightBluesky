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
      ),
    );
  }
}
