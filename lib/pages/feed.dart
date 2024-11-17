import 'package:bluesky/atproto.dart';
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/widgets/exceptionhandler.dart';
import 'package:lightbluesky/widgets/feeds/single.dart';
import 'package:bluesky/ids.dart' as ns;

/// Individual feed generator page
class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    required this.handle,
    required this.rkey,
  });

  final String handle;
  final String rkey;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollController = ScrollController();
  late Future<XRPCResponse<DID>> _futureDid;

  @override
  void initState() {
    super.initState();
    _futureDid = api.c.atproto.identity.resolveHandle(
      handle: widget.handle,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rkey),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        future: _futureDid,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final uri = AtUri.make(
              snapshot.data!.data.did,
              ns.appBskyFeedGenerator,
              widget.rkey,
            );
            return SingleFeed(
              func: ({String? cursor}) => api.c.feed.getFeed(
                generatorUri: uri,
                cursor: cursor,
              ),
              controller: _scrollController,
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_upward),
        onPressed: () {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        },
      ),
    );
  }
}
