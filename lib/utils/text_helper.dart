

import 'dart:math';

import 'package:flutter/material.dart';

class TextHelper {
  static int getLineCount( String text, double fontSize, double width) {
    if (text.isEmpty) {
      return 0;
    }

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    
    textPainter.layout(maxWidth: width);
    
    final newLineCount = textPainter.computeLineMetrics().length;

    return newLineCount;
  }

  static Rect measureString( String text, double fontSize, Point pt) {
    if (text.isEmpty) {
      return Rect.fromLTWH(0, 0, 0, 0);
    }

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    
    textPainter.layout();
    
    final size = textPainter.size;

    return Rect.fromLTWH(pt.x.toDouble(), pt.y.toDouble(), size.width, size.height);
  }

  static int GetActualHeight( String text, double fontSize, double width) {
    if (text.isEmpty) {
      return 0;
    }

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    
    textPainter.layout( maxWidth: width);
    
    final size = textPainter.size;

    return size.height.toInt();
  }
}