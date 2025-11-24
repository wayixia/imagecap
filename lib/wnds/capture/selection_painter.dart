
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';


class DrawingPoint {
  Offset offset;
  Color color;
  double strokeWidth;
  String tool;

  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
    required this.tool,
  });
}

class DrawingPath {
  List<DrawingPoint> points = [];
  Color color;
  double strokeWidth;
  String tool;

  DrawingPath({
    required this.color,
    required this.strokeWidth,
    required this.tool,
  });
}

// 自定义绘制选区
class SelectionPainter extends CustomPainter {
  final Rect? selectionRect;
  final bool isSelecting;
  final ui.Image? image;

  final List<DrawingPath> paths;
  final Offset? textPosition;
  final String? textContent;
  final Color textColor;
  final double controlPointSize;
  final DrawingPath? selectedPath;
  const SelectionPainter({
    required this.selectionRect,
    required this.isSelecting,
    required this.image,
    required this.paths,
    required this.selectedPath,
    this.textPosition,
    this.textContent,
    required this.textColor,
    this.controlPointSize = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectionRect == null) {
      return;
    }


    // 绘制选区矩形
    //canvas.drawRect(selectionRect!, paint);
    if( image != null ) {
      // final paint = Paint()
      // ..color = Colors.transparent
      // ..style = PaintingStyle.fill;
      canvas.drawImageRect(image!, selectionRect!, selectionRect!, Paint());
    }


    //canvas.drawImageRect(image!, selectionRect!, selectionRect!, paint);

    // 如果正在选择，绘制提示
    if (isSelecting) {
      _paintTips(canvas, size);
    } else {
      _paintPaths(canvas, size);
    }

    _paintTracker(canvas, size);
  }

  void _paintTips( Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '拖动选择区域',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.black54,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        selectionRect!.left,
        selectionRect!.top - 20,
      ),
    );
  }

  void _paintTracker( Canvas canvas, Size size) {
    // paint border and control points
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRect(selectionRect!.inflate(2), borderPaint);

    final controlPointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final points = [
      selectionRect!.topLeft,
      selectionRect!.topCenter,
      selectionRect!.topRight,
      selectionRect!.centerRight,
      selectionRect!.bottomRight,
      selectionRect!.bottomCenter,
      selectionRect!.bottomLeft,
      selectionRect!.centerLeft,
    ];

    for (final point in points) {
      canvas.drawRect(
        Rect.fromCenter(
          center: point,
          width: controlPointSize,
          height: controlPointSize,
        ),
        controlPointPaint,
      );
    }
  }


   void _paintPaths(Canvas canvas, Size size) {
    // 绘制所有路径
    for (var path in paths) {
      final paint = Paint()
        ..color = path.tool == 'highlighter' 
            ? path.color.withOpacity(0.3) 
            : path.color
        ..strokeWidth = path.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (path.tool == 'highlighter') {
        paint.blendMode = BlendMode.multiply;
      }

      if (path.points.isNotEmpty) {
        if (path.tool == 'pen' || path.tool == 'highlighter') {
          // 自由绘制
          for (int i = 0; i < path.points.length - 1; i++) {
            canvas.drawLine(
              path.points[i].offset,
              path.points[i + 1].offset,
              paint,
            );
          }
        } else if (path.tool == 'line' && path.points.length >= 2) {
          // 直线
          canvas.drawLine(path.points.first.offset, path.points.last.offset, paint);
        } else if (path.tool == 'rectangle' && path.points.length >= 2) {
          // 矩形
          final rect = Rect.fromPoints(path.points.first.offset, path.points.last.offset);
          canvas.drawRect(rect, paint);
        } else if (path.tool == 'ellipse' && path.points.length >= 2) {
          // 椭圆
          final rect = Rect.fromPoints(path.points.first.offset, path.points.last.offset);
          canvas.drawOval(rect, paint);
        } else if (path.tool == 'arrow' && path.points.length >= 2) {
          // 箭头
          _drawArrow(canvas, path.points.first.offset, path.points.last.offset, paint);
        }
      }
    }

    // 绘制文本
    if (textPosition != null && textContent != null && textContent!.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: textContent,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, textPosition!);
    }

    if(selectedPath != null) {
      // 绘制选中路径的边框
      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      Rect boundingRect;
      boundingRect = Rect.fromPoints(selectedPath!.points.first.offset, selectedPath!.points.last.offset);
      // for (var point in selectedPath!.points) {
      //   if (boundingRect == null) {
      //     boundingRect = Rect.fromLTWH(point.offset.dx, point.offset.dy, 0, 0);
      //   } else {
      //     boundingRect = boundingRect.expandToInclude(Rect.fromLTWH(point.offset.dx, point.offset.dy, 0, 0));
      //   }
      // }

      canvas.drawRect(boundingRect.inflate(selectedPath!.strokeWidth-1), borderPaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    // 绘制直线
    canvas.drawLine(start, end, paint);

    // 绘制箭头头部
    final angle = (end - start).direction;
    const arrowLength = 15.0;
    const arrowAngle = 0.5;

    final arrowEnd1 = end - Offset(
      arrowLength * cos(angle - arrowAngle),
      arrowLength * sin(angle - arrowAngle),
    );
    final arrowEnd2 = end - Offset(
      arrowLength * cos(angle + arrowAngle),
      arrowLength * sin(angle + arrowAngle),
    );

    canvas.drawLine(end, arrowEnd1, paint);
    canvas.drawLine(end, arrowEnd2, paint);
  }


  @override
  bool shouldRepaint(covariant SelectionPainter oldDelegate) {
    return true;
    //return oldDelegate.selectionRect != selectionRect ||
    //    oldDelegate.isSelecting != isSelecting || oldDelegate.paths != paths;
  }
}