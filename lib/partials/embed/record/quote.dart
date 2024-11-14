import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/post.dart';
import 'package:lightbluesky/partials/actor.dart';

class QuoteRecordEmbed extends StatelessWidget {
  const QuoteRecordEmbed({
    super.key,
    required this.record,
    this.media,
  });

  final bsky.UEmbedViewRecordViewRecord record;
  final bsky.EmbedViewMedia? media;

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
          ],
        ),
      ),
    );
  }
}
