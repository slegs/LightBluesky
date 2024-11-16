import 'package:bluesky/atproto.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/partials/embed/record/root.dart';
import 'package:lightbluesky/partials/icontext.dart';
import 'package:lightbluesky/partials/embed/external.dart';
import 'package:lightbluesky/partials/embed/images.dart';
import 'package:lightbluesky/partials/embed/video.dart';

/// Root embed widget
class EmbedRoot extends StatelessWidget {
  const EmbedRoot({
    super.key,
    required this.item,
    this.labels,
    this.full = false,
    this.open = true,
  });

  /// Embed root
  final EmbedView item;

  /// Linked post labels
  final List<Label>? labels;

  /// IMAGES ONLY: Use fullsized or thumbnail
  final bool full;

  /// Allows tapping
  final bool open;

  /// Setup censorship method for adult content
  Widget _handleAdult({required Widget child}) {
    var visibility =
        !api.adult ? ContentLabelVisibility.hide : ContentLabelVisibility.show;

    Widget root;
    String type = "unknown";

    if (labels != null && labels!.isNotEmpty) {
      int i = 0;
      bool finished = false;

      while (!finished && i < api.labels.length) {
        final content = api.labels[i];
        int j = 0;
        while (!finished && j < labels!.length) {
          final label = labels![j];
          if (content.label == label.value) {
            visibility = content.visibility;
            type = content.label;
            finished = true;
          }

          j++;
        }

        i++;
      }
    }

    switch (visibility) {
      case ContentLabelVisibility.hide:
        root = const IconText(
          icon: Icons.warning,
          text: 'Adult content',
        );
        break;
      case ContentLabelVisibility.warn:
        root = ExpansionTile(
          leading: const Icon(Icons.warning),
          title: const Text("Adult content"),
          subtitle: Text('Type: $type'),
          children: [
            child,
          ],
        );
        break;
      default:
        root = child;
    }

    return root;
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;

    // Pick specific widget for embed type
    if (item is UEmbedViewImages) {
      widget = ImagesEmbed(
        root: item as UEmbedViewImages,
        full: full,
        open: open,
      );
    } else if (item is UEmbedViewVideo) {
      widget = VideoEmbed(
        root: item as UEmbedViewVideo,
        open: open,
      );
    } else if (item is UEmbedViewExternal) {
      widget = ExternalEmbed(
        root: item as UEmbedViewExternal,
        open: open,
      );
    } else if (item is UEmbedViewRecord) {
      widget = RecordEmbed(
        root: item as UEmbedViewRecord,
        open: open,
      );
    } else if (item is UEmbedViewRecordWithMedia) {
      final data = (item as UEmbedViewRecordWithMedia).data;
      widget = RecordEmbed(
        root: UEmbedViewRecord(
          data: data.record,
        ),
        media: data.media,
        open: open,
      );
    } else {
      widget = const IconText(
        icon: Icons.warning,
        text: "Unsupported embed :(",
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: _handleAdult(child: widget),
    );
  }
}
