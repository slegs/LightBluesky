import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/models/customtab.dart';
import 'package:lightbluesky/partials/dialogs/publish.dart';
import 'package:lightbluesky/widgets/maindrawer.dart';
import 'package:lightbluesky/widgets/feeds/multiple.dart';

/// Home page, contains timeline and pinned feeds
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late TabController _tabController;
  bool _loading = true;

  /// Feed generators data
  final List<CustomTab> _tabs = [
    CustomTab(
      name: 'Timeline',
      func: ({cursor}) => api.c.feed.getTimeline(
        cursor: cursor,
      ),
    ),
  ];

  /// Init widget
  Future<void> _init() async {
    setState(() {
      _loading = true;
    });

    // Get feed generators pinned by user
    final data = await _getFeedGenerators();
    _tabController = TabController(
      length: data.length + 1, // +1 for following (timeline)
      vsync: this,
    );

    for (final gen in data) {
      _tabs.add(
        CustomTab(
          name: gen.displayName,
          func: ({cursor}) => api.c.feed.getFeed(
            generatorUri: gen.uri,
            cursor: cursor,
          ),
        ),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  /// Gets all feed generators pinned by user
  Future<List<bsky.FeedGeneratorView>> _getFeedGenerators() async {
    List<AtUri> data = [];

    for (final item in api.feeds) {
      if (item.pinned) {
        data.add(AtUri(item.value));
      }
    }

    final res = await api.c.feed.getFeedGenerators(
      uris: data,
    );

    return res.data.feeds;
  }

  List<Widget> _handleTabs() {
    List<Widget> widgets = [];

    for (final tab in _tabs) {
      widgets.add(
        Tab(
          text: tab.name,
        ),
      );
    }

    return widgets;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('LightBluesky'),
              primary: true,
              floating: true,
              snap: true,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const PublishDialog(),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
              bottom: !_loading
                  ? TabBar(
                      tabs: _handleTabs(),
                      controller: _tabController,
                      isScrollable: true,
                    )
                  : null,
            ),
          ];
        },
        body: !_loading
            ? MultipleFeeds(
                tabController: _tabController,
                scrollController: _scrollController,
                tabs: _tabs,
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_upward),
        onPressed: () {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        },
      ),
    );
  }
}
