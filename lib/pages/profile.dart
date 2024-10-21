import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/skyapi.dart';
import 'package:lightbluesky/widgets/apierror.dart';
import 'package:lightbluesky/widgets/postitem.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.did});

  final String did;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scrollController = ScrollController();
  late Future<XRPCResponse<bsky.ActorProfile>> _futureProfile;

  List<bsky.FeedView> items = List.empty(
    growable: true,
  );

  String? cursor;

  @override
  void initState() {
    super.initState();
    _futureProfile = api.actor.getProfile(actor: widget.did);
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
    final res = await api.feed.getAuthorFeed(
      actor: widget.did,
      cursor: cursor,
      filter: bsky.FeedFilter.postsAndAuthorThreads,
    );

    final filteredFeed = SkyApi.filterFeed(res.data.feed);

    cursor = res.data.cursor;

    setState(() {
      items.addAll(filteredFeed);
    });
  }

  Widget _makeProfileCard(bsky.ActorProfile actor) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (actor.banner != null)
              Image.network(
                actor.banner!,
                fit: BoxFit.fitWidth,
              ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    actor.avatar != null ? NetworkImage(actor.avatar!) : null,
              ),
              title: Text(actor.displayName != null
                  ? actor.displayName!
                  : '@${actor.handle}'),
              subtitle:
                  actor.displayName != null ? Text('@${actor.handle}') : null,
            ),
            if (actor.description != null)
              Text(
                actor.description!,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Column(
            children: [
              // User data
              FutureBuilder(
                future: _futureProfile,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _makeProfileCard(snapshot.data!.data);
                  } else if (snapshot.hasError) {
                    return ApiError(exception: snapshot.error as XRPCError);
                  }

                  return const CircularProgressIndicator();
                },
              ),
              // Posts
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, i) => PostItem(
                  item: items[i].post,
                  reason: items[i].reason,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
