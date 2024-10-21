import 'package:flutter/material.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/models/embedwrapper.dart';
import 'package:lightbluesky/pages/embed.dart';

/// Embed widget, used on posts that contain embeded data
class Embed extends StatelessWidget {
  const Embed({super.key, required this.wrap});

  final EmbedWrapper wrap;

  Widget _handleRoot() {
    Widget root;
    switch (wrap.type) {
      case EmbedTypes.images:
        root = wrap.widgets.length == 1
            ? wrap.widgets[0]
            : GridView.count(
                shrinkWrap: true,
                // Disable scrolling photos
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: wrap.widgets.length == 1 ? 1 : 2,
                children: wrap.widgets,
              );
        break;
      case EmbedTypes.videos:
        root = wrap.widgets[0];
        break;
      case EmbedTypes.unsupported:
        root = wrap.widgets[0];
        break;
    }

    return root;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Ui.nav(context, EmbedPage(wrap: wrap));
      },
      child: _handleRoot(),
    );
  }
}
