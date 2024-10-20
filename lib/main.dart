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
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
  Future<bool> setupApp() async {
    prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('session')) {
      // New user
      return false;
    }

    final data = prefs.getString('session')!;
    // Get old session data from storage
    var session = Session.fromJson(json.decode(data));

    final isExpired = await SkyApi.isSessionExpired(session);

    if (isExpired) {
      try {
        // Refresh session
        final refreshedSession = await refreshSession(
          refreshJwt: session.refreshJwt,
        );
        prefs.setString('session', json.encode(refreshedSession.data.toJson()));

        session = refreshedSession.data;
      } on InvalidRequestException catch (_) {
        return false;
      }
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
      title: 'LightBluesky',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: FutureBuilder(
        future: _setupFuture,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            FlutterNativeSplash.remove();
            return snapshot.data! ? const HomePage() : const AuthPage();
          } else if (snapshot.hasError) {
            FlutterNativeSplash.remove();
            return Text('Error seting up app! ${snapshot.error}');
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
