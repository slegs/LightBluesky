import 'package:bluesky/bluesky.dart';

class FeedWithCursor {
  final List<FeedView> items;
  String? cursor;

  FeedWithCursor({
    required this.items,
    this.cursor,
  });

  void setCursor(String? newCursor) {
    cursor = newCursor;
  }
}
