import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/models/embedwrapper.dart';
import 'package:lightbluesky/enums/embedtypes.dart';

class EmbedPage extends StatelessWidget {
  EmbedPage({super.key, required this.wrap});

  final EmbedWrapper wrap;

  final _controller = PageController();

  Widget _handleRoot() {
    Widget root;
    switch (wrap.type) {
      case EmbedTypes.images:
        root = wrap.widgets.length == 1
            ? wrap.widgets[0]
            : PageView.builder(
                itemCount: wrap.widgets.length,
                pageSnapping: true,
                controller: _controller,
                itemBuilder: (context, i) {
                  return wrap.widgets[i];
                },
              );
        break;
      case EmbedTypes.videos:
        // TODO: Add video support
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
              Ui.snackbar(context, "TODO: Add download");
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
