import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/skyapi.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/widgets/postitem.dart';
import 'package:lightbluesky/widgets/maindrawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();

  /// List of items available
  List<bsky.FeedView> items = List.empty(
    growable: true,
  );

  /// Current cursor
  String? cursor;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_scrollHook);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  /// Runs when reached bottom of scroll
  void _scrollHook() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  /// Add more items to list
  Future<void> _loadMore() async {
    try {
      final res = await api.feed.getTimeline(
        cursor: cursor,
      );
      final filteredFeed = SkyApi.filterFeed(res.data.feed);

      cursor = res.data.cursor;

      setState(() {
        items.addAll(filteredFeed);
      });
    } on XRPCException catch (e) {
      if (!mounted) return;
      Ui.snackbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LightBluesky'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Following',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: items.length,
              itemBuilder: (context, i) => PostItem(
                item: items[i].post,
                reason: items[i].reason,
              ),
            ),
          ],
        ),
        drawer: const MainDrawer(),
      ),
    );
  }
}
