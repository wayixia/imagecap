
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:imagecap/wnds/capture/toolbar.dart';
//import 'package:imagecap/wnds/screenshot_editor.dart';
import 'package:imagecap/utils/cursor_manager.dart';
import 'package:imagecap/utils/image_utils.dart';
import 'package:window_manager/window_manager.dart';
//import 'package:window_manager/window_manager.dart';



class CaptureWndApp extends StatelessWidget {
  const CaptureWndApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      //home: RectangleSelectionDemo()
      //home: ScreenshotEditor(),
      debugShowCheckedModeBanner: false,
      home: ImageSelectionScreen()
    );
  }
}

enum SelectionMode {
  none,
  selecting,
  moving,
  resizing,
}

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
  hitMiddleCenter
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
}

class ImageSelectionScreen extends StatefulWidget {
  const ImageSelectionScreen({super.key});

  @override
  State<ImageSelectionScreen> createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final TransformationController _transformationController =
      TransformationController();
  
  // 选区相关状态
  Rect? _selectionRect;
  Offset? _startPoint;
  bool _isSelecting = false;
  MouseCursor _cursor = SystemMouseCursors.basic;
  TrackerHit _currentHit = TrackerHit.hitNothing;
  ui.Image? _image;
  bool _showToolbar = false;
  Offset _toolbarPosition = Offset.zero;

