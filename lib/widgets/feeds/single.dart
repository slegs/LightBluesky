/// Imports required for Bluesky API integration and Flutter widgets
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/models/feedwithcursor.dart';
import 'package:lightbluesky/widgets/postitem.dart';

/// SingleFeed widget handles displaying a single Bluesky feed stream
/// with infinite scrolling and pagination support.
/// 
/// Type parameter T allows for different feed response types
class SingleFeed<T> extends StatefulWidget {
  /// Creates a SingleFeed widget
  /// 
  /// [func] - Async function that fetches feed data with optional cursor
  /// for pagination
  /// [controller] - ScrollController to manage scroll position and 
  /// trigger loading of more content
  const SingleFeed({
    super.key,
    required this.func,
    required this.controller,
  });

  /// Function that fetches feed data from Bluesky API
  /// Returns XRPCResponse containing feed items and pagination cursor
  final Future<XRPCResponse<bsky.Feed>> Function({String? cursor}) func;
  
  /// Controller for managing scroll position and detecting when
  /// user has scrolled to bottom to load more content
  final ScrollController controller;

  @override
  State<SingleFeed> createState() => _SingleFeedState();
}

/// Maintains state for SingleFeed widget including:
/// - Current feed items
/// - Pagination cursor
/// - Loading states
class _SingleFeedState extends State<SingleFeed> {
  /// Feed state container with empty but growable list of items
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
  Future<void> _loadMore({bool reset = false}) async {
    if (!feed.hasMore) {
      return;
    }

    if (reset) {
      feed.cursor = null;
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
      if (reset) {
        feed.items.clear();
      }
      feed.items.addAll(res.data.feed);
    });
  }

  /// Handles scroll events by checking if user has reached the bottom
  /// of the list. Triggers loading of more content when scroll position
  /// matches maximum scroll extent
  void _onScroll() {
    if (widget.controller.position.pixels ==
        widget.controller.position.maxScrollExtent) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Build the feed UI with pull-to-refresh and infinite scroll
    /// Returns a RefreshIndicator wrapped ListView
    return RefreshIndicator(
      // Trigger refresh when pulled down
      onRefresh: _loadMore,
      child: ListView.builder(
        // Attach scroll controller for infinite scroll
        controller: widget.controller,
        // Dynamic item count based on loaded feed items
        itemCount: feed.items.length,
        // Build individual post items
        itemBuilder: (context, i) {
          return PostItem(
            // Pass post data and metadata to PostItem widget
            item: feed.items[i].post,    // Main post content
            reason: feed.items[i].reason, // Why post appears in feed
            reply: feed.items[i].reply,   // Parent post if this is a reply
          );
        },
      ),
    );
  }
}
