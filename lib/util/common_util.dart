import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_scanner/util/constants.dart';

class CommonUtil {
  static Future<Size> getImageSize(Image image) {
    Completer<Size> completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener(
        (ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()))));
    return completer.future;
  }

  static getRandomNumber(maxNumber) {
    var rng = new Random();
    var uid = rng.nextInt(pow(maxNumber, 1));
    return uid;
  }

  static getRandomColor() {
    var colors = Constants.MY_COLORS;
    var uid = CommonUtil.getRandomNumber(5);
    return colors[uid];
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(2)) + ' ' + suffixes[i];
  }
}
