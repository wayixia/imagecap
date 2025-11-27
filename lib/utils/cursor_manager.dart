import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CursorManager {
  // 1. 创建一个平台通道，确保通道名称与原生端一致
  static const _channel = MethodChannel('com.imagecap.app/cursor');

  // 2. 定义一个方法来触发原生光标改变
  static Future<void> setCrosshairCursor() async {
    try {
      await _channel.invokeMethod('setCrosshairCursor');
    } on PlatformException catch (e) {
      debugPrint("Failed to set cursor: '${e.message}'.");
    }
  }

  static Future<void> resetCursor() async {
    try {
      await _channel.invokeMethod('resetCursor');
    } on PlatformException catch (e) {
      debugPrint("Failed to reset cursor: '${e.message}'.");
    }
  }

  static Future<void> setSystemCursor(String cursorKey) async {
    try {
      await _channel.invokeMethod('setCustomCursor', {'cursorKey': cursorKey});
    } on PlatformException catch (e) {
      debugPrint("Failed to set custom cursor: '${e.message}'.");
    }
  }
}


class CustomSystemCursor extends MouseCursor {
  final String? key;
  const CustomSystemCursor({this.key})
      : assert((key != null && key != ""));

  @override
  MouseCursorSession createSession(int device) =>
      _CustomCursorSession(this, device);

  @override
  String get debugDescription =>
      objectRuntimeType(this, 'CustomMemoryImageCursor');
}

class _CustomCursorSession extends MouseCursorSession {
  _CustomCursorSession(
      CustomSystemCursor super.cursor, super.device);

  @override
  CustomSystemCursor get cursor =>
      super.cursor as CustomSystemCursor;

  @override
  Future<void> activate() async {
    await CursorManager.setSystemCursor(cursor.key.toString());
  }

  @override
  void dispose() {}
}
