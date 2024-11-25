import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightbluesky/common.dart';
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
    final uri = post.uri.toString();
    final hasBookmark = storage.bookmark.has(uri);

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
          leading: hasBookmark
              ? const Icon(Icons.bookmark_remove)
              : const Icon(Icons.bookmark_add),
          title: Text(hasBookmark ? 'Remove bookmark' : 'Add bookmark'),
          onTap: () => _closeWhenFunc(
            func: () {
              if (hasBookmark) {
                storage.bookmark.remove(
                  uri: uri,
                );
              } else {
                storage.bookmark.add(uri);
              }

              Ui.snackbar(context, 'Changes applied succesfully');
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
