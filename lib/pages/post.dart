import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/partials/postcard.dart';
import 'package:bluesky/ids.dart' as ns;

/// Individual post page, shows full thread
class PostPage extends StatefulWidget {
  const PostPage({
    super.key,
    required this.handle,
    required this.rkey,
  });

  final String handle;
  final String rkey;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final List<bsky.Post> posts = List.empty(
    growable: true,
  );

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _init() async {
    final uri = AtUri.make(widget.handle, ns.appBskyFeedPost, widget.rkey);

    final res = await api.c.feed.getPostThread(
      uri: uri,
      depth: 10,
    );

    final thread = res.data.thread as bsky.UPostThreadViewRecord;

    final parents = _handleParent(thread);
    final root = thread.data.post;
    final children = _handleChildren(thread);

    setState(() {
      posts.addAll([...parents, root, ...children]);
    });
  }

  List<bsky.Post> _handleParent(bsky.UPostThreadViewRecord thread) {
    if (thread.data.parent == null) {
      return [];
    }

    List<bsky.Post> parents = [];
    bool done = false;
    var current = thread.data.parent! as bsky.UPostThreadViewRecord;
    while (!done) {
      // Add Post
      parents.add(current.data.post);

      if (current.data.parent == null) {
        done = true;
      } else {
        current = current.data.parent as bsky.UPostThreadViewRecord;
      }
    }

    return parents.reversed.toList();
  }

  List<bsky.Post> _handleChildren(bsky.UPostThreadViewRecord thread) {
    if (thread.data.replies == null) {
      return [];
    }

    List<bsky.Post> children = [];

    for (final reply in thread.data.replies!) {
      final item = reply as bsky.UPostThreadViewRecord;
      children.add(item.data.post);

      // Load replies nested only if...
      // There are nested replies available
      // The author is replying to themselves (a thread)
      if (reply.data.post.author.did == thread.data.post.author.did &&
          reply.data.replies != null) {
        children.addAll(_handleChildren(item));
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            item: posts[index],
          );
        },
      ),
    );
  }
}
