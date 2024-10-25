import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/models/embedwrapper.dart';
import 'package:lightbluesky/pages/post.dart';
import 'package:lightbluesky/partials/actor.dart';
import 'package:lightbluesky/widgets/embed.dart';
import 'package:lightbluesky/widgets/icontext.dart';

/// Card containing a FeedView (post)
class PostItem extends StatefulWidget {
  const PostItem({super.key, required this.item, this.reason});

  final bsky.Post item;
  final bsky.Reason? reason;

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  int _likes = 0;
  int _reposts = 0;

  AtUri? _userRepostedAtUri;
  bool _userReposted = false;
  AtUri? _userLikedAtUri;
  bool _userLiked = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.isReposted) {
      _userRepostedAtUri = widget.item.viewer.repost!;
      _userReposted = widget.item.isReposted;
    }

    if (widget.item.isLiked) {
      _userLikedAtUri = widget.item.viewer.like!;
      _userLiked = widget.item.isLiked;
    }

    _likes = widget.item.likeCount;
    _reposts = widget.item.repostCount;
  }

  Widget _handleReason() {
    String text;
    IconData icon;

    if (widget.reason!.data is bsky.ReasonRepost) {
      final repost = widget.reason!.data as bsky.ReasonRepost;

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

  Future<void> _handleRepost() async {
    if (_userReposted) {
      // Remove repost
      await api.atproto.repo.deleteRecord(uri: _userRepostedAtUri!);
      _userRepostedAtUri = null;
    } else {
      // Make repost
      final res = await api.feed.repost(
        cid: widget.item.cid,
        uri: widget.item.uri,
      );

      _userRepostedAtUri = res.data.uri;
    }

    setState(() {
      _userReposted = !_userReposted;
      _reposts = _userReposted ? _reposts + 1 : _reposts - 1;
    });
  }

  Future<void> _handleLike() async {
    if (_userLiked) {
      // Remove like
      await api.atproto.repo.deleteRecord(uri: _userLikedAtUri!);
      _userLikedAtUri = null;
    } else {
      // Make like
      final res = await api.feed.like(
        cid: widget.item.cid,
        uri: widget.item.uri,
      );

      _userLikedAtUri = res.data.uri;
    }

    setState(() {
      _userLiked = !_userLiked;
      _likes = _userLiked ? _likes + 1 : _likes - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Ui.nav(
            context,
            PostPage(uri: widget.item.uri),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.reason != null) _handleReason(),
            // START Author's data
            Actor(
              actor: widget.item.author,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
              ),
              child: Text(
                widget.item.record.text,
              ),
            ),
            // END Author's data
            // Add embed if available
            if (widget.item.embed != null)
              Embed(
                wrap: EmbedWrapper.fromApi(
                  root: widget.item.embed!,
                ),
              ),
            // START interaction buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.reply_outlined),
                  label: Text(widget.item.replyCount.toString()),
                  onPressed: () {
                    Ui.nav(
                      context,
                      PostPage(uri: widget.item.uri, autoReply: true),
                    );
                  },
                ),
                TextButton.icon(
                  icon: _userReposted
                      ? const Icon(Icons.autorenew)
                      : const Icon(Icons.autorenew_outlined),
                  label: Text(
                    _reposts.toString(),
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
                  onPressed: _handleLike,
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
