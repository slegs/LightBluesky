import 'package:flutter/material.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/models/embedwrapper.dart';

/// Fullscreen embed item
class EmbedDialog extends StatelessWidget {
  const EmbedDialog({super.key, required this.wrap});

  final EmbedWrapper wrap;

  /// Pick root depending on embed type
  Widget _handleRoot() {
    final widgets = wrap.getChildren(
      full: true,
    );

    Widget root;
    switch (wrap.type) {
      case EmbedTypes.images:
        root = widgets.length == 1
            ? widgets[0]
            : PageView.builder(
                itemCount: widgets.length,
                pageSnapping: true,
                itemBuilder: (context, i) {
                  return widgets[i];
                },
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // TODO: Add download
                  Ui.snackbar(context, "Download under construction!");
                },
                icon: const Icon(Icons.download),
              ),
            ],
          ),
          Expanded(
            child: _handleRoot(),
          ),
        ],
      ),
    );
  }
}
