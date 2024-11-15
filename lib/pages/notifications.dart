import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';

/// Notificatons page
/// TODO: Group notifications
/// TODO: Handle read
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final controller = ScrollController();
  final List<bsky.Notification> items = List.empty(
    growable: true,
  );

  String? cursor;

  @override
  void initState() {
    super.initState();
    _loadMore();
    controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    final res = await api.c.notification.listNotifications(
      cursor: cursor,
    );

    cursor = res.data.cursor;

    setState(() {
      items.addAll(res.data.notifications);
    });
  }

  /// Scroll hook, loads data if scroll close to bottom
  void _onScroll() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];

          IconData icon;
          String text;

          if (item.reason.isFollow) {
            icon = Icons.person_add;
            text = 'followed you';
          } else if (item.reason.isLike) {
            icon = Icons.favorite;
            text = 'liked your post';
          } else if (item.reason.isRepost) {
            icon = Icons.autorenew;
            text = 'reposted your post';
          } else {
            icon = Icons.question_mark;
            text = item.reason.toString();
          }

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: item.author.avatar != null
                      ? NetworkImage(item.author.avatar!)
                      : null,
                ),
                title: Text(item.author.displayName ?? item.author.handle),
                subtitle: Text(text),
                trailing: Icon(icon),
              ),
            ],
          );
        },
      ),
    );
  }
}
