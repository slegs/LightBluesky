import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/widgets/exceptionhandler.dart';

/// Notificatons page
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<XRPCResponse<bsky.Notifications>> _futureNotifications;

  @override
  void initState() {
    super.initState();
    _futureNotifications = api.c.notification.listNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            api.c.notification.listNotifications();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder(
        future: _futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final items = snapshot.data!.data.notifications;

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index].author.displayName ??
                        items[index].author.handle,
                  ),
                );
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
