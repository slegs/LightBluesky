import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/partials/dialogs/postcontext.dart';
import 'package:lightbluesky/partials/dialogs/publish.dart';

class InteractionPostCard extends StatefulWidget {
  const InteractionPostCard({
    super.key,
    required this.item,
  });

  final bsky.Post item;

  @override
  State<InteractionPostCard> createState() => _InteractionPostCardState();
}

class _InteractionPostCardState extends State<InteractionPostCard> {
  int _likes = 0;
  int _reposts = 0;

  AtUri? _userRepostedAtUri;
  bool _userReposted = false;
  AtUri? _userLikedAtUri;
  bool _userLiked = false;

  @override
  void initState() {
    super.initState();

    // Initial value for repost
    if (widget.item.isReposted) {
      _userRepostedAtUri = widget.item.viewer.repost!;
      _userReposted = widget.item.isReposted;
    }

    // Initial value for like
    if (widget.item.isLiked) {
      _userLikedAtUri = widget.item.viewer.like!;
      _userLiked = widget.item.isLiked;
    }

    _likes = widget.item.likeCount;
    _reposts = widget.item.repostCount;
  }

  /// Add / Remove repost
  void _handleRepost() async {
    (() async {
      if (_userReposted) {
        // Remove repost
        await api.c.atproto.repo.deleteRecord(uri: _userRepostedAtUri!);
        _userRepostedAtUri = null;
      } else {
        // Make repost
        final res = await api.c.feed.repost(
          cid: widget.item.cid,
          uri: widget.item.uri,
        );

        _userRepostedAtUri = res.data.uri;
      }
    })();

    setState(() {
      _userReposted = !_userReposted;
      _reposts = _userReposted ? _reposts + 1 : _reposts - 1;
    });
  }

  /// Add / Remove like
  void _handleLike() {
    (() async {
      if (_userLiked) {
        // Remove like
        await api.c.atproto.repo.deleteRecord(uri: _userLikedAtUri!);
        _userLikedAtUri = null;
      } else {
        // Make like
        final res = await api.c.feed.like(
          cid: widget.item.cid,
          uri: widget.item.uri,
        );

        _userLikedAtUri = res.data.uri;
      }
    })();

    setState(() {
      _userLiked = !_userLiked;
      _likes = _userLiked ? _likes + 1 : _likes - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.reply_outlined),
          label: Text(widget.item.replyCount.toString()),
          onPressed: widget.item.isNotReplyDisabled
              ? () {
                  showDialog(
                    context: context,
                    builder: (_) => PublishDialog(
                      parent: widget.item,
                    ),
                  );
                }
              : null,
        ),
        TextButton.icon(
          icon: _userReposted
              ? const Icon(Icons.autorenew)
              : const Icon(Icons.autorenew_outlined),
          label: Text(
            _reposts.toString(),
          ),
          style: TextButton.styleFrom(
            foregroundColor: _userReposted ? Colors.green : null,
          ),
          onPressed: _handleRepost,
        ),
        TextButton.icon(
          icon: _userLiked
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_outline),
          label: Text(
            _likes.toString(),
          ),
          style: TextButton.styleFrom(
            foregroundColor: _userLiked ? Colors.red : null,
          ),
          onPressed: _handleLike,
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => PostContextDialog(
                post: widget.item,
              ),
            );
          },
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
