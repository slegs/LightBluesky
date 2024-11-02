import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';

/// Tab wrapper
class CustomTab {
  /// Name
  final String name;

  /// Function to execute when loading data
  final Future<XRPCResponse<bsky.Feed>> Function({
    String? cursor,
  }) func;

  /// Optional icon for tab bar
  final Icon? icon;

  const CustomTab({
    required this.name,
    required this.func,
    this.icon,
  });
}
