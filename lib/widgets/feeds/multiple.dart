import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/models/customtab.dart';
import 'package:lightbluesky/models/feedwithcursor.dart';
import 'package:lightbluesky/widgets/postitem.dart';

/// Multiple Bluesky feed widget
class MultipleFeeds extends StatefulWidget {
  const MultipleFeeds({
    super.key,
    required this.tabController,
    required this.scrollController,
    required this.tabs,
  });

  final TabController tabController;
  final ScrollController scrollController;
  final List<CustomTab> tabs;

  @override
  State<MultipleFeeds> createState() => _MultipleFeedsState();
}

class _MultipleFeedsState extends State<MultipleFeeds> {
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

  /// Get data from API
  Future<void> _loadMore({
    bool reset = false,
  }) async {
    final index = widget.tabController.index;
    
    // Validate index bounds
    if (index < 0 || index >= _feeds.length) {
      return;
    }

    // Check if more data available
    if (!_feeds[index].hasMore) {
      return;
    }

    try {
      if (reset) {
        _feeds[index].items.clear();
        _feeds[index].cursor = null;
      }

      final res = await widget.tabs[index].func(
        cursor: _feeds[index].cursor,
      );

      if (res != null) {
        if (reset) {
          _feeds[index].items.clear();
          _feeds[index].items.addAll(res.data.feed);
        } else {
          _feeds[index].items.addAll(res.data.feed);
        }
        _feeds[index].cursor = res.data.cursor;
        //_feeds[index].hasMore = res.data.hasMore;
      }

    } catch (e) {
      // Handle blocked user error
      if (e.toString().contains('Requester has blocked actor')) {
        _feeds[index].hasMore = false;
        _feeds[index].isBlocked = true; // Add this field to FeedWithCursor
      } else if (e.toString().contains('400')) {
        // Handle other 400 errors
        _feeds[index].hasError = true; // Add this field to FeedWithCursor
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
