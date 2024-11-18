import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/partials/icontext.dart';
import 'package:lightbluesky/partials/postcard.dart';

class ReplyPostRoot extends StatelessWidget {
  const ReplyPostRoot({
    super.key,
    required this.root,
  });

  final ReplyPost root;

  @override
  Widget build(BuildContext context) {
    if (root is UReplyPostRecord) {
      return PostCard(
        item: (root as UReplyPostRecord).data,
      );
    }

    String reason;

    /// TODO: TRANSLATE
    if (root is UReplyPostBlocked) {
      reason = 'This post is from a blocked user!';
    } else if (root is UReplyPostNotFound) {
      reason = 'Post not found';
    } else {
      reason = 'Unkown reply type';
    }

    return IconText(
      icon: Icons.warning,
      text: reason,
    );
  }
}
