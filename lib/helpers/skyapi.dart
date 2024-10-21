import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';

/// Helper class for specific bluesky API functions
class SkyApi {
  /// Checks if a session has expired
  static Future<bool> isSessionExpired(Session oldSession) async {
    final tmpApi = Bluesky.fromSession(oldSession);
    try {
      await tmpApi.atproto.server.getSession();
      return false;
    } on InvalidRequestException catch (_) {
      return true;
    }
  }
}
