import 'package:bluesky/bluesky.dart';

/// Wrapper for list of items with a cursor
class FeedWithCursor {
  final List<FeedView> items;
  String? cursor;
  bool hasMore = true;

  FeedWithCursor({
    required this.items,
  });
}
