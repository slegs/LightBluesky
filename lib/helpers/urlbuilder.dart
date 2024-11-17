/// Wrapper for Bluesky's url
class UrlBuilder {
  static const baseUrl = "https://bsky.app";

  static String full(String path) {
    return '${UrlBuilder.baseUrl}$path';
  }

  /// Profile URL
  static String profile(String handle) {
    return '/profile/$handle';
  }

  static String feedGenerator(String handle, String rkey) {
    return '${profile(handle)}/feed/$rkey';
  }

  /// Post from a user
  static String post(String handle, String rkey) {
    return '${profile(handle)}/post/$rkey';
  }
}
