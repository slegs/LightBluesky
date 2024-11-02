import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/partials/postcard.dart';

class PostItem extends StatelessWidget {
  const PostItem({
    super.key,
    required this.item,
    this.reason,
    this.reply,
  });

  final bsky.Post item;
  final bsky.Reason? reason;
  final bsky.Reply? reply;

  List<Widget> _handleReply() {
    List<Widget> widgets = List.empty(
      growable: true,
    );

    final root = reply!.root as bsky.UReplyPostRecord;
    final parent = reply!.parent as bsky.UReplyPostRecord;

    widgets.add(
      PostCard(
        item: root.data,
      ),
    );

    if (root.data.cid != parent.data.cid) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
          ),
          child: PostCard(
            item: parent.data,
          ),
        ),
      );
    }

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
        ),
        child: PostCard(
          item: item,
          reason: reason,
        ),
      ),
    );

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return reply == null
        ? PostCard(
            item: item,
            reason: reason,
          )
        : Column(
            children: _handleReply(),
          );
  }
}
