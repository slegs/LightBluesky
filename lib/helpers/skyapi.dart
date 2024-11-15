import 'dart:async';

import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/atproto.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lightbluesky/common.dart';

/// Helper class for specific bluesky API functions
class SkyApi {
  var c = Bluesky.anonymous();
  bool adult = false;
  List<SavedFeed> feedGenerators = List.empty(
    growable: true,
  );
  List<ContentLabelPreference> contentLabels = List.empty(
    growable: true,
  );

  Timer? _refreshTimer;

  /// Set session for Bluesky
  void setSession(Session? newSession) {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
    }

    if (newSession == null) {
      c = Bluesky.anonymous();
      return;
    }

    c = Bluesky.fromSession(newSession);

    // Setup new timer
    final expiresIn =
        newSession.accessToken.expiresAt.difference(DateTime.now());

    _refreshTimer = Timer(expiresIn, () async {
      final refreshedSession = await refreshSession(
        refreshJwt: c.session!.refreshJwt,
      );

      storage.session.set(refreshedSession.data);
      setSession(refreshedSession.data);
    });
  }

  /// Remove items that are from users that are blocked or muted
  List<FeedView> filterFeed(List<FeedView> items) {
    return items
        .where((item) =>
            item.post.author.isNotBlocking && item.post.author.isNotMuted)
        .toList();
  }

  /// Handle file upload, returns Embed of type selected
  Future<Embed?> upload(List<PlatformFile> files, FileType type) async {
    Embed? embed;

    switch (type) {
      case FileType.image:
        final List<Image> images = List.empty(
          growable: true,
        );

        for (var file in files) {
          final bytes = await file.xFile.readAsBytes();

          final uploaded = await c.atproto.repo.uploadBlob(
            bytes,
          );

          images.add(
            Image(alt: '', image: uploaded.data.blob),
          );
        }

        embed = Embed.images(
          data: EmbedImages(
            images: images,
          ),
        );
        break;
      case FileType.video:
        final bytes = await files[0].xFile.readAsBytes();

        final uploaded = await c.atproto.repo.uploadBlob(
          bytes,
        );

        embed = Embed.video(
          data: EmbedVideo(
            video: uploaded.data.blob,
          ),
        );
        break;
      default:
        embed = null;
    }

    return embed;
  }

  /// Save user preferences
  Future<void> setPreferences() async {
    final res = await c.actor.getPreferences();

    for (final p in res.data.preferences) {
      if (p is UPreferenceAdultContent) {
        adult = p.data.isEnabled;
      } else if (p is UPreferenceSavedFeedsV2) {
        for (var item in p.data.items) {
          if (item.type == "feed") {
            feedGenerators.add(item);
          }
        }
      } else if (p is UPreferenceContentLabel) {
        contentLabels.add(p.data);
      }
    }
  }
}
