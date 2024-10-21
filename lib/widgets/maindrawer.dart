import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';

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
            title: const Text('Source'),
            onTap: () {
              Ui.openUrl('https://github.com/pablouser1/LightBluesky');
            },
          )
        ],
      ),
    );
  }
}
