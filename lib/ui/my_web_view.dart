import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWebView extends StatefulWidget {
  const MyWebView({Key? key}) : super(key: key);

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late InAppWebViewController _webViewController;
  Logger logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2,
        // number of method calls to be displayed
        errorMethodCount: 8,
        // number of method calls if stacktrace is provided
        lineLength: 120,
        // width of the output
        colors: true,
        // Colorful log messages
        printTime: true // Should each log print contain a timestamp
        ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          child: InAppWebView(
            initialOptions: InAppWebViewGroupOptions(),
            onLoadError:
                (InAppWebViewController a, Uri? b, int err, String msg) {
              logger.e('error: $err, msg: $msg');
            },
            onWebViewCreated: (controller) {
              _webViewController = controller;
              _webViewController.loadFile(assetFilePath: 'html/test.html');
              controller.addJavaScriptHandler(
                handlerName: 'getSettings',
                callback: (args) async {
                  return await _getSettings();
                },
              );
              controller.addJavaScriptHandler(
                  handlerName: 'sendSettings',
                  callback: (args) async {
                    var settingData = args[0];
                    logger.i(settingData);
                    return await _setSettings(settingData);
                  });
              controller.addJavaScriptHandler(
                handlerName: 'sendImages',
                callback: (args) async {
                  var name = args[0]['FILE_LIST'][0]['FILE_NAME'];
                  var image = args[0]['FILE_LIST'][0]['IMAGE'].split(',')[1];
                  Uint8List bytes = base64.decode(image);
                  String dir = (await getApplicationDocumentsDirectory()).path;
                  File file = File("$dir/" + name);
                  await file.writeAsBytes(bytes);

                  showDialog(
                    context: context,
                    builder: (context) {
                      return Material(
                        type: MaterialType.transparency,
                        child: AlertDialog(
                          title: const Center(
                            child: Text('이미지 확인용'),
                          ),
                          content: Container(
                            width: 300,
                            height: 300,
                            child: Center(child: Image.file(file)),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            onLoadStart: (controller, url) {},
            onLoadStop: (controller, url) async {},
            onProgressChanged:
                (InAppWebViewController controller, int progress) {
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  Future<Map<String, String>> _getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var bgm = (prefs.getString('bgm') ?? '1');
    var sfx = (prefs.getString('sfx') ?? '1');
    var timetype = (prefs.getString('timetype') ?? '0');

    var result = {
      'bgm': bgm,
      'sfx': sfx,
      'timetype': timetype,
    };

    logger.i(result);

    return result;
  }

  _setSettings(Map<String, dynamic> data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('bgm', data['bgm']);
      await prefs.setString('sfx', data['sfx']);
      await prefs.setString('timetype', data['timetype']);
      return true;
    } catch (error) {
      return false;
    }
  }
}
