/// Wrapper for Bluesky's urls
class UrlBuilder {
  static const baseUrl = "https://bsky.app";

  /// Get full url
  static String full(String path) {
    return '${UrlBuilder.baseUrl}$path';
  }

  /// Profile path
  static String profile(String handle) {
    return '/profile/$handle';
  }

  /// User's feed generator path
  static String feedGenerator(String handle, String rkey) {
    return '${profile(handle)}/feed/$rkey';
  }

  /// Post from a user
  static String post(String handle, String rkey) {
    return '${profile(handle)}/post/$rkey';
  }
}
