import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/models/feedwithcursor.dart';
import 'package:lightbluesky/partials/dialogs/publish.dart';
import 'package:lightbluesky/widgets/maindrawer.dart';
import 'package:lightbluesky/widgets/postitem.dart';

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
  List<bsky.FeedGeneratorView> generators = List.empty(
    growable: true,
  );

  /// All feeds available (+ following!)
  late List<FeedWithCursor> feeds;

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
    _tabController.addListener(_onTabChange);
    _scrollController.addListener(_onScroll);

    generators.addAll(data);
    feeds = [
      FeedWithCursor(
        items: List.empty(
          growable: true,
        ),
      ),
      ...data.map(
        (_) => FeedWithCursor(
          items: List<bsky.FeedView>.empty(
            growable: true,
          ),
          cursor: '',
        ),
      ),
    ];

    _loadMore();

    setState(() {
      _loading = false;
    });
  }

  /// Gets all feed generators pinned by user
  Future<List<bsky.FeedGeneratorView>> _getFeedGenerators() async {
    final actorPrefs = await api.c.actor.getPreferences();

    List<AtUri> data = [];
    var found = false;
    var i = 0;
    while (!found && i < actorPrefs.data.preferences.length) {
      final p = actorPrefs.data.preferences[i];
      if (p is bsky.UPreferenceSavedFeedsV2) {
        for (var item in p.data.items) {
          if (item.pinned && item.type == 'feed') {
            data.add(AtUri(item.value));
          }
        }
        found = true;
      }
      i++;
    }

    final res = await api.c.feed.getFeedGenerators(
      uris: data,
    );

    return res.data.feeds;
  }

  /// Generate tabs from generators + preset following
  List<Widget> _handleTabs() {
    List<Widget> widgets = [
      const Tab(
        text: 'Following',
      )
    ];

    for (var feed in generators) {
      Widget? icon;

      if (feed.avatar != null) {
        icon = CircleAvatar(
          backgroundImage: NetworkImage(
            feed.avatar!,
          ),
        );
      }

      widgets.add(
        Tab(
          text: feed.displayName,
          icon: icon,
        ),
      );
    }

    return widgets;
  }

  /// Generate listviews from all feeds available
  List<Widget> _handleTabChildren() {
    List<Widget> widgets = [];

    for (var i = 0; i < feeds.length; i++) {
      widgets.add(
        ListView.builder(
          itemCount: feeds[i].items.length,
          itemBuilder: (context, j) => PostItem(
            item: feeds[i].items[j].post,
            reason: feeds[i].items[j].reason,
          ),
        ),
      );
    }

    return widgets;
  }

  /// Get feed items from server
  Future<void> _loadMore() async {
    final index = _tabController.index;

    try {
      XRPCResponse<bsky.Feed> res;
      if (index == 0) {
        res = await api.c.feed.getTimeline();
      } else {
        res = await api.c.feed.getFeed(
          generatorUri: generators[index - 1].uri,
        );
      }

      feeds[index].cursor = res.data.cursor;
      setState(() {
        feeds[index].items.addAll(api.filterFeed(res.data.feed));
      });
    } on XRPCException catch (e) {
      if (!mounted) return;
      Ui.snackbar(context, e.toString());
    }
  }

  /// Tab change hook, loads data if tab being changed does not have any items.
  void _onTabChange() {
    if (!(_tabController.indexIsChanging ||
        _tabController.index != _tabController.previousIndex)) {
      return;
    }

    final newIndex = _tabController.index;

    if (feeds[newIndex].items.isEmpty) {
      _loadMore();
    }
  }

  /// Scroll hook, loads data if scroll close to bottom
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
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
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('LightBluesky'),
              primary: true,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            SliverToBoxAdapter(
              child: !_loading
                  ? TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: _handleTabs(),
                    )
                  : null,
            )
          ];
        },
        body: !_loading
            ? TabBarView(
                controller: _tabController,
                children: _handleTabChildren(),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const PublishDialog(),
          );
        },
      ),
    );
  }
}
