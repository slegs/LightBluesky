import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/partials/customimage.dart';

/// Embed for external (Tenor gifs and links to other websites)
class ExternalEmbed extends StatelessWidget {
  const ExternalEmbed({
    super.key,
    required this.root,
    required this.open,
  });

  final UEmbedViewExternal root;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final external = root.data.external;
    // Handle GIFs from tenor
    var thumb = external.thumbnail;

    final uri = Uri.parse(external.uri);

    if (uri.host == 'media.tenor.com') {
      thumb = external.uri;
    }

    return InkWell(
      onTap: open
          ? () {
              Ui.openUrl(external.uri);
            }
          : null,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          children: [
            if (thumb != null)
              CustomImage(
                thumb,
                fit: BoxFit.fill,
              ),
            // TODO: Click to open ALT
            Text(
              external.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(external.description),
          ],
        ),
      ),
    );
  }
}
