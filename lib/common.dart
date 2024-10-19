import 'package:bluesky/bluesky.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Initial value is anonymous
var api = Bluesky.anonymous();
late SharedPreferences prefs;
