import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/helpers/urlbuilder.dart';

class PostContextDialog extends StatelessWidget {
  const PostContextDialog({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share'),
          onTap: () {
            final url = UrlBuilder.post(post);
            Ui.shareUrl(url, context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.warning),
          title: const Text('Report'),
          onTap: () {
            Ui.snackbar(context, "TODO: Add report");
          },
        )
      ],
    );
  }
}
