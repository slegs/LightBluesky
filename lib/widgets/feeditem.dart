import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/widgets/icontext.dart';

/// Card containing a FeedView (post)
class FeedItem extends StatelessWidget {
  const FeedItem({super.key, required this.item});

  final bsky.FeedView item;

  Widget _handleEmbed() {
    List<Widget> widgets = [];
    final media = item.post.embed!;
    if (media is bsky.UEmbedViewImages) {
      for (var img in media.data.images) {
        final widget = Image.network(
          img.thumbnail,

          // Show progress while downloading image
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        );
        widgets.add(widget);
      }

      return media.data.images.length == 1
          ? widgets[0]
          : GridView.count(
              shrinkWrap: true,
              // Disable scrolling photos
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: media.data.images.length == 1 ? 1 : 2,
              children: widgets,
            );
    }
    return const IconText(
      icon: Icons.warning,
      text: 'Embed type not supported! :(',
    );
  }

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
            if (item.post.embed != null) _handleEmbed(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Ui.snackbar(context, "TODO: Add reply");
                  },
                  icon: const Icon(Icons.reply),
                ),
                IconButton(
                  onPressed: () {
                    Ui.snackbar(context, "TODO: Add repost");
                  },
                  icon: const Icon(Icons.autorenew),
                ),
                IconButton(
                  onPressed: () {
                    Ui.snackbar(context, "TODO: Add like");
                  },
                  icon: const Icon(Icons.favorite),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
