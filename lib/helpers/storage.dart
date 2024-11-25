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

class BookmarkModule {
  static const String key = 'saved';

  const BookmarkModule();

  /// Get all saved posts
  List<String> get() {
    if (!_c.containsKey(key)) {
      return [];
    }

    return _c.getStringList(key)!;
  }

  bool has(String uri) {
    if (!_c.containsKey(key)) {
      return false;
    }

    return _c.getStringList(key)!.contains(uri);
  }

  /// Add a new post
  void add(String uri) {
    _c.setStringList(key, [
      ...get(),
      uri,
    ]);
  }

  /// Removes a post
  void remove({String? uri, int? pos}) {
    if (uri == null && pos == null) {
      throw ArgumentError.notNull("Id and pos");
    }

    final posts = get();

    if (uri != null) {
      posts.remove(uri);
    } else if (pos != null) {
      posts.removeAt(pos);
    }

    _c.setStringList(key, posts);
  }

  /// Remove all posts
  void clear() {
    _c.remove(key);
  }
}

/// Wrapper for SharedPreferences
class Storage {
  final session = const SessionModule();
  final bookmark = const BookmarkModule();

  /// Set SharedPreferences instance
  Future<void> init() async {
    _c = await SharedPreferences.getInstance();
  }
}
