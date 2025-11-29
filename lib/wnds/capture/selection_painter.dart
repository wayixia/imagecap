
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';


// Hit-Test codes
enum TrackerHit
{
	hitNothing,
	hitTopLeft, 
  hitTopRight, 
  hitBottomRight, 
  hitBottomLeft,
	hitTopCenter, 
  hitRightCenter, 
  hitBottomCenter, 
  hitLeftCenter, 
  hitMiddleCenter,
  hitDrawObject,
  
  hitDrawRectangleTopLeft, 
  hitDrawRectangleTopRight, 
  hitDrawRectangleBottomRight, 
  hitDrawRectangleBottomLeft,
  hitDrawRectangleTopCenter, 
  hitDrawRectangleRightCenter, 
  hitDrawRectangleBottomCenter, 
  hitDrawRectangleLeftCenter, 

  hitDrawLineStart,  // line or arrow start point
  hitDrawLineEnd, // line or arrow end point
}

enum DrawElementTypeHit {
  hitDrawNone,
  hitDrawText,
  hitDrawLine,
  hitDrawRectangle,
  hitDrawCircle,
  hitDrawArrow,
  hitDrawPen
}


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

  Map<TrackerHit, Offset>? getTrackerPoints() {
    if( points.length < 2 ) {
      return null;
    }

    Rect trackRect = Rect.fromPoints(points.first.offset, points.last.offset);
    final Map< TrackerHit, Offset> tackerpoints;
      
    if( tool == "rectangle") {
      tackerpoints = {
        TrackerHit.hitDrawRectangleTopLeft : trackRect.topLeft,
        TrackerHit.hitDrawRectangleTopCenter :trackRect.topCenter,
        TrackerHit.hitDrawRectangleTopRight :trackRect.topRight,
        TrackerHit.hitDrawRectangleRightCenter :trackRect.centerRight,
        TrackerHit.hitDrawRectangleBottomRight :trackRect.bottomRight,
        TrackerHit.hitDrawRectangleBottomCenter :trackRect.bottomCenter,
        TrackerHit.hitDrawRectangleBottomLeft :trackRect.bottomLeft,
        TrackerHit.hitDrawRectangleLeftCenter :trackRect.centerLeft,
      };
    } else if( tool == "ellipse") {
      tackerpoints = {
        TrackerHit.hitDrawRectangleTopCenter: Offset(trackRect.center.dx, trackRect.top),
        TrackerHit.hitDrawRectangleRightCenter: Offset(trackRect.right, trackRect.center.dy),
        TrackerHit.hitDrawRectangleBottomCenter: Offset(trackRect.center.dx, trackRect.bottom),
        TrackerHit.hitDrawRectangleLeftCenter: Offset(trackRect.left, trackRect.center.dy),
      };
    } else if( tool =="line" || tool =="arrow") {
      tackerpoints = points.length >= 2 ? {
        TrackerHit.hitDrawLineStart: points.first.offset,
        TrackerHit.hitDrawLineEnd: points.last.offset,
       } : {
        TrackerHit.hitDrawLineStart: trackRect.topLeft,
        TrackerHit.hitDrawLineEnd: trackRect.bottomRight,
      };
    } else {
      return null;
    }
    
    return tackerpoints;
  }
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

    // 如果正在选择，绘制提示
    if (isSelecting) {
      _paintTips(canvas, size);
    } else {
      _paintPaths(canvas, size);
    }

    _paintTracker(canvas, size, selectionRect!, drawBorder: true, drawResize: paths.isEmpty);
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

  void _paintTracker( Canvas canvas, Size size, Rect trackRect, { 
      Color color=Colors.blue, 
      bool drawResize=true, 
      bool drawBorder = true, 
      String type="rectangle", 
      List<DrawingPoint>? linepoints } ) {
    // paint border and control points
    
    if( drawBorder ) {
      final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
      canvas.drawRect(trackRect, borderPaint);
    }

    if( drawResize ) {
      final controlPointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      final List points;
      
      if( type == "rectangle") {
        points = [
          trackRect.topLeft,
          trackRect.topCenter,
          trackRect.topRight,
          trackRect.centerRight,
          trackRect.bottomRight,
          trackRect.bottomCenter,
          trackRect.bottomLeft,
          trackRect.centerLeft,
        ];
      } else if( type == "ellipse") {
        points = [
          Offset(trackRect.center.dx, trackRect.top),
          Offset(trackRect.right, trackRect.center.dy),
          Offset(trackRect.center.dx, trackRect.bottom),
          Offset(trackRect.left, trackRect.center.dy),
        ];
      } else if(type=="line" || type=="arrow") {
        points = linepoints != null && linepoints.length >= 2 ? [
          linepoints.first.offset,
          linepoints.last.offset,
        ] : [
          trackRect.topLeft,
          trackRect.bottomRight,
        ];
      } else {
        return;
      }

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
      Rect boundingRect;
      boundingRect = Rect.fromPoints(selectedPath!.points.first.offset, selectedPath!.points.last.offset);
      _paintTracker(canvas, size, boundingRect, 
        color: Colors.brown, 
        drawResize: true, 
        drawBorder: false, 
        type: selectedPath!.tool,
        linepoints: selectedPath!.points,);
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