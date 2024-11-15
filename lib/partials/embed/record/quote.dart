import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/post.dart';
import 'package:lightbluesky/partials/actor.dart';
import 'package:lightbluesky/partials/icontext.dart';
import 'package:lightbluesky/widgets/embed.dart';

/// Embed for generator feed records
/// Supports text only and nested embeds attached
class QuoteRecordEmbed extends StatelessWidget {
  const QuoteRecordEmbed({
    super.key,
    required this.record,
    this.media,
    required this.open,
  });

  final bsky.UEmbedViewRecordViewRecord? record;
  final bsky.EmbedView? media;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final card = Card.outlined(
      child: record != null
          ? InkWell(
              onTap: open
                  ? () {
                      Ui.nav(
                        context,
                        PostPage(uri: record!.data.uri),
                      );
                    }
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Actor(
                    actor: record!.data.author,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: Text(
                      record!.data.value.text,
                    ),
                  ),
                  if (record!.data.embeds != null &&
                      record!.data.embeds!.isNotEmpty)
                    EmbedRoot(
                      item: record!.data.embeds![0],
                      labels: record!.data.labels,
                    )
                ],
              ),
            )
          : const IconText(
              icon: Icons.warning,
              text: "Not found!",
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
