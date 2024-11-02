import 'package:bluesky/bluesky.dart';

/// Wrapper for list of items with a cursor
class FeedWithCursor {
  final List<FeedView> items;
  String? cursor;

  FeedWithCursor({
    required this.items,
    this.cursor,
  });

  /// Set cursor
  ///
  /// TODO: Use `set` keyword instead?
  void setCursor(String? newCursor) {
    cursor = newCursor;
  }
}
