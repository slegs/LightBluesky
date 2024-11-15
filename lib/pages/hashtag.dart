import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/models/customtab.dart';
import 'package:lightbluesky/widgets/feeds/multiple.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Hashtag page
class HashtagPage extends StatefulWidget {
  const HashtagPage({super.key, required this.name});

  /// Hashtag name
  ///
  /// Example: art
  final String name;

  @override
  State<HashtagPage> createState() => _HashtagPageState();
}

class _HashtagPageState extends State<HashtagPage>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late TabController _tabController;
  bool _isSaved = false;

  /// Wrapper made to adapt function to Feed type
  Future<XRPCResponse<Feed>> _func(String sort, String? cursor) async {
    final res = await api.c.feed.searchPosts(
      '#${widget.name}',
      sort: sort,
    );

    // Copy response with modified Feed
    return XRPCResponse(
      headers: res.headers,
      status: res.status,
      request: res.request,
      rateLimit: res.rateLimit,
      data: Feed(
        feed: List.generate(
          res.data.posts.length,
          (index) => FeedView(
            post: res.data.posts[index],
          ),
        ),
        cursor: res.data.cursor,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, // Top + latest
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveHashtag() {
    storage.hashtags.add(widget.name);

    setState(() {
      _isSaved = !_isSaved;
    });
    Ui.snackbar(
      context,
      'Hashtag saved',
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    final tabs = [
      CustomTab(
        name: locale.sort_top,
        func: ({cursor}) => _func('top', cursor),
      ),
      CustomTab(
        name: locale.sort_latest,
        func: ({cursor}) => _func('latest', cursor),
      ),
    ];

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text('#${widget.name}'),
              primary: true,
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              actions: [
                IconButton(
                  onPressed: !_isSaved ? _saveHashtag : null,
                  icon: Icon(
                    _isSaved ? Icons.check : Icons.add,
                  ),
                ),
              ],
              bottom: TabBar(
                tabs: [
                  for (final tab in tabs)
                    Tab(
                      text: tab.name,
                    ),
                ],
                controller: _tabController,
                isScrollable: true,
              ),
            ),
          ];
        },
        body: MultipleFeeds(
          tabController: _tabController,
          scrollController: _scrollController,
          tabs: tabs,
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
