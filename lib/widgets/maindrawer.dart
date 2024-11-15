import 'package:bluesky/atproto.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/constants/app.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/pages/auth.dart';
import 'package:lightbluesky/pages/feeds.dart';
import 'package:lightbluesky/pages/hashtags.dart';
import 'package:lightbluesky/pages/notifications.dart';
import 'package:lightbluesky/pages/profile.dart';
import 'package:lightbluesky/pages/search.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Drawer, shown only on home page
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: Column(
              children: [
                const Expanded(
                  child: Text(App.name),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final packageInfo = await PackageInfo.fromPlatform();

                    if (!context.mounted) return;

                    showAboutDialog(
                      context: context,
                      applicationName: packageInfo.appName,
                      applicationVersion: packageInfo.version,
                    );
                  },
                  icon: const Icon(Icons.info),
                  label: Text(locale.drawer_about),
                ),
              ],
            ),
          ),
          // SEARCH
          ListTile(
            leading: const Icon(Icons.search),
            title: Text(locale.search_title),
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
            title: Text(locale.notifications_title),
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
            title: Text(locale.hashtags_title),
            onTap: () {
              Ui.nav(
                context,
                const HashtagsPage(),
              );
            },
          ),
          // SETTINGS
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(locale.drawer_settings),
            onTap: () {
              Ui.dialog(
                context,
                "Under construction",
                "TODO: Add settings",
              );
            },
          ),
          // SOURCE CODE
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(locale.drawer_source),
            onTap: () {
              Ui.openUrl(App.source);
            },
          ),
          ExpansionTile(
            title: Text(api.c.session!.handle),
            children: [
              // PROFILE
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(locale.drawer_my_profile),
                onTap: () {
                  Ui.nav(
                    context,
                    ProfilePage(did: api.c.session!.did),
                  );
                },
              ),
              // LOGOUT
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(locale.drawer_logout),
                onTap: () {
                  deleteSession(
                    refreshJwt: api.c.session!.refreshJwt,
                  );
                  storage.session.remove();
                  api.setSession(null);

                  Ui.snackbar(context, locale.drawer_logout_ok);

                  Ui.nav(
                    context,
                    const AuthPage(),
                    wipe: true,
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
