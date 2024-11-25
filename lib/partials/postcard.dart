import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightbluesky/helpers/urlbuilder.dart';
import 'package:lightbluesky/partials/actor.dart';
import 'package:lightbluesky/partials/interaction.dart';
import 'package:lightbluesky/partials/textwithfacets.dart';
import 'package:lightbluesky/partials/icontext.dart';
import 'package:lightbluesky/widgets/embed.dart';

class Section {
  final bool enabled;
  final bool tappable;

  const Section({
    this.enabled = true,
    this.tappable = true,
  });
}

class Sections {
  final Section actor;
  final Section post;
  final Section embed;
  final Section interaction;

  const Sections({
    this.actor = const Section(),
    this.post = const Section(),
    this.embed = const Section(),
    this.interaction = const Section(),
  });
}

/// Card containing a FeedView (post)
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.item,
    this.reason,
    this.sections = const Sections(),
  });

  final bsky.Post item;
  final bsky.Reason? reason;
  final Sections sections;

  /// Reason text
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
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reason != null) _handleReason(),
        // START Author's data
        if (sections.actor.enabled)
          Actor(
            actor: item.author,
            tap: sections.actor.tappable,
            createdAt: item.record.createdAt,
          ),
        Padding(
          padding: const EdgeInsets.only(
            left: 10.0,
          ),
          child: TextWithFacets(
            text: item.record.text,
            facets: item.record.facets,
          ),
        ),
        // END Author's data
        // Add embed if available
        if (sections.embed.enabled && item.embed != null)
          EmbedRoot(
            item: item.embed!,
            labels: item.labels,
            open: sections.embed.tappable,
          ),
        if (sections.interaction.enabled)
          InteractionPostCard(
            item: item,
          ),
      ],
    );
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      elevation: 5,
      child: sections.post.tappable
          ? InkWell(
              onTap: () {
                // Redirect to post
                context.push(
                  UrlBuilder.post(
                    item.author.handle,
                    item.uri.rkey,
                  ),
                );
              },
              child: col,
            )
          : col,
    );
  }
}
