import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/models/embedwrapper.dart';
import 'package:lightbluesky/pages/post.dart';
import 'package:lightbluesky/partials/actor.dart';
import 'package:lightbluesky/partials/dialogs/publish.dart';
import 'package:lightbluesky/partials/textwithfacets.dart';
import 'package:lightbluesky/widgets/embed.dart';
import 'package:lightbluesky/partials/icontext.dart';

/// Card containing a FeedView (post)
class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.item,
    this.reason,
    this.basic = false,
  });

  final bsky.Post item;
  final bsky.Reason? reason;
  final bool basic;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      elevation: 5,
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
              tap: !widget.basic,
              createdAt: widget.item.record.createdAt,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
              ),
              child: TextWithFacets(
                text: widget.item.record.text,
                facets: widget.item.record.facets,
              ),
            ),
            // END Author's data
            // Add embed if available
            if (widget.item.embed != null && !widget.basic)
              Embed(
                wrap: EmbedWrapper.fromApi(
                  root: widget.item.embed!,
                ),
                labels: widget.item.labels,
              ),
            // START interaction buttons
            if (!widget.basic)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.reply_outlined),
                    label: Text(widget.item.replyCount.toString()),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => PublishDialog(
                          parent: widget.item,
                        ),
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
