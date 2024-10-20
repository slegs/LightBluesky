import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';

class SkyApi {
  /// Gets refreshed session or saved session
  /// Depending on response data
  static Future<bool> isExpired(Session oldSession) async {
    final tmpApi = Bluesky.fromSession(oldSession);
    try {
      await tmpApi.atproto.server.checkAccountStatus();
      return false;
    } on InvalidRequestException catch (e) {
      return e.response.data.error == 'ExpiredToken';
    }
  }
}
