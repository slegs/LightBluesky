import 'package:flutter/material.dart';
import 'package:lightbluesky/enums/embedtypes.dart';

class EmbedWrapper {
  final List<Widget> widgets;
  final EmbedTypes type;

  const EmbedWrapper({required this.widgets, required this.type});
}
