import 'dart:convert';

import 'package:bluesky/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPrefences value
late SharedPreferences _c;

/// Session module for Storage
class SessionModule {
  static const String key = 'session';

  const SessionModule();

  /// Get session if exists
  Session? get() {
    if (!_c.containsKey(key)) {
      return null;
    }

    return Session.fromJson(
      json.decode(
        _c.getString(key)!,
      ),
    );
  }

  /// Sets a new session
  void set(Session session) {
    _c.setString(key, json.encode(session.toJson()));
  }

  /// Wipe current session
  void remove() {
    _c.remove(key);
  }
}

/// Wrapper for SharedPreferences
class Storage {
  final session = const SessionModule();

  /// Set SharedPreferences instance
  Future<void> init() async {
    _c = await SharedPreferences.getInstance();
  }
}
