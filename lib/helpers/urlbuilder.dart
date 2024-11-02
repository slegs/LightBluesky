import 'package:bluesky/bluesky.dart';

class UrlBuilder {
  static const baseUrl = "https://bsky.app";

  static String profile(ActorBasic actor) {
    return '${UrlBuilder.baseUrl}/profile/${actor.handle}';
  }

  static String post(Post post) {
    return '${profile(post.author)}/post/${post.uri.rkey}';
  }
}
