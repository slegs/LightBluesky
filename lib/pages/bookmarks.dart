import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/widgets/feeds/single.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({
    super.key,
  });

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final _scrollController = ScrollController();

  List<AtUri> uris = List.empty(
    growable: true,
  );

  @override
  void initState() {
    super.initState();

    final bookmarks = storage.bookmark.get();
    for (final bm in bookmarks) {
      uris.add(
        AtUri.parse(bm),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarks"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: storage.bookmark.get().isNotEmpty
          ? SingleFeed(
              func: ({String? cursor}) async {
                final res = await api.c.feed.getPosts(
                  uris: uris,
                );

                return XRPCResponse(
                  headers: res.headers,
                  status: res.status,
                  request: res.request,
                  rateLimit: res.rateLimit,
                  data: Feed(
                    feed: res.data.posts
                        .map(
                          (p) => FeedView(
                            post: p,
                          ),
                        )
                        .toList(),
                  ),
                );
              },
              controller: _scrollController,
            )
          : Center(
              child: Text('No bookmarks'),
            ),
    );
  }
}
