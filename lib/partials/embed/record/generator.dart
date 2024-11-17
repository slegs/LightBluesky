import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightbluesky/helpers/customimage.dart';
import 'package:lightbluesky/helpers/urlbuilder.dart';
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
                context.go(
                  UrlBuilder.feedGenerator(
                    root.data.createdBy.handle,
                    root.data.uri.rkey,
                  ),
                );
              }
            : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: root.data.avatar != null
                ? CustomImage.provider(
                    url: root.data.avatar!,
                    caching: false,
                  )
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
