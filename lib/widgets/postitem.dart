import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/models/embedwrapper.dart';
import 'package:lightbluesky/pages/post.dart';
import 'package:lightbluesky/widgets/embed.dart';
import 'package:lightbluesky/widgets/icontext.dart';

/// Card containing a FeedView (post)
class PostItem extends StatelessWidget {
  const PostItem({super.key, required this.item, this.reason});

  final bsky.Post item;
  final bsky.Reason? reason;

  Widget _handleReason() {
    String text;
    IconData icon;

    if (reason!.data is bsky.ReasonRepost) {
      final repost = reason!.data as bsky.ReasonRepost;

      text = 'Reposted by ${repost.by.displayName ?? "@${repost.by.handle}"}';
      icon = Icons.autorenew;
    } else {
      text = "Unsuported reason!";
      icon = Icons.warning;
    }

    return IconText(
      icon: icon,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Ui.nav(
            context,
            PostPage(uri: item.uri),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reason != null) _handleReason(),
            // START Author's data
            ListTile(
              leading: CircleAvatar(
                backgroundImage: item.author.avatar != null
                    ? NetworkImage(item.author.avatar!)
                    : null,
              ),
              title: Text(item.author.displayName != null
                  ? item.author.displayName!
                  : '@${item.author.handle}'),
              subtitle: item.author.displayName != null
                  ? Text('@${item.author.handle}')
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
              ),
              child: Text(
                item.record.text,
              ),
            ),
            // END Author's data
            // Add embed if available
            if (item.embed != null)
              Embed(
                wrap: EmbedWrapper.fromApi(
                  root: item.embed!,
                ),
              ),
            // START interaction buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.reply_outlined),
                  label: Text(item.replyCount.toString()),
                  onPressed: () {
                    Ui.nav(
                      context,
                      PostPage(uri: item.uri, autoReply: true),
                    );
                  },
                ),
                TextButton.icon(
                  icon: item.isReposted
                      ? const Icon(Icons.autorenew)
                      : const Icon(Icons.autorenew_outlined),
                  label: Text(item.repostCount.toString()),
                  onPressed: () {
                    Ui.snackbar(context, "TODO: Add repost");
                  },
                ),
                TextButton.icon(
                  icon: item.isLiked
                      ? const Icon(Icons.favorite)
                      : const Icon(Icons.favorite_outline),
                  label: Text(item.likeCount.toString()),
                  onPressed: () {
                    Ui.snackbar(context, "TODO: Add like");
                  },
                ),
              ],
            ),
            // END interaction buttons
          ],
        ),
      ),
    );
  }
}
