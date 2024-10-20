import 'dart:convert';

import 'package:bluesky/atproto.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/skyapi.dart';
import 'package:lightbluesky/pages/auth.dart';
import 'package:lightbluesky/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
  /// TODO: Move logic to separate file?
  /// TODO: Maybe a better way to handle sessions
  Future<bool> setupApp() async {
    prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('session')) {
      // New user
      return false;
    }

    final data = prefs.getString('session')!;
    // Get old session data from storage
    var session = Session.fromJson(json.decode(data));

    final isExpired = await SkyApi.isExpired(session);

    if (isExpired) {
      // Refresh session
      final refreshedSession = await refreshSession(
        refreshJwt: session.refreshJwt,
      );

      if (refreshedSession.status.code != 200) {
        // The session could not be refreshed.
        return false;
      }

      prefs.setString('session', json.encode(refreshedSession.data.toJson()));

      session = refreshedSession.data;
    }

    api = Bluesky.fromSession(session);
    return true;
  }

  @override
  void initState() {
    super.initState();
    _setupFuture = setupApp();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LightBlueSky',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: FutureBuilder(
        future: _setupFuture,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data! ? const HomePage() : const AuthPage();
          } else if (snapshot.hasError) {
            return Text('Error seting up app! ${snapshot.error}');
          }

          // TODO: Make proper splashscreen
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
