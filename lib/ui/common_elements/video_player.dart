import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String path;
  final bool isFile;
  final Function(bool) onMute;
  final bool crop;

  VideoPlayerWidget({this.path, this.isFile, this.onMute, this.crop});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  bool _isMute;
  bool _crop;

  @override
  void initState() {
    super.initState();
    _isMute = true;
    if (widget.isFile)
      _controller = VideoPlayerController.file(File(widget.path));
    else
      // _controller = VideoPlayerController.network(widget.path);
      _controller = VideoPlayerController.asset(widget.path);
    _initializeVideoPlayerFuture = _controller.initialize();

    _crop = widget.crop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _controller.setVolume(0);
          _controller.setLooping(true);
          _controller.play();
          return GestureDetector(
            onTap: () {
              if (_isMute)
                _controller.setVolume(1);
              else
                _controller.setVolume(0);
              _isMute = !_isMute;
              widget.onMute(_isMute);
            },
            child: (_crop)
                ? ClipRect(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      child: Wrap(
                        children: [
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ],
                      ),
                    ),
                  )
                : AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
          );
        } else
          return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
