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

  Widget _handleRoot({required Widget child}) {
    var visibility = ContentLabelVisibility.show;

    Widget root;

    int i = 0;
    bool finished = false;

    if (labels != null) {
      while (!finished && i < labels!.length) {
        final label = labels![i];

        int j = 0;
        while (!finished && j < api.contentLabels.length) {
          final filter = api.contentLabels[j];
          if (label.value == filter.label) {
            visibility = filter.visibility;
            finished = true;
          }
          j++;
        }
        i++;
      }
    }

    switch (visibility) {
      case ContentLabelVisibility.hide:
        root = const IconText(icon: Icons.warning, text: 'Adult content');
        break;
      case ContentLabelVisibility.warn:
        root = ExpansionTile(
          leading: const Icon(Icons.warning),
          title: const Text("Adult content"),
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
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => EmbedDialog(
            wrap: wrap,
          ),
        );
      },
      child: _handleRoot(
        child: _handleChild(context),
      ),
    );
  }
}
