import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/widgets/postitem.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required this.title, required this.uri});

  final String title;
  final AtUri uri;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollController = ScrollController();

  List<bsky.FeedView> items = List.empty(
    growable: true,
  );
  String? cursor;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _loadMore() async {
    setState(() {
      _loading = true;
    });
    final res = await api.c.feed.getFeed(
      generatorUri: widget.uri,
      cursor: cursor,
    );

    cursor = res.data.cursor;

    setState(() {
      _loading = false;
      items.addAll(res.data.feed);
    });
  }

  /// Scroll hook, loads data if scroll close to bottom
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: _loading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(5.0),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: items.length,
        itemBuilder: (context, i) {
          final data = items[i];

          return PostItem(
            item: data.post,
            reason: data.reason,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_upward),
        onPressed: () {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        },
      ),
    );
  }
}