  // 绘图相关状态
  List<DrawingPath> _paths = [];
  List<DrawingPath> _redoPaths = [];
  Color _selectedColor = Colors.red;
  double strokeWidth = 3.0;
  bool isDrawing = false;
  Offset? currentOffset;
  TextEditingController? _textController;
  Offset? _textPosition;
  bool _showTextInput = false;
  String _selectedTool = "";



  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final image = await ImageUtils.loadImageFromAsset('assets/images/capture.png');
      setState(() {
        _image = image;
      });
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
              children: _image != null ? _imageTrackview():[Text("Loading Image...")],
            ),
    );
  }


  bool _isDrawMode()
  {
    return ( _selectedTool != "" );
  }

  DrawElementTypeHit _drawElementHitTest(Offset point) {
    return DrawElementTypeHit.hitDrawNone;
  }

  TrackerHit _trackerHitTest(Offset point) {
    if (_selectionRect == null) {
      return TrackerHit.hitNothing;
    }

    const controlPointSize = 18.0;
    final points = {
      TrackerHit.hitTopLeft: _selectionRect!.topLeft,
      TrackerHit.hitTopCenter: _selectionRect!.topCenter,
      TrackerHit.hitTopRight: _selectionRect!.topRight,
      TrackerHit.hitRightCenter: _selectionRect!.centerRight,
      TrackerHit.hitBottomRight: _selectionRect!.bottomRight,
      TrackerHit.hitBottomCenter: _selectionRect!.bottomCenter,
      TrackerHit.hitBottomLeft: _selectionRect!.bottomLeft,
      TrackerHit.hitLeftCenter: _selectionRect!.centerLeft,
      TrackerHit.hitMiddleCenter: _selectionRect!.center,
    };

    for (final entry in points.entries) {
      final rect = Rect.fromCenter(
        center: entry.value,
        width: controlPointSize,
        height: controlPointSize,
      );
      if (rect.contains(point)) {
        return entry.key;
      }
    }

    if( _selectionRect!.contains(point) ) {
      return TrackerHit.hitMiddleCenter;
    }

    return TrackerHit.hitNothing;
  }

  void _setCursor(TrackerHit hit) {
    MouseCursor cursor;
    switch (hit) {
      case TrackerHit.hitTopLeft:
        cursor = SystemMouseCursors.resizeUpLeft;
        break;
      case TrackerHit.hitBottomRight:
        cursor = SystemMouseCursors.resizeDownRight;
        break; 
      case TrackerHit.hitTopRight:
        cursor = SystemMouseCursors.resizeUpRight;
        break;
      case TrackerHit.hitBottomLeft:
        cursor = SystemMouseCursors.resizeDownRight;
        break;
      case TrackerHit.hitTopCenter:
      case TrackerHit.hitBottomCenter:
        cursor = SystemMouseCursors.resizeUpDown;
        break;
      case TrackerHit.hitLeftCenter:
      case TrackerHit.hitRightCenter:
        cursor = SystemMouseCursors.resizeLeftRight;
        break;
      case TrackerHit.hitMiddleCenter:
        if( _isDrawMode() ) {
          cursor = SystemMouseCursors.precise;
        } else {
          cursor = SystemMouseCursors.move;
        }
        break;
      case TrackerHit.hitNothing:
        cursor = SystemMouseCursors.basic;
        break;
    }

    if( Platform.isMacOS ) {
      if( hit == TrackerHit.hitTopLeft ) {
        cursor = CustomSystemCursor(key: 'TopLeft');
      } else if( hit == TrackerHit.hitTopRight ) {
        cursor = CustomSystemCursor(key: 'TopRight');
      } else if( hit == TrackerHit.hitBottomLeft ) {
        cursor = CustomSystemCursor(key: 'BottomLeft');
      } else if( hit == TrackerHit.hitBottomRight ) {
        cursor = CustomSystemCursor(key: 'BottomRight');
      } else if( hit == TrackerHit.hitMiddleCenter ) {
        if( _isDrawMode() ) {
          cursor = SystemMouseCursors.precise;
        } else {
          cursor = CustomSystemCursor(key: 'Move');
        }
      } 
    }

    setState(() {
      _cursor = cursor;
    });
  }

  List<Widget> _imageTrackview() {
    return <Widget>[ 
      // 图片 
      // Image.asset("assets/images/capture.png", 
      //   key: _imageKey, 
      //   fit: BoxFit.none,
      //   alignment: Alignment.topLeft,
      // ), 
      CustomPaint( 
        painter: ImagePainter(_image!), 
        size: Size(_image!.width.toDouble(), _image!.height.toDouble()),
      ),

      // 蒙层
      Positioned.fill( 
        child: Container( 
          color: Colors.black.withOpacity(0.5),
        ),
      ),
      
      // 选区覆盖层
      Positioned.fill(
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerHover: _onPointerHover,
          child:MouseRegion(
            cursor: _cursor,
            child: CustomPaint(
              painter: _SelectionPainter(
                image: _image,
                selectionRect: _selectionRect,
                isSelecting: _isSelecting,
                paths: _paths, 
                textColor: _selectedColor,
                textPosition: _textPosition,
                textContent: _textController?.text,
              ),
            ),
          ),
        ),
      ),
    
      // 工具栏
      if(_showToolbar) 
        Positioned(
          left: _toolbarPosition.dx,
          top: _toolbarPosition.dy,
          height: 50,
          child: _toolbarView(),
        ),
        
        // 文本输入框
        if (_showTextInput && _textPosition != null)
          Positioned(
            left: _textPosition!.dx,
            top: _textPosition!.dy,
            child: Container(
              width: 200,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _textController,
                style: TextStyle(color: _selectedColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '输入文字...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                autofocus: true,
                onSubmitted: (value) {
                  setState(() {
                    _showTextInput = false;
                  });
                },
              ),
            ),
          ),

    ];
  }

  Widget _toolbarView() {
    return CaptureToolbar(
      selectedTool: _selectedTool,
      onToolSelected: (tool) {
        setState(() {
          _selectedTool = tool;
        });
      },
      showTextInput: _showTextInput,
      onUndo: _undo,
      onRedo: _redo,
      onClear: _clearAll,
      onSave: _cropImage,
      onClose: () {
        // Close the capture window
        windowManager.close();
      },
      canRedo: _redoPaths.isNotEmpty,
      canUndo: _paths.isNotEmpty,
    );
  }

  void _updateTrackerRect(PointerEvent event) {
    if( _currentHit == TrackerHit.hitMiddleCenter ) {
      // 移动选区
      final delta = event.localPosition - _startPoint!;
      _selectionRect = _selectionRect!.shift(delta);
      _startPoint = event.localPosition;
    } else if( _currentHit == TrackerHit.hitLeftCenter ) {
      // 调整左侧边界
      _selectionRect = Rect.fromLTRB(
        event.localPosition.dx,
        _selectionRect!.top,
        _selectionRect!.right,
        _selectionRect!.bottom,
      );
    } else if( _currentHit == TrackerHit.hitTopCenter ) {
      // 调整上侧边界
      _selectionRect = Rect.fromLTRB(
        _selectionRect!.left,
        event.localPosition.dy,
        _selectionRect!.right,
        _selectionRect!.bottom,
      );
    } else if( _currentHit == TrackerHit.hitRightCenter ) {
      // 调整右侧边界
      _selectionRect = Rect.fromLTRB(
        _selectionRect!.left,
        _selectionRect!.top,
        event.localPosition.dx,
        _selectionRect!.bottom,
      );
    } else if( _currentHit == TrackerHit.hitBottomCenter ) {
      // 调整下侧边界
      _selectionRect = Rect.fromLTRB(
        _selectionRect!.left,
        _selectionRect!.top,
        _selectionRect!.right,
        event.localPosition.dy,
      );
    } else if( _currentHit == TrackerHit.hitBottomCenter ) {
      // 调整下侧边界
      _selectionRect = Rect.fromLTRB(
        _selectionRect!.left,
        _selectionRect!.top,
        _selectionRect!.right,
        event.localPosition.dy,
      );
    } else if( _currentHit == TrackerHit.hitTopLeft ) {
      // 调整左上角
      _selectionRect = Rect.fromLTRB(
        event.localPosition.dx,
        event.localPosition.dy,
        _selectionRect!.right,
        _selectionRect!.bottom,
      );
    } else if( _currentHit == TrackerHit.hitTopRight ) {
      // 调整右上角
      _selectionRect = Rect.fromLTRB(
        _selectionRect!.left,
        event.localPosition.dy,
        event.localPosition.dx,
        _selectionRect!.bottom,
      );
    } else if( _currentHit == TrackerHit.hitBottomLeft ) {
      // 调整左下角
      _selectionRect = Rect.fromLTRB(
        event.localPosition.dx,
        _selectionRect!.top,
        _selectionRect!.right,
        event.localPosition.dy,
      );
    } else if( _currentHit == TrackerHit.hitBottomRight ) {
      // 调整右下角
      _selectionRect = Rect.fromLTRB(
        _selectionRect!.left,
        _selectionRect!.top,
        event.localPosition.dx,
        event.localPosition.dy,
      );
    } else {
      if ( !_isSelecting ) {
        return;
      }
      _selectionRect = Rect.fromPoints( _startPoint!, event.localPosition,);
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _currentHit = _trackerHitTest(event.localPosition);

    if( _isDrawMode() ) {
      // 绘图模式
      _onPanStart(event);
    } else {
      // 非绘图模式，移动选区，缩放选区
      if(_currentHit != TrackerHit.hitNothing ) {
        // hit some thing
        if( _currentHit == TrackerHit.hitMiddleCenter ) {
          // 移动选区
        }

        setState(() {
          _showToolbar = false; 
          _startPoint = event.localPosition; 
        });
      } else {
        // 建立选区
        setState(() {
          _showToolbar = false; 
          _isSelecting = true; 
          _startPoint = event.localPosition; 
          _selectionRect = Rect.fromPoints(_startPoint!, _startPoint!);
        });
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    // dragging move
    //var ht = _trackerHitTest(event.localPosition);
    // print('Hit Test: $ht');
    // _setCursor(ht);
    if( _isDrawMode() ) {
      _onPanUpdate(event);
    } else {
      setState(() {
        _updateTrackerRect(event);
      });
    }
  }

  void _onPointerHover(PointerHoverEvent event) {
    var ht = _trackerHitTest(event.localPosition);
    //print('Hit Test: $ht');
    _setCursor(ht);
  }

  void _onPointerUp(PointerUpEvent event) {
    //if(_currentHit == TrackerHit.hitMiddleCenter ) {
      // 结束移动选区
      //_currentHit = TrackerHit.hitNothing;
      if( _isDrawMode() ) {
        _onPanEnd(event);
      } else {
        setState(() {
          _showToolbar = true;
          _toolbarPosition = Offset( _selectionRect!.left, _selectionRect!.bottom + 10); 
        });
      }
    //  return;
    //}

    if (!_isSelecting) return;
    
    setState(() {
      _isSelecting = false;
      // 确保选区矩形是有效的（宽度和高度为正）
      if (_selectionRect != null) {
        _selectionRect = Rect.fromPoints(
          Offset(
            _selectionRect!.left < _selectionRect!.right
                ? _selectionRect!.left
                : _selectionRect!.right,
            _selectionRect!.top < _selectionRect!.bottom
                ? _selectionRect!.top
                : _selectionRect!.bottom,
          ),
          Offset(
            _selectionRect!.left < _selectionRect!.right
                ? _selectionRect!.right
                : _selectionRect!.left,
            _selectionRect!.top < _selectionRect!.bottom
                ? _selectionRect!.bottom
                : _selectionRect!.top,
          ),
        );
        _showToolbar = true;
        _toolbarPosition = Offset( _selectionRect!.left, _selectionRect!.bottom + 10);
        print(_toolbarPosition);
      }
    });
  }


 // 绘图相关方法
  void _onPanStart(PointerDownEvent details) {
    if (_selectedTool == 'text') 
    {
      setState(() {
        //_showTextInput = true;
        currentOffset = details.localPosition;
      });
      return;
    }

    setState(() {
      isDrawing = true;
      _redoPaths.clear();
      
      //if (_selectedTool == 'pen' || _selectedTool == 'highlighter') {
      if (_selectedTool != 'text' ) {
        _paths.add(DrawingPath(
          color: _selectedColor,
          strokeWidth: strokeWidth,
          tool: _selectedTool,
        ));
        
        _paths.last.points.add(DrawingPoint(
          offset: details.localPosition,
          color: _selectedColor,
          strokeWidth: strokeWidth,
          tool: _selectedTool,
        ));
      } else {
        currentOffset = details.localPosition;
      }
    });
  }

  void _onPanUpdate(PointerMoveEvent details) {
    if (!isDrawing || _selectedTool == 'text') return;

    setState(() {
      //if (_selectedTool == 'pen' || _selectedTool == 'highlighter') {
      if (_selectedTool != 'text') {
        _paths.last.points.add(DrawingPoint(
          offset: details.localPosition,
          color: _selectedColor,
          strokeWidth: strokeWidth,
          tool: _selectedTool,
        ));
      } else {
        currentOffset = details.localPosition;
      }
    });
  }

  void _onPanEnd(PointerUpEvent details) {
    if (_selectedTool == 'text') {
      setState(() {
        _showTextInput = true;
        _textPosition = details.localPosition;
      });
      return;
    }

    setState(() {
      isDrawing = false;
      if (_selectedTool != 'pen' && _selectedTool != 'highlighter' && currentOffset != null) {
        // 对于形状工具，添加完整的路径
        _paths.add(DrawingPath(
          color: _selectedColor,
          strokeWidth: strokeWidth,
          tool: _selectedTool,
        ));
        
        _paths.last.points.add(DrawingPoint(
          offset: currentOffset!,
          color: _selectedColor,
          strokeWidth: strokeWidth,
          tool: _selectedTool,
        ));
      }
      currentOffset = null;
    });
  }


  void _cropImage() {
    if (_selectionRect == null) return;
    
    // 这里可以实现裁剪逻辑
    // 在实际应用中，你可能需要使用 image 包来处理图片裁剪
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选区信息'),
        content: Text(
          '已选择区域:\n'
          '位置: (${_selectionRect!.left.toStringAsFixed(1)}, '
          '${_selectionRect!.top.toStringAsFixed(1)})\n'
          '大小: ${_selectionRect!.width.toStringAsFixed(1)} × '
          '${_selectionRect!.height.toStringAsFixed(1)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 工具方法
  void _undo() {
    if (_paths.isNotEmpty) {
      setState(() {
        _redoPaths.add(_paths.removeLast());
      });
    }
  }

  void _redo() {
    if (_redoPaths.isNotEmpty) {
      setState(() {
        _paths.add(_redoPaths.removeLast());
      });
    }
  }

  void _clearAll() {
    setState(() {
      _paths.clear();
      _redoPaths.clear();
      _showTextInput = false;
      //textPosition = null;
    });
  }

}

// 自定义绘制选区
class _SelectionPainter extends CustomPainter {
  final Rect? selectionRect;
  final bool isSelecting;
  final ui.Image? image;

  final List<DrawingPath> paths;
  final Offset? textPosition;
  final String? textContent;
  final Color textColor;

  const _SelectionPainter({
    required this.selectionRect,
    required this.isSelecting,
    required this.image,
    required this.paths,
    this.textPosition,
    this.textContent,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectionRect == null) {
      return;
    }

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 绘制选区矩形
    //canvas.drawRect(selectionRect!, paint);
    if( image != null ) {
      // final paint = Paint()
      // ..color = Colors.transparent
      // ..style = PaintingStyle.fill;
      canvas.drawImageRect(image!, selectionRect!, selectionRect!, Paint());
    }
    canvas.drawRect(selectionRect!, borderPaint);

    //canvas.drawImageRect(image!, selectionRect!, selectionRect!, paint);

    // 绘制选区角落的控制点
    final controlPointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    const controlPointSize = 18.0;
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

    // 如果正在选择，绘制提示
    if (isSelecting) {
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
    else {
      _paintPaths(canvas, size);
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
  bool shouldRepaint(covariant _SelectionPainter oldDelegate) {
    return true;
    //return oldDelegate.selectionRect != selectionRect ||
    //    oldDelegate.isSelecting != isSelecting || oldDelegate.paths != paths;
  }
}