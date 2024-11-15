import 'dart:async';

import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/atproto.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lightbluesky/common.dart';

var _c = Bluesky.anonymous();

/// Session module for Api helper
class SessionModule {
  Timer? _refreshTimer;

  Future<bool> init() async {
    final session = storage.session.get();
    if (session == null || session.refreshToken.isExpired) {
      // New user or refresh token is expired
      return false;
    }

    if (session.accessToken.isExpired) {
      _refresh();
    } else {
      _save(session, disk: false);
    }

    return true;
  }

  Future<void> login(
    String service,
    String identity,
    String password,
    String? authFactor,
  ) async {
    // Try login
    final session = await createSession(
      service: service,
      identifier: identity,
      password: password,
      authFactorToken: authFactor,
    );

    _save(session.data);
  }

  void logout() {
    deleteSession(
      refreshJwt: _c.session!.refreshJwt,
    );
    _save(null);
  }

  Future<void> _refresh() async {
    final refreshedSession = await refreshSession(
      refreshJwt: _c.session!.refreshJwt,
    );

    _save(refreshedSession.data);
    _timer();
  }

  /// Save to memory and optionally to disk
  void _save(Session? session, {bool disk = true}) {
    if (disk) {
      if (session == null) {
        storage.session.remove();
      } else {
        storage.session.set(session);
      }
    }

    if (session == null) {
      _c = Bluesky.anonymous();
    } else {
      _c = Bluesky.fromSession(session);
    }
  }

  void _timer() {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
    }

    final expiresIn =
        _c.session!.accessToken.expiresAt.difference(DateTime.now());

    _refreshTimer = Timer(expiresIn, _refresh);
  }
}

/// Files module for Api helper
class FilesModule {
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

          final uploaded = await _c.atproto.repo.uploadBlob(
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

        final uploaded = await _c.atproto.repo.uploadBlob(
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
}

/// Content module for Api helper
class ContentModule {
  /// Has adult content enabled
  bool adult = false;

  /// List of feed generators
  List<SavedFeed> feeds = List.empty(
    growable: true,
  );

  /// List content preferance labels, used for deciding if an item should
  /// be hidden or not
  List<ContentLabelPreference> labels = List.empty(
    growable: true,
  );

  /// Save user preferences
  Future<void> init() async {
    final res = await _c.actor.getPreferences();

    for (final p in res.data.preferences) {
      if (p is UPreferenceAdultContent) {
        adult = p.data.isEnabled;
      } else if (p is UPreferenceSavedFeedsV2) {
        for (var item in p.data.items) {
          if (item.type == "feed") {
            feeds.add(item);
          }
        }
      } else if (p is UPreferenceContentLabel) {
        labels.add(p.data);
      }
    }
  }

  /// Remove items that are from users that are blocked or muted
  List<FeedView> filter(List<FeedView> items) {
    return items
        .where((item) =>
            item.post.author.isNotBlocking && item.post.author.isNotMuted)
        .toList();
  }
}

/// Helper class for specific bluesky API functions
class SkyApi {
  final session = SessionModule();
  final files = FilesModule();
  final content = ContentModule();

  /// Bluesky client instance
  Bluesky get c => _c;
}
