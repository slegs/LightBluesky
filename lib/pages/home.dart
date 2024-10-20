import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<bsky.FeedView> items = List.empty(
    growable: true,
  );

  String? cursor;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMore() async {
    final res = await api.feed.getTimeline(
      cursor: '',
    );

    cursor = res.data.cursor;

    setState(() {
      items.addAll(res.data.feed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index].post.author.handle),
              subtitle: Text(items[index].post.record.text),
            );
          },
        ),
      ),
    );
  }
}
