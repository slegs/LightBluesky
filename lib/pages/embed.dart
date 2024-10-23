import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/enums/embedtypes.dart';
import 'package:lightbluesky/models/embedwrapper.dart';

class EmbedPage extends StatelessWidget {
  const EmbedPage({super.key, required this.wrap});

  final EmbedWrapper wrap;

  Widget _handleRoot() {
    final widgets = wrap.getChildren(full: true);

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Ui.snackbar(context, 'TODO: Add download');
            },
            icon: const Icon(Icons.download),
          )
        ],
      ),
      body: Center(
        child: _handleRoot(),
      ),
    );
  }
}
