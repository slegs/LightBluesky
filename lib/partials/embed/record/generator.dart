import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/feed.dart';
import 'package:lightbluesky/widgets/embed.dart';

/// Embed for generator feed records
class GeneratorRecordEmbed extends StatelessWidget {
  const GeneratorRecordEmbed({
    super.key,
    required this.root,
    this.media,
    required this.open,
  });

  final bsky.UEmbedViewRecordViewGeneratorView root;
  final bsky.EmbedView? media;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final card = Card.outlined(
      child: InkWell(
        onTap: open
            ? () {
                Ui.nav(
                  context,
                  FeedPage(
                    title: root.data.displayName,
                    uri: root.data.uri,
                  ),
                );
              }
            : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: root.data.avatar != null
                ? Image.network(root.data.avatar!).image
                : null,
          ),
          title: Text(root.data.displayName),
          subtitle: root.data.description != null
              ? Text(root.data.description!)
              : null,
        ),
      ),
    );
    return media == null
        ? card
        : Column(
            children: [
              EmbedRoot(
                item: media!,
              ),
              card,
            ],
          );
  }
}
