import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/profile.dart';

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
            title: const Text('Settings'),
            onTap: () {
              Ui.snackbar(context, "TODO: Add settings");
            },
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              if (api.session == null) {
                Ui.snackbar(context, 'Not logged in!');
                return;
              }

              Ui.nav(
                context,
                ProfilePage(did: api.session!.did),
              );
            },
          ),
          ListTile(
            title: const Text('Source'),
            onTap: () {
              /// TODO: Get source URL from pubspec.yml instead of hardcode??
              Ui.openUrl('https://github.com/pablouser1/LightBluesky');
            },
          ),
        ],
      ),
    );
  }
}
