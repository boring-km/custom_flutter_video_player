import 'dart:async';
import 'dart:io';

import 'package:custom_video_player/res/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../system_config.dart';
import 'video_progress_controller.dart';
import 'video_time_text.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({Key? key}) : super(key: key);

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  final playImage = 'images/viewer_01_ic_play_m.png';
  final pauseImage = 'images/viewer_01_ic_pause_m.png';
  var currentImage = 'images/viewer_01_ic_play_m.png';
  final testUrl = 'https://www.rmp-streaming.com/media/big-buck-bunny-360p.mp4';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = VideoPlayerController.network(
      testUrl,
    );

    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemConfig.setScreenConfig();
    return Scaffold(
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      height: 90,
                      color: CustomColors.video_player_bottom_bg_color,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // 영상이 재생 중이라면, 일시 중지 시킵니다.
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                  currentImage = playImage;
                                } else {
                                  // 만약 영상이 일시 중지 상태였다면, 재생합니다.
                                  _controller.play();
                                  currentImage = pauseImage;
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24.0),
                              child: Image.asset(currentImage),
                            ),
                          ),
                          const SizedBox(width: 16,),
                          VideoTimeText(_controller, height: 90,),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 1280,
                  height: 710,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(
                      children: [
                        VideoPlayer(_controller),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VideoProgressController(_controller, allowScrubbing: true),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 24.0,),
                    child: GestureDetector(
                      onTap: () {
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else {
                          exit(0);
                        }
                      },
                      child: Image.asset('images/viewer_01_ic_arrow_back.png'),
                    ),
                  ),
                )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
