import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/partials/dialogs/embed.dart';
import 'package:lightbluesky/widgets/customplayer.dart';

class VideoEmbed extends StatelessWidget {
  const VideoEmbed({
    super.key,
    required this.root,
  });

  final UEmbedViewVideo root;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (_) => EmbedDialog(
            item: root,
          ),
        );
      },
      child: CustomPlayer(
        playlist: root.data.playlist,
      ),
    );
  }
}
