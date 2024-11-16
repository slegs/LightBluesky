import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/models/feedwithcursor.dart';
import 'package:lightbluesky/widgets/postitem.dart';

/// Single Bluesky feed widget
class SingleFeed<T> extends StatefulWidget {
  const SingleFeed({
    super.key,
    required this.func,
    required this.controller,
  });

  final Future<XRPCResponse<bsky.Feed>> Function({String? cursor}) func;
  final ScrollController controller;

  @override
  State<SingleFeed> createState() => _SingleFeedState();
}

class _SingleFeedState extends State<SingleFeed> {
  final FeedWithCursor feed = FeedWithCursor(
    items: List.empty(
      growable: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  /// Get data from API
  Future<void> _loadMore() async {
    if (!feed.hasMore) {
      return;
    }

    final res = await widget.func(
      cursor: feed.cursor,
    );

    if (res.data.cursor == null) {
      feed.hasMore = false;
    }

    feed.cursor = res.data.cursor;

    if (!mounted) {
      // User disposed widget before API request could finish
      return;
    }

    setState(() {
      feed.items.addAll(res.data.feed);
    });
  }

  /// Scroll hook, loads data if scroll close to bottom
  void _onScroll() {
    if (widget.controller.position.pixels ==
        widget.controller.position.maxScrollExtent) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      itemCount: feed.items.length,
      itemBuilder: (context, i) {
        return PostItem(
          item: feed.items[i].post,
          reason: feed.items[i].reason,
          reply: feed.items[i].reply,
        );
      },
    );
  }
}
