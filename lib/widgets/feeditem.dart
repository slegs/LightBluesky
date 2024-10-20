import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';

class FeedItem extends StatelessWidget {
  const FeedItem({super.key, required this.item});

  final FeedView item;
  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}
