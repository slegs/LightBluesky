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
    required this.open,
    this.media,
  });

  final UEmbedViewRecord root;
  final EmbedViewMedia? media;
  final bool open;

  @override
  Widget build(BuildContext context) {
    Widget widget;

    EmbedView? typedMedia;
    if (media != null) {
      if (media is UEmbedViewMediaImages) {
        typedMedia = EmbedView.images(
          data: (media as UEmbedViewMediaImages).data,
        );
      } else if (media is UEmbedViewMediaVideo) {
        typedMedia = EmbedView.video(
          data: (media as UEmbedViewMediaVideo).data,
        );
      } else if (media is UEmbedViewMediaExternal) {
        typedMedia = EmbedView.external(
          data: (media as UEmbedViewMediaExternal).data,
        );
      } else if (media is UEmbedViewMediaUnknown) {
        typedMedia = EmbedView.unknown(
          data: (media as UEmbedViewMediaUnknown).data,
        );
      }
    }

    if (root.data.record is UEmbedViewRecordViewRecord) {
      widget = QuoteRecordEmbed(
        record: root.data.record as UEmbedViewRecordViewRecord,
        media: typedMedia,
        open: open,
      );
    } else if (root.data.record is UEmbedViewRecordViewNotFound) {
      widget = QuoteRecordEmbed(
        record: null,
        media: typedMedia,
        open: open,
      );
    } else if (root.data.record is UEmbedViewRecordViewGeneratorView) {
      widget = GeneratorRecordEmbed(
        root: root.data.record as UEmbedViewRecordViewGeneratorView,
        media: typedMedia,
        open: open,
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
