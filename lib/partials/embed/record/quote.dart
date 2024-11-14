import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/post.dart';
import 'package:lightbluesky/partials/actor.dart';
import 'package:lightbluesky/widgets/embed.dart';

/// Embed for generator feed records
/// Supports text only and nested embeds attached
class QuoteRecordEmbed extends StatelessWidget {
  const QuoteRecordEmbed({
    super.key,
    required this.record,
  });

  final bsky.UEmbedViewRecordViewRecord record;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: InkWell(
        onTap: () {
          Ui.nav(
            context,
            PostPage(uri: record.data.uri),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Actor(
              actor: record.data.author,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
              ),
              child: Text(
                record.data.value.text,
              ),
            ),
            if (record.data.embeds != null)
              EmbedRoot(
                item: record.data.embeds![0],
                labels: record.data.labels,
              )
          ],
        ),
      ),
    );
  }
}
