import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/widgets/exceptionhandler.dart';
import 'package:lightbluesky/widgets/postitem.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.uri, this.autoReply = false});

  final AtUri uri;
  final bool autoReply;

  @override
  State<PostPage> createState() => _PostPageState();
}

/// TODO: Add auto-open reply
class _PostPageState extends State<PostPage> {
  late Future<XRPCResponse<bsky.PostThread>> _futurePost;

  @override
  void initState() {
    super.initState();
    _futurePost = api.c.feed.getPostThread(
      uri: widget.uri,
      depth: 10,
    );
  }

  List<Widget> _handleParent(bsky.UPostThreadViewRecord thread) {
    List<Widget> parents = [];

    bool done = false;
    var current = thread.data.parent! as bsky.UPostThreadViewRecord;
    while (!done) {
      // Add Post
      parents.add(
        PostItem(item: current.data.post),
      );

      if (current.data.parent == null) {
        done = true;
      } else {
        current = current.data.parent as bsky.UPostThreadViewRecord;
      }
    }

    return parents.reversed.toList();
  }

  List<Widget> _handleChildren(bsky.UPostThreadViewRecord thread) {
    List<Widget> widgets = [];

    for (var reply in thread.data.replies!) {
      final item = reply as bsky.UPostThreadViewRecord;
      widgets.add(
        PostItem(
          item: item.data.post,
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder(
        future: _futurePost,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final thread =
                snapshot.data!.data.thread as bsky.UPostThreadViewRecord;

            return ListView(
              children: [
                // Parent
                if (thread.data.parent != null) ..._handleParent(thread),
                // Main
                PostItem(item: thread.data.post),
                // Children
                if (thread.data.replies != null) ..._handleChildren(thread),
              ],
            );
          } else if (snapshot.hasError) {
            return ExceptionHandler(
              exception: snapshot.error!,
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
