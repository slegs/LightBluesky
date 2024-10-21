import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/embedgen.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/widgets/embed.dart';

/// Card containing a FeedView (post)
class FeedItem extends StatelessWidget {
  const FeedItem({super.key, required this.item});

  final bsky.FeedView item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Ui.snackbar(context, "TODO: Implement full post");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // START Author's data
            ListTile(
              leading: CircleAvatar(
                backgroundImage: item.post.author.avatar != null
                    ? NetworkImage(item.post.author.avatar!)
                    : null,
              ),
              title: Text(item.post.author.displayName != null
                  ? item.post.author.displayName!
                  : '@${item.post.author.handle}'),
              subtitle: item.post.author.displayName != null
                  ? Text('@${item.post.author.handle}')
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
              ),
              child: Text(
                item.post.record.text,
              ),
            ),
            // END Author's data
            // Add embed if available
            if (item.post.embed != null)
              Embed(
                wrap: EmbedGenerator.fromApi(item.post.embed!),
              ),
            // START interaction buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.reply),
                  label: Text(item.post.replyCount.toString()),
                  onPressed: () {
                    Ui.snackbar(context, "TODO: Add reply");
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.autorenew),
                  label: Text(item.post.repostCount.toString()),
                  onPressed: () {
                    Ui.snackbar(context, "TODO: Add repost");
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.favorite),
                  label: Text(item.post.likeCount.toString()),
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
