import 'package:bluesky/bluesky.dart' as bsky;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/profile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Common widget for
/// displaying actor's display name and/or handle and profile picture
class Actor extends StatelessWidget {
  const Actor({
    super.key,
    required this.actor,
    this.createdAt,
    this.tap = true,
  });

  /// Actor data
  final bsky.ActorBasic actor;

  /// Date for post relating to actor
  final DateTime? createdAt;

  /// Allow tapping to open actor's profile
  final bool tap;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return ListTile(
      onTap: tap
          ? () => Ui.nav(
                context,
                ProfilePage(did: actor.did),
              )
          : null,
      leading: CircleAvatar(
        backgroundImage: actor.avatar != null
            ? CachedNetworkImageProvider(
                actor.avatar!,
                cacheManager: cache,
              )
            : null,
      ),
      title: Text(
        actor.displayName != null ? actor.displayName! : '@${actor.handle}',
      ),
      subtitle: actor.displayName != null ? Text('@${actor.handle}') : null,
      trailing: createdAt != null
          ? Text(GetTimeAgo.parse(
              createdAt!,
              locale: locale.localeName,
            ))
          : null,
    );
  }
}
