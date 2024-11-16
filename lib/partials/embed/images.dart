import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/customimage.dart';
import 'package:lightbluesky/partials/dialogs/embed.dart';

/// Embed for image(s), 1 to 4
class ImagesEmbed extends StatelessWidget {
  const ImagesEmbed({
    super.key,
    required this.root,
    required this.full,
    required this.open,
  });

  final UEmbedViewImages root;
  final bool full;
  final bool open;

  /// Get widgets for images
  List<Widget> _handleImages() {
    List<Widget> widgets = [];

    for (var img in root.data.images) {
      double? ratio;
      if (img.aspectRatio != null) {
        ratio = img.aspectRatio!.width / img.aspectRatio!.height;
      }

      final widget = CustomImage.normal(
        url: full ? img.fullsize : img.thumbnail,
        ratio: ratio,
        caching: false,
      );

      widgets.add(widget);
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final widgets = _handleImages();

    Widget base;

    if (root.data.images.length == 1) {
      base = widgets[0];
    } else if (full) {
      // Left-right scroll images
      base = PageView.builder(
        itemCount: widgets.length,
        pageSnapping: true,
        itemBuilder: (context, i) {
          return widgets[i];
        },
      );
    } else {
      // Images grid
      base = GridView.count(
        shrinkWrap: true,
        // Disable scrolling photos
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: widgets.length == 1 ? 1 : 2,
        children: widgets,
      );
    }

    return InkWell(
      onTap: open
          ? () {
              showDialog(
                context: context,
                builder: (_) => EmbedDialog(
                  item: root,
                ),
              );
            }
          : null,
      // Do not make grid if only one image
      child: base,
    );
  }
}
