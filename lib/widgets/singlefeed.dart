import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/widgets/postitem.dart';

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
  final List<bsky.FeedView> items = List.empty(
    growable: true,
  );
  String? cursor;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
    _loadMore();
  }

  Future<void> _loadMore() async {
    final res = await widget.func(
      cursor: cursor,
    );

    cursor = res.data.cursor;

    setState(() {
      items.addAll(res.data.feed);
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
      itemCount: items.length,
      itemBuilder: (context, i) {
        return PostItem(
          item: items[i].post,
          reason: items[i].reason,
          reply: items[i].reply,
        );
      },
    );
  }
}
