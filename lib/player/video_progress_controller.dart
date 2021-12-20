import 'package:custom_video_player/res/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

import 'linear_circle_progress_indicator.dart';

class VideoProgressController extends StatefulWidget {

  const VideoProgressController(
      this.controller, {
        Key? key,
        this.colors = const CustomVideoProgressColors(),
        required this.allowScrubbing,
      }) : super(key: key);

  final VideoPlayerController controller;
  final CustomVideoProgressColors colors;
  final bool allowScrubbing;

  @override
  _VideoProgressControllerState createState() => _VideoProgressControllerState();
}

class _VideoProgressControllerState extends State<VideoProgressController> {
  _VideoProgressControllerState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  late VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  CustomVideoProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.isInitialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = LinearCircleProgressIndicator(
        value: position / duration,
        color: colors.playedColor,
        backgroundColor: CustomColors.video_player_seekbar_bg_color,
        pointerColor: CustomColors.video_player_seekbar_point_color,
        minHeight: 20,
      );
    } else {
      progressIndicator = LinearCircleProgressIndicator(
        value: null,
        color: colors.playedColor,
        pointerColor: colors.playedColor,
        // valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
        minHeight: 20,
      );
    }
    if (widget.allowScrubbing) {
      return _VideoScrubber(
        child: progressIndicator,
        controller: controller,
      );
    } else {
      return progressIndicator;
    }
  }
}

class CustomVideoProgressColors {
  const CustomVideoProgressColors({
    this.playedColor = CustomColors.video_player_seekbar_color,
    this.bufferedColor = const Color.fromRGBO(50, 50, 200, 0.2),
    this.backgroundColor = CustomColors.video_player_seekbar_bg_color,
  });

  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;
}

class _VideoScrubber extends StatefulWidget {
  const _VideoScrubber({
    required this.child,
    required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying &&
            controller.value.position != controller.value.duration) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}