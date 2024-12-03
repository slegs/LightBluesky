import 'package:bluesky/bluesky.dart';

/// Wrapper for list of items with a cursor
class FeedWithCursor {

  FeedWithCursor({

    required this.items,

    this.cursor,

  });

  final List<FeedView> items;

  String? cursor;

  bool hasMore = true;

  bool hasError = true;

  bool isLoading = false;

  bool isBlocked = false;
}
