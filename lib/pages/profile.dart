import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/skyapi.dart';
import 'package:lightbluesky/models/feedwithcursor.dart';
import 'package:lightbluesky/partials/actor.dart';
import 'package:lightbluesky/partials/customimage.dart';
import 'package:lightbluesky/widgets/exceptionhandler.dart';
import 'package:lightbluesky/widgets/postitem.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.did});

  final String did;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _feedFilters = bsky.FeedFilter.values;
  late Future<XRPCResponse<bsky.ActorProfile>> _futureProfile;
  late TabController _tabController;

  List<FeedWithCursor> feeds = bsky.FeedFilter.values
      .map(
        (_) => FeedWithCursor(
            items: List<bsky.FeedView>.empty(
              growable: true,
            ),
            cursor: ''),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _feedFilters.length,
      vsync: this,
    );

    _futureProfile = api.actor.getProfile(actor: widget.did);
    _loadMore();
    _tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    final index = _tabController.index;

    final res = await api.feed.getAuthorFeed(
      actor: widget.did,
      cursor: feeds[index].cursor,
      filter: _feedFilters[index],
    );

    final filteredFeed = SkyApi.filterFeed(res.data.feed);

    feeds[index].cursor = res.data.cursor;

    setState(() {
      feeds[index].items.addAll(filteredFeed);
    });
  }

  void _onTabChange() {
    if (!_tabController.indexIsChanging) {
      return;
    }

    final newIndex = _tabController.index;

    if (feeds.length < newIndex) {
      // Out of bounds
      return;
    }

    if (feeds[newIndex].items.isEmpty) {
      _loadMore();
    }
  }

  Widget _makeProfileCard(bsky.ActorProfile actor) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Actor(
            actor: bsky.ActorBasic(
              did: actor.did,
              handle: actor.handle,
              displayName: actor.displayName,
              avatar: actor.avatar,
              associated: actor.associated,
              viewer: actor.viewer,
              labels: actor.labels,
            ),
          ),
          if (actor.description != null)
            Text(
              actor.description!,
            ),
        ],
      ),
    );
  }

  List<Widget> _makeTabs() {
    List<Widget> widgets = [];

    for (final filter in _feedFilters) {
      widgets.add(
        Tab(
          text: filter.name,
        ),
      );
    }

    return widgets;
  }

  List<Widget> _makeTabViews() {
    List<Widget> widgets = [];

    for (var i = 0; i < _feedFilters.length; i++) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: TabBar(
        tabs: _makeTabs(),
        controller: _tabController,
        isScrollable: true,
      ),
      body: FutureBuilder(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final actor = snapshot.data!.data;
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    primary: true,
                    pinned: true,
                    expandedHeight: 150.0,
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: actor.banner != null
                          ? CustomImage(
                              actor.banner!,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _makeProfileCard(actor),
                  ),
                  const SliverToBoxAdapter(
                    child: Divider(),
                  )
                ];
              },
              body: Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: _makeTabViews(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return ExceptionHandler(
              exception: snapshot.error!,
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
