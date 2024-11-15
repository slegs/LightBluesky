import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/widgets/embed.dart';

/// Fullscreen embed item
class EmbedDialog extends StatelessWidget {
  const EmbedDialog({super.key, required this.item});

  final EmbedView item;

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
            child: EmbedRoot(
              item: item,
              full: true,
              open: false,
            ),
          ),
        ],
      ),
    );
  }
}
