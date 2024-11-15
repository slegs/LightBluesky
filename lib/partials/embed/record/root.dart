import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/partials/embed/record/generator.dart';
import 'package:lightbluesky/partials/embed/record/quote.dart';
import 'package:lightbluesky/partials/icontext.dart';

/// Embed for record
///
/// Supported:
/// - Quotes
/// - Generator feeds
class RecordEmbed extends StatelessWidget {
  const RecordEmbed({
    super.key,
    required this.root,
  });

  final UEmbedViewRecord root;

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (root.data.record is UEmbedViewRecordViewRecord) {
      widget = QuoteRecordEmbed(
        record: root.data.record as UEmbedViewRecordViewRecord,
      );
    } else if (root.data.record is UEmbedViewRecordViewNotFound) {
      widget = const QuoteRecordEmbed(
        record: null,
      );
    } else if (root.data.record is UEmbedViewRecordViewGeneratorView) {
      widget = GeneratorRecordEmbed(
        root: root.data.record as UEmbedViewRecordViewGeneratorView,
      );
    } else {
      widget = const IconText(
        icon: Icons.warning,
        text: "Record embed type not supported! :(",
      );
    }

    return widget;
  }
}
