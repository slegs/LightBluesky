import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:flutter/material.dart';

class CustomTab {
  final String name;
  final Future<XRPCResponse<bsky.Feed>> Function({
    String? cursor,
  }) func;
  final Icon? icon;

  const CustomTab({
    required this.name,
    required this.func,
    this.icon,
  });
}
