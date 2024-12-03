/// Import required packages for Bluesky API integration and Flutter widgets
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/models/customtab.dart';
import 'package:lightbluesky/models/feedwithcursor.dart';
import 'package:lightbluesky/widgets/postitem.dart';

/// MultipleFeeds widget manages multiple tabbed Bluesky feeds with:
/// - Tab-based navigation
/// - Infinite scrolling
/// - Pagination support
/// - Error handling for blocked users
class MultipleFeeds extends StatefulWidget {
  /// Creates a MultipleFeeds widget
  /// 
  /// Parameters:
  /// [tabController] - Manages tab switching and animation
  /// [scrollController] - Handles scroll position and load triggers
  /// [tabs] - List of feed configurations to display
  const MultipleFeeds({
    super.key,
    required this.tabController,
    required this.scrollController,
    required this.tabs,
  });

  /// Controls tab selection and animation
  final TabController tabController;
  
  /// Controls scroll position and detects when to load more content
  final ScrollController scrollController;
  
  /// Defines the feed configurations for each tab
  final List<CustomTab> tabs;

  @override
  State<MultipleFeeds> createState() => _MultipleFeedsState();
}

/// Maintains state for MultipleFeeds including:
/// - Feed data for each tab
/// - Loading states
/// - Pagination cursors
/// - Error states
class _MultipleFeedsState extends State<MultipleFeeds> {
  /// List of feed states corresponding to each tab
  /// Each FeedWithCursor contains:
  /// - List of feed items
  /// - Pagination cursor
  /// - Loading state
  /// - Error state
  late List<FeedWithCursor> _feeds;

  @override
  void initState() {
    super.initState();

    // Wrap tabs with FeedWithCursor
    _feeds = widget.tabs
        .map(
          (_) => FeedWithCursor(
            items: List<bsky.FeedView>.empty(
              growable: true,
            ),
          ),
        )
        .toList();

    widget.tabController.addListener(_onTabChange);
    widget.scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChange);
    widget.scrollController.removeListener(_onScroll);

    super.dispose();
  }

  /// Loads more feed items for current tab
  /// 
  /// Parameters:
  /// [reset] - If true, clears existing items before loading
  Future<void> _loadMore({bool reset = false}) async {
    final index = widget.tabController.index;
    
    // Early return if no more items available
    if (!_feeds[index].hasMore) {
      return;
    }

    try {
      // Clear existing items if reset requested
      if (reset) {
        _feeds[index].items.clear();
        _feeds[index].cursor = null;
      }

      // Fetch new feed items using tab-specific function
      final res = await widget.tabs[index].func(
        cursor: _feeds[index].cursor,
      );

      // Update feed state with new items
      if (res != null) {
        if (reset) {
          _feeds[index].items.clear();
          _feeds[index].items.addAll(res.data.feed);
        } else {
          _feeds[index].items.addAll(res.data.feed);
        }
        // Update pagination cursor for next load
        _feeds[index].cursor = res.data.cursor;
      }

    } catch (e) {
      // Handle specific error cases
      if (e.toString().contains('Requester has blocked actor')) {
        _feeds[index].hasMore = false;
        _feeds[index].isBlocked = true;
      }
      debugPrint('Feed load error: $e');
    }

    setState(() {});
  }

  /// Tab change hook
  void _onTabChange() {
    if (!(widget.tabController.indexIsChanging ||
        widget.tabController.index != widget.tabController.previousIndex)) {
      return;
    }

    final newIndex = widget.tabController.index;
    if (_feeds[newIndex].items.isEmpty) {
      _loadMore();
    }
  }

  /// Scroll hook, loads data if scroll close to bottom
  void _onScroll() {
    if (widget.scrollController.position.pixels ==
        widget.scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  /// Get ListViews for each tab
  List<Widget> _handleTabViews() {
    List<Widget> widgets = [];

    for (int i = 0; i < _feeds.length; i++) {
      widgets.add(
        RefreshIndicator(
          onRefresh: () => _loadMore(
            reset: true,
          ),
          child: ListView.builder(
            itemCount: _feeds[i].items.length,
            itemBuilder: (context, j) {
              return PostItem(
                item: _feeds[i].items[j].post,
                reason: _feeds[i].items[j].reason,
                reply: _feeds[i].items[j].reply,
              );
            },
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: _handleTabViews(),
    );
  }
}
