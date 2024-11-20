import 'dart:async';

import 'package:bluesky/app_bsky_embed_video.dart';
import 'package:bluesky/atproto.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lightbluesky/common.dart';

/// Helper class for specific bluesky API functions
class SkyApi {
  /// Bluesky client instance
  Bluesky c = Bluesky.anonymous();

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

  /// Timer used for refreshing session
  Timer? _refreshTimer;

  /// Save user preferences
  Future<void> initPreferences() async {
    final res = await c.actor.getPreferences();

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

  /// Try restoring session is valid
  Future<bool> init() async {
    final session = storage.session.get();
    if (session == null) {
      // New user or refresh token is expired
      return false;
    }

    _save(session, disk: false);

    final now = DateTime.now();

    // Check if refresh token is expired
    if (now.isAfter(c.session!.refreshTokenJwt.exp)) {
      return false;
    }

    // Check if access token is expired
    if (now.isAfter(c.session!.accessTokenJwt.exp)) {
      await _refresh();
    } else {
      _timer();
    }

    return true;
  }

  /// Authorizes user
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

  /// Remove all login data
  void logout() {
    deleteSession(
      refreshJwt: c.session!.refreshJwt,
    );
    _save(null);
  }

  /// Refresh session using refreshJwt
  Future<void> _refresh() async {
    final refreshedSession = await refreshSession(
      refreshJwt: c.session!.refreshJwt,
    );

    _save(refreshedSession.data);
    _timer();
  }

  /// Save session to memory and optionally to disk
  void _save(Session? session, {bool disk = true}) {
    if (disk) {
      if (session == null) {
        storage.session.remove();
      } else {
        storage.session.set(session);
      }
    }

    if (session == null) {
      c = Bluesky.anonymous();
    } else {
      c = Bluesky.fromSession(session);
    }
  }

  /// Setup refresh timer
  void _timer() {
    if (_refreshTimer != null && _refreshTimer!.isActive) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
    }

    final expiresIn = c.session!.accessTokenJwt.exp.difference(DateTime.now());

    _refreshTimer = Timer(expiresIn, _refresh);
  }
}
