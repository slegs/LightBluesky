import 'package:bluesky/bluesky.dart';

class FeedWithCursor {
  final List<FeedView> items;
  final String? cursor;

  const FeedWithCursor({
    required this.items,
    this.cursor,
  });

  set cursor(String? newCursor) => newCursor;
}
