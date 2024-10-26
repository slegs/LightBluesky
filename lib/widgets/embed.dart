import 'package:flutter/material.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/models/embedwrapper.dart';
import 'package:lightbluesky/partials/dialogs/embed.dart';

/// Embed widget, used on posts that contain embeded data
class Embed extends StatelessWidget {
  const Embed({super.key, required this.wrap});

  final EmbedWrapper wrap;

  Widget _handleRoot(BuildContext context) {
    Widget root;
    final widgets = wrap.getChildren(full: false, context: context);
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
      child: _handleRoot(context),
    );
  }
}
