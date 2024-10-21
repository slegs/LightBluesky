import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CustomPlayer extends StatefulWidget {
  const CustomPlayer({
    super.key,
    required this.cid,
    required this.playlist,
    required this.thumbnail,
    required this.aspectRatio,
  });

  final String cid;
  final String playlist;
  final String thumbnail;
  final Map<String, dynamic> aspectRatio;

  @override
  State<CustomPlayer> createState() => _CustomPlayerState();
}

class _CustomPlayerState extends State<CustomPlayer> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();

    player.open(
      Media(widget.playlist),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio['width'] / widget.aspectRatio['height'],
      child: Video(
        controller: controller,
        width: (widget.aspectRatio['width'] as int).toDouble(),
        height: (widget.aspectRatio['height'] as int).toDouble(),
      ),
    );
  }
}
