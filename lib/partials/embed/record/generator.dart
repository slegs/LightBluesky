import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';

class GeneratorRecordEmbed extends StatelessWidget {
  const GeneratorRecordEmbed({
    super.key,
    required this.root,
  });

  final bsky.UEmbedViewRecordViewGeneratorView root;
  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: InkWell(
        onTap: () {
          Ui.snackbar(context, "TODO: Add feed support");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: root.data.avatar != null
                    ? Image.network(root.data.avatar!).image
                    : null,
              ),
              title: Text(root.data.displayName),
              subtitle: root.data.description != null
                  ? Text(root.data.description!)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
