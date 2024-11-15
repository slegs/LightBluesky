import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/feed.dart';

/// Embed for generator feed records
class GeneratorRecordEmbed extends StatelessWidget {
  const GeneratorRecordEmbed({
    super.key,
    required this.root,
    required this.open,
  });

  final bsky.UEmbedViewRecordViewGeneratorView root;
  final bool open;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
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
          ],
        ),
      ),
    );
  }
}
