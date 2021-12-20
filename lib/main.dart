import 'package:custom_video_player/player/custom_video_player.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
      MaterialApp(
        initialRoute: '/player',
        title: 'CustomPlayer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/player': (context) => const CustomVideoPlayer(),
        },
      )
  );
}
