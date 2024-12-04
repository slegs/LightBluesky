/// Import core Dart async functionality for Timer
library;
import 'dart:async';

/// Import Bluesky-specific packages for API integration
import 'package:bluesky/app_bsky_embed_video.dart';  // Video embedding support
import 'package:bluesky/atproto.dart';              // AT Protocol core
import 'package:bluesky/bluesky.dart';              // Main Bluesky client
import 'package:bluesky/core.dart';                 // Core Bluesky types

/// Import file handling support
import 'package:file_picker/file_picker.dart';      // File selection dialogs

/// Import app-wide utilities
import 'package:lightbluesky/common.dart';

/// SkyApi provides a wrapper around the Bluesky client with additional
/// functionality for:
/// - Session management
/// - Content filtering
/// - Feed customization
/// - Media uploads 
class SkyApi {
  /// Internal Bluesky client instance
  /// Starts in anonymous mode until login
  Bluesky c = Bluesky.anonymous();

  /// Flag for adult content visibility
  /// When false, adult content is filtered out
  bool adult = false;

  /// Cached list of user's saved feed generators
  /// Updated when feeds are added/removed
  List<SavedFeed> feeds = List.empty(
    growable: true,
  );

  /// User's content label preferences
  /// Controls visibility of different content types
  /// Example: hide nsfw, show nudity, etc
  List<ContentLabelPreference> labels = List.empty(
    growable: true,
  );

  /// Timer for automatic session refresh
  /// Prevents token expiration by refreshing before timeout
  /// Initialized when session is created, cleared on logout
  Timer? _refreshTimer;

  /// Initializes user preferences by fetching from Bluesky API
  /// Handles:
  /// - Adult content settings 
  /// - Saved feed preferences
  /// - Content label visibility settings
  /// Throws if API call fails or session is invalid
  Future<void> initPreferences() async {
    // Fetch current preferences from server
    final res = await c.actor.getPreferences();

    // Process each preference type from server response
    for (final p in res.data.preferences) {
      if (p is UPreferenceAdultContent) {
        // Update local adult content visibility flag based on user preference
        // Controls filtering of NSFW and sensitive content
        adult = p.data.isEnabled;
      } else if (p is UPreferenceSavedFeedsV2) {
        // Process saved feed generator preferences
        // Each item represents a custom feed the user has saved
        for (var item in p.data.items) {
          if (item.type == "feed") {
            // Add valid feed items to local cache
            // Only store items of type "feed" for custom timeline support
            feeds.add(item);
          }
        }
      } else if (p is UPreferenceContentLabel) {
        // Store content label visibility preferences
        labels.add(p.data);
      }
    }
  }

  /// Handles media file uploads and creates appropriate embeds
  /// Parameters:
  /// - files: List of files selected for upload 
  /// - type: Type of media being uploaded (image, video, etc)
  /// Returns an Embed object if successful, null otherwise
  Future<Embed?> upload(List<PlatformFile> files, FileType type) async {
    // Initialize empty embed container
    Embed? embed;

    // Process files based on media type
    switch (type) {
      case FileType.image:
        // Initialize empty list for processed images
        // Growable to allow adding images as they're processed
        final List<Image> images = List.empty(
          growable: true,
        );

        // Process each image file and create Image objects
        for (var file in files) {
          // Read file bytes for upload
          final bytes = await file.xFile.readAsBytes();

          // Upload bytes to Bluesky blob storage and get reference
          final uploaded = await c.atproto.repo.uploadBlob(
            bytes,
          );

          // Create image object with uploaded blob reference
          // Alt text left empty for accessibility - should be added later
          images.add(
            Image(alt: '', image: uploaded.data.blob),
          );
        }

        // Create final embed containing all processed images
        embed = Embed.images(
          data: EmbedImages(
            images: images,
          ),
        );
        break;
      case FileType.video:
        // Handle video upload and embedding
        // Process only first video file
        // Multiple video uploads not supported
        final bytes = await files[0].xFile.readAsBytes();

        // Upload video bytes to Bluesky blob storage
        final uploaded = await c.atproto.repo.uploadBlob(
          bytes,
        );

        // Create video embed with blob reference
        embed = Embed.video(
          data: EmbedVideo(
            video: uploaded.data.blob,
          ),
        );
        break;

      default:
        // Return null for unsupported media types
        embed = null;
    }

    return embed;
  }

  /// Attempts to restore and validate a saved session
  /// Returns true if session restored successfully
  Future<bool> init() async {
    // Try loading saved session from storage
    final session = storage.session.get();
    
    // Return false if no session found
    if (session == null) {
      return false;
    }

    // Initialize client with saved session
    c = Bluesky.fromSession(session);

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

  
  /// Attempts to refresh the current session using the refresh token
  /// Throws if refresh fails or token is invalid
  Future<void> _refresh() async {
    // Validate session exists before attempting refresh
    if (c.session?.refreshJwt == null) {
      throw StateError('No refresh token available');
    }

    try {
      // Attempt to refresh session with current refresh token
      final refreshedSession = await refreshSession(
        refreshJwt: c.session!.refreshJwt,
      );

      // Save new session data and restart refresh timer
      _save(refreshedSession.data);
      _timer();
    } catch (e) {
      // Clear invalid session state
      _save(null);

      
      // Log refresh failure for debugging
      //debugPrint('Session refresh failed: $e');

      // Re-throw to allow proper error handling upstream
      //rethrow;
    }
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
