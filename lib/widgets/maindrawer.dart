/// Standard Flutter Material Design widgets import
library;
import 'package:flutter/material.dart';
/// Navigation routing package import
import 'package:go_router/go_router.dart';
/// App-wide common utilities and widgets
import 'package:lightbluesky/common.dart';
/// Application constants and configuration
import 'package:lightbluesky/constants/app.dart';
/// UI helper functions and utilities
import 'package:lightbluesky/helpers/ui.dart';
/// URL construction helpers
import 'package:lightbluesky/helpers/urlbuilder.dart';
/// Custom notification counter widget
import 'package:lightbluesky/partials/notificationscounter.dart';
/// Package for accessing app version information
import 'package:package_info_plus/package_info_plus.dart';
/// Auto-generated localization support
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// MainDrawer is a navigation drawer widget that appears on the home page
/// It provides the main navigation structure for the app
class MainDrawer extends StatelessWidget {
  /// Default constructor with optional key parameter
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    /// Get access to localized strings for current locale
    final locale = AppLocalizations.of(context)!;

    /// Build the main drawer structure
    return Drawer(
      /// ListView allows scrolling if content exceeds screen height
      child: ListView(
        /// Remove default padding from ListView
        padding: EdgeInsets.zero,
        children: [
          /// Drawer header section containing app branding
          DrawerHeader(
            decoration: BoxDecoration(
              /// Use theme's inverse primary color for header background
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
              context.go('/search');
            },
          ),
          // NOTIFICATIONS
          const NotificationsCounter(),
          // FEEDS
          ListTile(
            leading: const Icon(Icons.feed),
            title: const Text('Feeds'),
            onTap: () {
              context.go('/feeds');
            },
          ),
          // BOOKMARKS
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Bookmarks'),
            onTap: () {
              context.go('/bookmarks');
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
                  context.go(
                    UrlBuilder.profile(api.c.session!.did),
                  );
                },
              ),
              // LOGOUT
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(locale.drawer_logout),
                onTap: () {
                  api.logout();

                  Ui.snackbar(context, locale.drawer_logout_ok);

                  context.go('/login');
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
