import 'package:custom_video_player/res/custom_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class VideoTimeText extends StatefulWidget {

  final VideoPlayerController controller;
  final double height;

  const VideoTimeText(this.controller, {Key? key, required this.height,}) : super(key: key);

  @override
  _VideoTimeTextState createState() => _VideoTimeTextState();
}

class _VideoTimeTextState extends State<VideoTimeText> {

  late VoidCallback listener;
  VideoPlayerController get controller => widget.controller;

  _VideoTimeTextState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

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
    if (controller.value.isInitialized) {
      int current = controller.value.position.inSeconds;
      int duration = controller.value.duration.inSeconds;
      String currentTime = getTimeString(current);
      String totalTime = getTimeString(duration);
      return SizedBox(
        height: widget.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(currentTime,
              style: const TextStyle(
                color: CustomColors.video_player_current_text_color,
                fontSize: 21,
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(' / $totalTime',
              style: const TextStyle(
                color: CustomColors.video_player_total_text_color,
                fontSize: 21,
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  String getTimeString(int duration) {
    var format = NumberFormat('00');
    var minute = format.format((duration / 60).floor());
    var second = format.format(duration % 60);
    return '$minute:$second';
  }
}