import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/feeds.dart';
import 'package:lightbluesky/pages/hashtags.dart';
import 'package:lightbluesky/pages/notifications.dart';
import 'package:lightbluesky/pages/profile.dart';
import 'package:lightbluesky/pages/search.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Drawer, shown only on home page
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: const Text('LightBluesky'),
          ),
          // SEARCH
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search'),
            onTap: () {
              Ui.nav(
                context,
                const SearchPage(),
              );
            },
          ),
          // NOTIFICATIONS
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Ui.nav(
                context,
                const NotificationsPage(),
              );
            },
          ),
          // FEEDS
          ListTile(
            leading: const Icon(Icons.feed),
            title: const Text('Feeds'),
            onTap: () {
              Ui.nav(
                context,
                const FeedsPage(),
              );
            },
          ),
          // HASHTAGS
          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text('Hashtags'),
            onTap: () {
              Ui.nav(
                context,
                const HashtagsPage(),
              );
            },
          ),
          // PROFILE
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Ui.nav(
                context,
                ProfilePage(did: api.c.session!.did),
              );
            },
          ),
          // SETTINGS
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Ui.dialog(
                context,
                "Under construction",
                "TODO: Add settings",
              );
            },
          ),
          // Source code
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source'),
            onTap: () {
              Ui.openUrl('https://github.com/pablouser1/LightBluesky');
            },
          ),
          // About the project
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () async {
              final packageInfo = await PackageInfo.fromPlatform();

              if (!context.mounted) return;

              showAboutDialog(
                context: context,
                applicationName: packageInfo.appName,
                applicationVersion: packageInfo.version,
              );
            },
          ),
        ],
      ),
    );
  }
}
