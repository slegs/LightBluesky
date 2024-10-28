import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky/core.dart';
import 'package:bluesky_text/bluesky_text.dart';
import 'package:file_picker/file_picker.dart';
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
  static const maxChars = 300;
  final _controller = TextEditingController();
  int _length = 0;
  bool _posting = false;

  FileType? _fileType;
  final List<PlatformFile> _files = List.empty(
    growable: true,
  );

  bool get _isReply => widget.parent != null;

  /// Send post to Bluesky
  Future<void> _handlePublish() async {
    setState(() {
      _posting = true;
    });

    final text = BlueskyText(_controller.text);
    final facets = await text.entities.toFacets();

    try {
      bsky.Embed? embed;

      if (_files.isNotEmpty) {
        embed = await api.upload(_files, _fileType!);
      }

      await api.c.feed.post(
        text: text.value,
        reply: _isReply ? widget.parent!.record.reply : null,
        facets: facets.map(bsky.Facet.fromJson).toList(),
        embed: embed,
      );

      if (!mounted) return;
      Ui.snackbar(context, 'Post published!');
      Navigator.pop(context);
    } on XRPCException catch (e) {
      if (!mounted) return;
      Ui.snackbar(context, e.toString());
    }

    setState(() {
      _posting = false;
    });
  }

  /// Add file(s) to list
  Future<void> _handleFiles(FileType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: type == FileType.image,
    );

    // Add to list if there is at least one and there aren't > 4 total items
    if (!(result != null && _files.length + result.count <= 4)) {
      return;
    }

    setState(() {
      _fileType ??= type;
      _files.addAll(result.files);
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
                  _length = val.length;
                });
              },
              autofocus: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: !_isReply ? "What's on your mind?" : "Write a reply",
              ),
            ),
            if (_files.isNotEmpty)
              Text('Files chosen: ${_files.map((f) => f.name).join(', ')}'),
            if (!_posting)
              Row(
                children: [
                  // Max characters
                  Text(
                    '$_length / $maxChars',
                    style: _length > maxChars
                        ? const TextStyle(
                            color: Colors.red,
                          )
                        : null,
                  ),
                  // Add photo(s)
                  IconButton(
                    onPressed: _fileType == null || _fileType == FileType.image
                        ? () => _handleFiles(FileType.image)
                        : null,
                    icon: const Icon(Icons.add_a_photo),
                  ),
                  const Spacer(),
                  // Cancel button
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                  // Send button
                  TextButton.icon(
                    onPressed: _length <= maxChars ? _handlePublish : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                  ),
                ],
              ),
            // Loading bar
            if (_posting) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
