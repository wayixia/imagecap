import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageUtils {
  static final Map<String, ui.Image> _imageCache = {};

  /// 从资源加载图片
  static Future<ui.Image> loadImageFromAsset(
    String assetPath, {
    bool cache = true,
  }) async {
    // 检查缓存
    if (cache && _imageCache.containsKey(assetPath)) {
      return _imageCache[assetPath]!;
    }

    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      if (cache) {
        _imageCache[assetPath] = image;
      }

      return image;
    } catch (e) {
      throw Exception('Failed to load image from asset: $assetPath, error: $e');
    }
  }

  /// 清除图片缓存
  static void clearCache() {
    _imageCache.clear();
  }

  /// 预加载多个图片
  static Future<List<ui.Image>> preloadImages(List<String> assetPaths) {
    return Future.wait(assetPaths.map((path) => loadImageFromAsset(path)));
  }
}


class ImagePainter extends CustomPainter {
  final ui.Image image;
  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}