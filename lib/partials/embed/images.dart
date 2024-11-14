import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/partials/customimage.dart';
import 'package:lightbluesky/partials/dialogs/embed.dart';

/// Embed for image(s), 1 to 4
class ImagesEmbed extends StatelessWidget {
  const ImagesEmbed({
    super.key,
    required this.root,
    required this.full,
  });

  final UEmbedViewImages root;
  final bool full;

  /// Get widgets for images
  List<Widget> _handleImages() {
    List<Widget> widgets = [];

    for (var img in root.data.images) {
      final widget = Padding(
        padding: const EdgeInsets.all(5.0),
        child: CustomImage(
          full ? img.fullsize : img.thumbnail,
        ),
      );

      widgets.add(widget);
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final widgets = _handleImages();
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => EmbedDialog(
            item: root,
          ),
        );
      },
      // Do not make grid if only one image
      child: root.data.images.length == 1
          ? widgets[0]
          : GridView.count(
              shrinkWrap: true,
              // Disable scrolling photos
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: widgets.length == 1 ? 1 : 2,
              children: widgets,
            ),
    );
  }
}
