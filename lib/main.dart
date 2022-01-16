import 'package:custom_video_player/player/custom_video_player.dart';
import 'package:flutter/material.dart';

import 'ui/my_web_view.dart';

void main() {
  runApp(
      MaterialApp(
        initialRoute: '/web',
        title: 'CustomPlayer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/player': (context) => const CustomVideoPlayer(),
          '/web': (context) => const MyWebView(),
        },
      )
  );
}
