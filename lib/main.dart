import 'package:bluesky/atproto.dart';
import 'package:bluesky/core.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/pages/auth.dart';
import 'package:lightbluesky/pages/home.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  VideoPlayerMediaKit.ensureInitialized(
    linux: true,
    windows: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _setupFuture;

  /// Setups preferences for later usage.
  ///
  /// Checks if user has already loggedin and sets session if its the case
  Future<bool> _setupApp() async {
    await storage.init();

    var session = storage.session.get();
    if (session == null) {
      // New user
      return false;
    }

    // If the refresh token is expired force login
    if (session.refreshToken.isExpired) {
      return false;
    }

    if (session.accessToken.isExpired) {
      // Refresh session
      final refreshedSession = await refreshSession(
        refreshJwt: session.refreshJwt,
      );

      storage.session.set(refreshedSession.data);

      session = refreshedSession.data;
    }

    api.setSession(session);
    await api.setPreferences();
    return true;
  }

  @override
  void initState() {
    super.initState();
    _setupFuture = _setupApp();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'LightBluesky',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: lightColorScheme ?? const ColorScheme.light(),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? const ColorScheme.dark(),
            useMaterial3: true,
          ),
          home: FutureBuilder(
            future: _setupFuture,
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data! ? const HomePage() : const AuthPage();
              } else if (snapshot.hasError) {
                return Text('Error seting up app! ${snapshot.error}');
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        );
      },
    );
  }
}
