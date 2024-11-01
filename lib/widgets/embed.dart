import 'package:bluesky/atproto.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/models/embedwrapper.dart';
import 'package:lightbluesky/partials/dialogs/embed.dart';
import 'package:lightbluesky/partials/icontext.dart';

/// Embed widget, used on posts that contain embeded data
class Embed extends StatelessWidget {
  const Embed({super.key, required this.wrap, this.labels});

  final EmbedWrapper wrap;
  final List<Label>? labels;

  Widget _handleChild(BuildContext context) {
    Widget root;
    final widgets = wrap.getChildren(
      full: false,
      context: context,
    );
    switch (wrap.type) {
      case EmbedTypes.images:
        root = widgets.length == 1
            ? widgets[0]
            : GridView.count(
                shrinkWrap: true,
                // Disable scrolling photos
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: widgets.length == 1 ? 1 : 2,
                children: widgets,
              );
        break;
      default:
        root = widgets[0];
        break;
    }

    return root;
  }

  /// Setup censorship method for adult content
  Widget _handleRoot({required Widget child}) {
    var visibility =
        !api.adult ? ContentLabelVisibility.hide : ContentLabelVisibility.show;

    Widget root;
    String type = "unknown";

    if (labels != null && labels!.isNotEmpty) {
      int i = 0;
      bool finished = false;

      while (!finished && i < api.contentLabels.length) {
        final content = api.contentLabels[i];
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
    tap() {
      showDialog(
        context: context,
        builder: (_) => EmbedDialog(
          wrap: wrap,
        ),
      );
    }

    return InkWell(
      onTap: wrap.type != EmbedTypes.videos ? tap : null,
      onLongPress: wrap.type == EmbedTypes.videos ? tap : null,
      child: _handleRoot(
        child: _handleChild(context),
      ),
    );
  }
}
