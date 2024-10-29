import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/feeds.dart';
import 'package:lightbluesky/pages/profile.dart';
import 'package:lightbluesky/pages/search.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text('Feed'),
            onTap: () {
              Ui.nav(
                context,
                const FeedsPage(),
              );
            },
          ),
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
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Ui.snackbar(context, "TODO: Add settings");
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source'),
            onTap: () {
              /// TODO: Get source URL from pubspec.yml instead of hardcode??
              Ui.openUrl('https://github.com/pablouser1/LightBluesky');
            },
          ),
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
