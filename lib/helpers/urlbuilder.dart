import 'package:bluesky/bluesky.dart';

/// Wrapper for Bluesky's url
class UrlBuilder {
  static const baseUrl = "https://bsky.app";

  /// Profile URL
  static String profile(ActorBasic actor) {
    return '${UrlBuilder.baseUrl}/profile/${actor.handle}';
  }

  /// Post from a user
  static String post(Post post) {
    return '${profile(post.author)}/post/${post.uri.rkey}';
  }
}
