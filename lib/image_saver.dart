import 'dart:async';

import 'package:flutter/services.dart';
import 'package:image_saver/files.dart';

class ImageSaver {
  static const MethodChannel _channel = const MethodChannel('image_saver');
  static const String methodSaveImage = 'saveImage';
  static const String pleaseProvidePath = 'Please provide valid file path.';
  static const String fileIsNotVideo = 'File on path is not a video.';
  static const String fileIsNotImage = 'File on path is not an image.';
  static const String fileIsNotLocal = 'File on path is not in local.';
  static const String methodSaveVideo = 'saveVideo';

  static Future<bool> saveImage(String path, {String albumName}) async {
    if (path == null || path.isEmpty) {
      throw ArgumentError(pleaseProvidePath);
    }

    if (!isImage(path)) {
      throw ArgumentError(fileIsNotVideo);
    }

    bool result = await _channel.invokeMethod(
      methodSaveImage,
      <String, dynamic>{'path': path, 'albumName': albumName},
    );

    return result;
  }

  static Future<bool> saveVideo(String path, {String albumName}) async {
    if (path == null || path.isEmpty) {
      throw ArgumentError(pleaseProvidePath);
    }

    if (!isImage(path)) {
      throw ArgumentError(fileIsNotImage);
    }

    if (!isLocalFilePath(path)) {
      throw ArgumentError(fileIsNotImage);
    }

    bool result = await _channel.invokeMethod(
      methodSaveImage,
      <String, dynamic>{'path': path, 'albumName': albumName},
    );

    return result;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
