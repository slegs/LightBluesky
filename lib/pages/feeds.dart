import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/feed.dart';
import 'package:lightbluesky/widgets/exceptionhandler.dart';

class FeedsPage extends StatefulWidget {
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  late Future<XRPCResponse<bsky.FeedGenerators>> _futureGenerators;

  @override
  void initState() {
    super.initState();

    _futureGenerators = api.c.feed.getFeedGenerators(
      uris: api.feedGenerators.map((f) => AtUri(f.value)).toList(),
    );
  }

  // api.feedGenerators

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feeds"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder(
        future: _futureGenerators,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final gen = snapshot.data!;

            return ListView.builder(
              itemCount: gen.data.feeds.length,
              itemBuilder: (context, i) {
                final data = gen.data.feeds[i];
                return ListTile(
                    onTap: () {
                      Ui.nav(
                        context,
                        FeedPage(
                          title: data.displayName,
                          uri: data.uri,
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: data.avatar != null
                          ? NetworkImage(data.avatar!)
                          : null,
                    ),
                    title: Text(data.displayName),
                    subtitle: Text('@${data.createdBy.handle}'),
                    trailing: Text('${data.likeCount.toString()} like(s)'));
              },
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
