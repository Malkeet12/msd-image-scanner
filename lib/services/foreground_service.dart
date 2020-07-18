import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForegroundService {
  static const platform = const MethodChannel('nativeToFlutter');
  static const methodChannel = MethodChannel("flutterToNative");
  static var callBackDispacther = new Map();

  static start(method, data) async {
    if (Platform.isAndroid) {
      var res = await methodChannel.invokeMethod(method, data);
      return res;
    }
  }

  static stop() async {
    if (Platform.isAndroid) {
      await methodChannel.invokeMethod("stop");
    }
  }

  static registerCallBack(event, cb) {
    if (Platform.isAndroid) {
      callBackDispacther[event] = cb;
      if (callBackDispacther.isNotEmpty)
        platform.setMethodCallHandler(_handleMethod);
    }
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    await callBackDispacther[call.method](call.arguments);
  }
}
