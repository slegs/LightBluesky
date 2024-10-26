import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:bluesky_text/bluesky_text.dart';
import 'package:flutter/material.dart';
import 'package:lightbluesky/common.dart';
import 'package:lightbluesky/helpers/ui.dart';
import 'package:lightbluesky/widgets/postitem.dart';

class PublishDialog extends StatefulWidget {
  const PublishDialog({super.key, this.parent});

  final bsky.Post? parent;

  @override
  State<PublishDialog> createState() => _PublishDialogState();
}

class _PublishDialogState extends State<PublishDialog> {
  final _controller = TextEditingController();
  static const maxChars = 300;
  int length = 0;
  bool _loading = false;

  bool get _isReply => widget.parent != null;

  Future<void> _handlePublish() async {
    setState(() {
      _loading = true;
    });

    final text = BlueskyText(_controller.text);
    final facets = await text.entities.toFacets();
    try {
      await api.feed.post(
        text: text.value,
        reply: _isReply ? widget.parent!.record.reply : null,
        facets: facets.map(bsky.Facet.fromJson).toList(),
      );

      if (!mounted) return;
      Ui.snackbar(context, 'Post published!');
      Navigator.pop(context);
    } on XRPCException catch (e) {
      if (!mounted) return;
      Ui.snackbar(context, e.toString());
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isReply) ...[
              PostItem(
                item: widget.parent!,
                basic: true,
              ),
              const Divider(),
            ],
            TextField(
              controller: _controller,
              onChanged: (val) {
                setState(() {
                  length = val.length;
                });
              },
              autofocus: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: !_isReply ? "What's on your mind?" : "Write a reply",
              ),
            ),
            if (!_loading)
              Row(
                children: [
                  Text(
                    '$length / $maxChars',
                    style: length > maxChars
                        ? const TextStyle(
                            color: Colors.red,
                          )
                        : null,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                  TextButton.icon(
                    onPressed: length <= maxChars ? _handlePublish : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                  ),
                ],
              ),
            if (_loading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
