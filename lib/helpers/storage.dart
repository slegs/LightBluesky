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
}

/// Hashtag(s) module for Storage
class HashtagModule {
  static const String key = 'hashtags';

  const HashtagModule();

  /// Get all hashtags
  List<String> get() {
    return _c.getStringList(key) ?? [];
  }

  /// Add a new hashtag
  void add(String value) {
    final tags = get();

    tags.add(value);

    _c.setStringList(key, tags);
  }

  /// Remove a hashtag using its value or index
  void remove({String? value, int? index}) {
    if (value == null && index == null) {
      throw ArgumentError("Value or index should be set");
    }

    final tags = get();

    if (index != null) {
      tags.removeAt(index);
    } else if (value != null) {
      tags.remove(value);
    }

    _c.setStringList(key, tags);
  }
}

/// Wrapper for SharedPreferences
class Storage {
  final session = const SessionModule();
  final hashtags = const HashtagModule();

  /// Set SharedPreferences instance
  Future<void> init() async {
    _c = await SharedPreferences.getInstance();
  }
}
