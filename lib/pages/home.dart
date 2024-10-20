import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/widgets/feeditem.dart';
import 'package:lightbluesky/widgets/maindrawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();

  List<bsky.FeedView> items = List.empty(
    growable: true,
  );

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

  void _scrollHook() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final res = await api.feed.getTimeline(
      cursor: cursor,
    );

    cursor = res.data.cursor;

    setState(() {
      items.addAll(res.data.feed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LightBluesky'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Following',
              ),
            ],
          ),
        ),
        body: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: TabBarView(
            children: [
              ListView.builder(
                controller: _scrollController,
                itemCount: items.length,
                itemBuilder: (context, i) => FeedItem(item: items[i]),
              ),
            ],
          ),
        ),
        drawer: const MainDrawer(),
      ),
    );
  }
}
