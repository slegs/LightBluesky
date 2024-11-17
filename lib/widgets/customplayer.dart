import 'package:flutter/material.dart';
import 'package:lightbluesky/helpers/customimage.dart';
import 'package:video_player/video_player.dart';

/// Player wrapper, uses `video_player` with custom controls
class CustomPlayer extends StatefulWidget {
  const CustomPlayer({
    super.key,
    required this.playlist,
    this.thumb,
    this.ratio,
  });

  final String playlist;
  final String? thumb;
  final double? ratio;

  @override
  State<CustomPlayer> createState() => _CustomPlayerState();
}

class _CustomPlayerState extends State<CustomPlayer> {
  late final VideoPlayerController _controller;

  bool _showControls = false;

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.playlist),
    )..initialize().then((_) {
        _controller.setLooping(true);
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _handlePlaceholder() {
    return [
      if (widget.thumb != null)
        CustomImage.normal(
          url: widget.thumb!,
          caching: false,
          fit: BoxFit.fill,
        ),
      const CircularProgressIndicator(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.ratio ?? _controller.value.aspectRatio,
      child: InkWell(
        onTap: () {
          setState(() {
            _showControls = true;
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showControls = false;
                });
              }
            });
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_controller.value.isInitialized) VideoPlayer(_controller),
            if (_showControls && _controller.value.isInitialized)
              CircleAvatar(
                child: IconButton(
                  onPressed: _togglePlay,
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
              ),
            if (!_controller.value.isInitialized) ..._handlePlaceholder(),
          ],
        ),
      ),
    );
  }
}
