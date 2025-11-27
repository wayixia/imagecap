
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imagecap/utils/shape_detection.dart';
import 'package:imagecap/wnds/capture/selection_painter.dart';
import 'package:imagecap/wnds/capture/toolbar.dart';
import 'package:imagecap/utils/cursor_manager.dart';
import 'package:imagecap/utils/image_utils.dart';
import 'package:imagecap/wnds/capture/toolbar_options.dart';
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
  
  hitDrawEllipseTopCenter,
  hitDrawEllipseLeftCenter,
  hitDrawEllipseBottomCenter,
  hitDrawEllipseRightCenter,

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



class ImageSelectionScreen extends StatefulWidget {
  const ImageSelectionScreen({super.key});

  @override
  State<ImageSelectionScreen> createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  // final TransformationController _transformationController =
  //     TransformationController();
  
  // 选区相关状态
  Rect? _selectionRect;
  Offset? _startPoint;
  bool _isSelecting = false;
  MouseCursor _cursor = SystemMouseCursors.basic;
  TrackerHit _currentHit = TrackerHit.hitNothing;
  ui.Image? _image;
  bool _showToolbar = false;
  bool _showToolbarOptions = false;
  Offset _toolbarPosition = Offset.zero;

  // 绘图相关状态
  final List<DrawingPath> _paths = [];
  final List<DrawingPath> _redoPaths = [];
  DrawingPath? _selectedPath;
  Color _selectedColor = Colors.red;
  double strokeWidth = 3.0;
  bool isDrawing = false;
  Offset? currentOffset;
  TextEditingController? _textController;
  Offset? _textPosition;
  bool _showTextInput = false;
  String _selectedTool = "";
  Offset _drawStartPoint = Offset.zero;
  final double _controlPointSize = 8.0;


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
      debugPrint('Error loading image: $e');
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
    return ( _selectedTool != "" || _paths.isNotEmpty || _redoPaths.isNotEmpty );
  }

  /// 判断点是否在直线区域内， tolerance为容差范围
  bool _pointInLineArea( Offset point, Offset lineStart, Offset lineEnd, double tolerance ) {
    // 首先检查点是否在直线的包围盒内
    if( point.dx < min(lineStart.dx, lineEnd.dx) - tolerance ||
        point.dx > max(lineStart.dx, lineEnd.dx) + tolerance ||
        point.dy < min(lineStart.dy, lineEnd.dy) - tolerance ||
        point.dy > max(lineStart.dy, lineEnd.dy) + tolerance ) {
      return false;
    }
    
    // 处理直线垂直的情况
    if( lineEnd.dx.toInt() == lineStart.dx.toInt() ) {
      if( ( point.dx >= lineStart.dx - tolerance ) && ( point.dx <= lineStart.dx + tolerance ) ) {
        double minY = min( lineStart.dy, lineEnd.dy );
        double maxY = max( lineStart.dy, lineEnd.dy );
        if( ( point.dy >= minY - tolerance ) && ( point.dy <= maxY + tolerance ) ) {
          return true;
        }
      }
      return false;
    }

    // 处理直线水平的情况
    if( lineEnd.dy.toInt() == lineStart.dy.toInt() ) {
      if( ( point.dy >= lineStart.dy - tolerance ) && ( point.dy <= lineStart.dy + tolerance ) ) {
        double minX = min( lineStart.dx, lineEnd.dx );
        double maxX = max( lineStart.dx, lineEnd.dx );
        if( ( point.dx >= minX - tolerance ) && ( point.dx <= maxX + tolerance ) ) {
          return true;
        }
      }
      return false;
    }

    double k = (lineEnd.dy - lineStart.dy) / (lineEnd.dx - lineStart.dx + 0.00001);
    double b = lineStart.dy - k * lineStart.dx;
    double expectedY = k * point.dx + b;
    //print("k=$k, b=$b, expectedY=$expectedY, point.dy=${point.dy}, lineStart=$lineStart, lineEnd=$lineEnd"); 
    if ( ( (expectedY - tolerance ) > point.dy ) ||  ( (expectedY + tolerance) < point.dy ) ) {
      return false;
    }

    return true;
  }

  /// 判断点是否在矩形边缘范围内, tolerance为容差范围
  bool _pointInRectangleArea( Offset point, Offset rectStart, Offset rectEnd, double tolerance ) {
    double left = min( rectStart.dx, rectEnd.dx );
    double right = max( rectStart.dx, rectEnd.dx );
    double top = min( rectStart.dy, rectEnd.dy );
    double bottom = max( rectStart.dy, rectEnd.dy );

    Rect rect = Rect.fromLTRB(left, top, right, bottom);

    if( rect.inflate(tolerance).contains(point)  && !rect.deflate(tolerance).contains(point) ) {
      return true;
    }

    return false;
  }

  bool _pointInEllipsArea( Offset point, Offset rectStart, Offset rectEnd,  double tolerance ) {
    Offset center = Offset(
          (rectStart.dx + rectEnd.dx) / 2,
          (rectStart.dy + rectEnd.dy) / 2,
        );
    double a = ( rectEnd.dx-rectStart.dx )/2;
    double b = ( rectEnd.dy-rectStart.dy )/2;
    // @todo 垂直的长轴处理还有问题
    //if( a>b) {
      return Ellipse(center, a, b).containsPoint(point, tolerance: tolerance);
    //} else {
    //  return Ellipse(center, b, a).containsPoint(point, tolerance: tolerance);
    //}
  }


  DrawingPath? _findDrawingPathAt(Offset point) {
    for (var path in _paths.reversed) {
      if( path.tool == "arrow" || path.tool == "line" ) {
        if( path.points.length < 2 ) {
          continue;
        }
        
        if( _pointInLineArea(point, path.points.first.offset, path.points.last.offset, 5) ) {
          return path;
        }
      } else if( path.tool == "rectangle" ) {
        if( path.points.length < 2 ) {
          continue;
        }

        if( _pointInRectangleArea(point, path.points.first.offset, path.points.last.offset, 5) ) {
          return path;
        }
      } else if( path.tool == "ellipse" ) {
        if( path.points.length < 2 ) {
          continue;
        }
        

        if( _pointInEllipsArea(point, path.points.first.offset, path.points.last.offset, 5) ) {
          return path;
        }
      } else {
        // if( path.tool == 'pen' || path.tool == 'highlighter' ) {
        //   continue; // skip pen and highlighter
        continue;
      }
    }
    return null;
  }

  bool _isInTracker(Offset localPosition) {
    return _selectionRect?.contains(localPosition)??false;
  }

  Offset _safePosition( Offset localPosition ) {
    if( _selectionRect == null ) {
      return localPosition;
    }

    double dx = 0;
    double dy = 0;
    if( localPosition.dx < _selectionRect!.left ) {
      dx = _selectionRect!.left;
    } else if( localPosition.dx > _selectionRect!.right ) {
      dx = _selectionRect!.right;
    } else {
      dx = localPosition.dx;
    }

    if( localPosition.dy < _selectionRect!.top ) {
      dy = _selectionRect!.top;
    } else if( localPosition.dy > _selectionRect!.bottom ) {
      dy = _selectionRect!.bottom;
    } else {
      dy = localPosition.dy;
    }
    ///print("safePosition($dx,$dy)");
    return Offset(dx, dy);
  }


  Map<TrackerHit, Offset>? _getDrawTrackerPoints( String type, List<DrawingPoint>? linepoints, double controlPointSize ) {
    final Map<TrackerHit, Offset> points;

    if( type == "line" || type == "arrow" ) {
      points = {
        TrackerHit.hitDrawLineStart: linepoints != null && linepoints.length >= 2 ? linepoints.first.offset : _selectionRect!.topLeft,
        TrackerHit.hitDrawLineEnd: linepoints != null && linepoints.length >= 2 ? linepoints.last.offset : _selectionRect!.bottomRight,
      };
    } else if( type == "ellipse") {
      points = {
        TrackerHit.hitDrawEllipseTopCenter: Offset(_selectionRect!.center.dx, _selectionRect!.top),
        TrackerHit.hitDrawEllipseRightCenter: Offset(_selectionRect!.right, _selectionRect!.center.dy),
        TrackerHit.hitDrawEllipseBottomCenter: Offset(_selectionRect!.center.dx, _selectionRect!.bottom),
        TrackerHit.hitDrawEllipseLeftCenter: Offset(_selectionRect!.left, _selectionRect!.center.dy),
      };
    } else if( type == "rectangle" ) {
      points = {
        TrackerHit.hitDrawRectangleTopLeft: _selectionRect!.topLeft,
        TrackerHit.hitDrawRectangleTopCenter: _selectionRect!.topCenter,
        TrackerHit.hitDrawRectangleTopRight: _selectionRect!.topRight,
        TrackerHit.hitDrawRectangleRightCenter: _selectionRect!.centerRight,
        TrackerHit.hitDrawRectangleBottomRight: _selectionRect!.bottomRight,
        TrackerHit.hitDrawRectangleBottomCenter: _selectionRect!.bottomCenter,
        TrackerHit.hitDrawRectangleBottomLeft: _selectionRect!.bottomLeft,
        TrackerHit.hitDrawRectangleLeftCenter: _selectionRect!.centerLeft,
      };
    } else {
      return null;
    }

    return points;
  }

  bool _isDrawTrackerHit( TrackerHit hit ) {
    return hit == TrackerHit.hitDrawLineStart ||
           hit == TrackerHit.hitDrawLineEnd ||
           hit == TrackerHit.hitDrawEllipseTopCenter ||
           hit == TrackerHit.hitDrawEllipseRightCenter ||
           hit == TrackerHit.hitDrawEllipseBottomCenter ||
           hit == TrackerHit.hitDrawEllipseLeftCenter ||
           hit == TrackerHit.hitDrawRectangleTopLeft ||
           hit == TrackerHit.hitDrawRectangleTopCenter ||
           hit == TrackerHit.hitDrawRectangleTopRight ||
           hit == TrackerHit.hitDrawRectangleRightCenter ||
           hit == TrackerHit.hitDrawRectangleBottomRight ||
           hit == TrackerHit.hitDrawRectangleBottomCenter ||
           hit == TrackerHit.hitDrawRectangleBottomLeft ||
           hit == TrackerHit.hitDrawRectangleLeftCenter;
  }

  TrackerHit _trackerHitTest(Offset point) {
    if (_selectionRect == null) {
      return TrackerHit.hitNothing;
    }

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
        width: _controlPointSize,
        height: _controlPointSize,
      );
      if (rect.contains(point)) {
        return entry.key;
      }
    }

    if( _selectionRect!.contains(point) ) {
      if( _isDrawMode() ) {
        // 检测是否在绘图对象的选区上
        if( _selectedPath != null ) {
          Map<TrackerHit, Offset>? drawPoints = _getDrawTrackerPoints( _selectedPath!.tool, _selectedPath!.points, _controlPointSize );
          if( drawPoints != null ) {
            for (final entry in drawPoints.entries) {
              final rect = Rect.fromCenter(
                center: entry.value,
                width: _controlPointSize,
                height: _controlPointSize,
              );
              if (rect.contains(point)) {
                return entry.key;
              }
            }
          }
          //return TrackerHit.hitDrawObject;
        }
        DrawingPath? path = _findDrawingPathAt( point );
        if( path != null ) {
          return TrackerHit.hitDrawObject;
        }
      }
      return TrackerHit.hitMiddleCenter;
    }

    return TrackerHit.hitNothing;
  }

  void _setCursor(TrackerHit hit) {
    MouseCursor cursor;
    switch (hit) {
      case TrackerHit.hitTopLeft:
      case TrackerHit.hitDrawRectangleTopLeft:
        cursor = SystemMouseCursors.resizeUpLeft;
        break;
      case TrackerHit.hitBottomRight:
      case TrackerHit.hitDrawRectangleBottomRight:
        cursor = SystemMouseCursors.resizeDownRight;
        break; 
      case TrackerHit.hitTopRight:
      case TrackerHit.hitDrawRectangleTopRight:
        cursor = SystemMouseCursors.resizeUpRight;
        break;
      case TrackerHit.hitBottomLeft:
      case TrackerHit.hitDrawRectangleBottomLeft:
        cursor = SystemMouseCursors.resizeDownRight;
        break;
      case TrackerHit.hitTopCenter:
      case TrackerHit.hitBottomCenter:
      case TrackerHit.hitDrawRectangleTopCenter:
      case TrackerHit.hitDrawRectangleBottomCenter:
        cursor = SystemMouseCursors.resizeUpDown;
        break;
      case TrackerHit.hitLeftCenter:
      case TrackerHit.hitRightCenter:
      case TrackerHit.hitDrawRectangleLeftCenter:
      case TrackerHit.hitDrawRectangleRightCenter:
        cursor = SystemMouseCursors.resizeLeftRight;
        break;
      case TrackerHit.hitMiddleCenter:
        if( _isDrawMode() ) {
          cursor = SystemMouseCursors.precise;
        } else {
          cursor = SystemMouseCursors.move;
        }
        break;
      
      case TrackerHit.hitDrawObject:
        cursor = SystemMouseCursors.move;
        break;

      case TrackerHit.hitDrawEllipseTopCenter:
      case TrackerHit.hitDrawEllipseBottomCenter:
        cursor = SystemMouseCursors.resizeUpDown;
        break;
      case TrackerHit.hitDrawEllipseLeftCenter:
      case TrackerHit.hitDrawEllipseRightCenter:
        cursor = SystemMouseCursors.resizeLeftRight;
        break;
      case TrackerHit.hitDrawLineStart:
      case TrackerHit.hitDrawLineEnd:
        cursor = SystemMouseCursors.basic;
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
      } else if( hit == TrackerHit.hitDrawObject ) {
        cursor = CustomSystemCursor(key: 'Move');
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
              painter: SelectionPainter(
                image: _image,
                selectionRect: _selectionRect,
                isSelecting: _isSelecting,
                paths: _paths, 
                selectedPath: _selectedPath,
                textColor: _selectedColor,
                textPosition: _textPosition,
                textContent: _textController?.text,
                controlPointSize: _controlPointSize,
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
      if( _showToolbar && _showToolbarOptions ) 
        Positioned(
          left: _toolbarPosition.dx,
          top: _toolbarPosition.dy+60,
          height: 50,
          child: _toolbarOptionsView(),
        ),
 
      // 文本输入框
      if (_showTextInput && currentOffset != null)
        Positioned(
          left: _drawStartPoint.dx,
          //left: min(_drawStartPoint.dx, currentOffset!.dx),
          top: _drawStartPoint.dy,
          //top: min( _drawStartPoint.dy, currentOffset!.dy),
          child: Container(
            width: (currentOffset!.dx - _drawStartPoint.dx).abs(),
            height: (currentOffset!.dy - _drawStartPoint.dy).abs(),
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              //color: Colors.transparent,
              borderRadius: BorderRadius.circular(3),
            ),
            child: TextField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
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
          if(_selectedTool != "" ) {
            _showToolbarOptions = true;
          } else {
            _showToolbarOptions = false;
          }
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

  Widget _toolbarOptionsView() {
    return CaptureToolbarOptions(
      selectedColor: _selectedColor,
      fontSize: 16,
      lineSize: strokeWidth.toInt(),
      onColorSelected: _onColorSelected, 
      onFontSizeSelected: _onFontSizeSelected, 
      onLineSizeSelected: _onLineSizeSelected);
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
    _startPoint = event.localPosition; 
    //print('Pointer Down at ${event.localPosition}, hit=$_currentHit');
    if( _isDrawMode() ) {
      // 绘图模式
      if( _isInTracker(event.localPosition)) {
        if( _currentHit == TrackerHit.hitDrawObject || _isDrawTrackerHit( _currentHit ) ) {
          // 点击到绘图对象上
          DrawingPath? path = _findDrawingPathAt(event.localPosition);
          _selectedPath = path;
          setState(() {
            
          });
        } else {
          _selectedPath = null;
          _onPanStart(event);
        }
      }
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
      //if( _isInTracker(event.localPosition)) {
      if( _selectedPath != null ) {
        if(_currentHit == TrackerHit.hitDrawObject ) {
          // 移动选中绘图对象
          setState(() {
          final delta = event.localPosition - _startPoint!;
          for( var point in _selectedPath!.points ) {
            point.offset = point.offset + delta;
          }
          _startPoint = event.localPosition;
          });
        } else if( _isDrawTrackerHit( _currentHit ) ) {
          //print("move draw tracker hit: $_currentHit");
          // 调整绘图对象大小
          setState(() {
            if( _currentHit == TrackerHit.hitDrawLineStart ) {
              // 调整线条起点
              _selectedPath!.points.first.offset = event.localPosition;
            } else if( _currentHit == TrackerHit.hitDrawLineEnd ) {
              // 调整线条终点
              _selectedPath!.points.last.offset = event.localPosition;
            } else if( _currentHit == TrackerHit.hitDrawRectangleTopLeft ) {
              // 调整矩形左上角
              _selectedPath!.points[0].offset = event.localPosition;
            } else if( _currentHit == TrackerHit.hitDrawRectangleBottomRight ) {
              // 调整矩形右下角
              _selectedPath!.points[1].offset = event.localPosition;
            } else if( _currentHit == TrackerHit.hitDrawEllipseTopCenter ) {
              // 调整椭圆上侧中点
              _selectedPath!.points[0].offset = Offset( _selectedPath!.points[0].offset.dx, event.localPosition.dy);
            } else if( _currentHit == TrackerHit.hitDrawEllipseBottomCenter ) {
              // 调整椭圆下侧中点
              _selectedPath!.points[1].offset = Offset( _selectedPath!.points[1].offset.dx, event.localPosition.dy);
            }
          });
        }
      } else {
        _onPanUpdate(event);
      }
      //}
    } else {
      setState(() {
        _updateTrackerRect(event);
      });
    }
  }

  void _onPointerHover(PointerHoverEvent event) {
    var ht = _trackerHitTest(event.localPosition);
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
        //print(_toolbarPosition);
      }
    });
  }


 // 绘图相关方法
  void _onPanStart(PointerDownEvent details) {

    _drawStartPoint = details.localPosition;

    if (_selectedTool == 'text') 
    {
      setState(() {
        isDrawing = true;
        _showTextInput = true;
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
    if (!isDrawing )
    {  
      return;
    }

    setState(() {
      //if (_selectedTool == 'pen' || _selectedTool == 'highlighter') {
      if (_selectedTool != 'text') {
        _paths.last.points.add(DrawingPoint(
          offset: _safePosition(details.localPosition),
          color: _selectedColor,
          strokeWidth: strokeWidth,
          tool: _selectedTool,
        ));
      } else {
        currentOffset = _safePosition(details.localPosition);
        _showTextInput = true;
      }
    });
  }

  void _onPanEnd(PointerUpEvent details) {
    if (_selectedTool == 'text') {
      setState(() {
        _showTextInput = true;
        _textPosition = _safePosition(details.localPosition);
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
      _textPosition = null;
      _selectedPath = null;
    });
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _onLineSizeSelected( int size ) {

  }

  void _onFontSizeSelected( int size ) {

  }
}