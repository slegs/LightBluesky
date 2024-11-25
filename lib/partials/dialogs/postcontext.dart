import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/helpers/urlbuilder.dart';

/// Menu with additional post actions
///
/// Implemented:
/// - Share
///
/// TODO: Report
class PostContextDialog extends StatelessWidget {
  const PostContextDialog({
    super.key,
    required this.post,
  });

  /// Post item
  final Post post;

  void _closeWhenFunc({
    required void Function() func,
    required BuildContext context,
  }) {
    func();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share'),
          onTap: () => _closeWhenFunc(
            func: () {
              final url = UrlBuilder.full(
                UrlBuilder.post(
                  post.author.handle,
                  post.uri.rkey,
                ),
              );
              Ui.shareUrl(url, context);
            },
            context: context,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.warning),
          title: const Text('Report'),
          onTap: () => _closeWhenFunc(
            func: () {
              Ui.snackbar(context, "TODO: Add report");
            },
            context: context,
          ),
        ),
      ],
    );
  }
}
