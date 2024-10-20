import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';

class FeedItem extends StatelessWidget {
  const FeedItem({super.key, required this.item});

  final FeedView item;
  @override
  Widget build(BuildContext context) {
    final buf = StringBuffer();
    if (item.post.author.displayName != null) {
      buf.write('${item.post.author.displayName} ');
    }

    buf.write('@${item.post.author.handle}');
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: item.post.author.avatar != null
              ? NetworkImage(item.post.author.avatar!)
              : null,
        ),
        title: Text(buf.toString()),
        subtitle: Text(item.post.record.text),
      ),
    );
  }
}
