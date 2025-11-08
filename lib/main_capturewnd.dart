
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:imagecap/utils/cursor_manager.dart';
import 'package:imagecap/utils/image_utils.dart';
import 'package:window_manager/window_manager.dart';



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



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: 
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        DrawingBoard( 
          background: Container(width: 600, height: 800, color: Colors.white), 
          showDefaultActions: true, /// Enable default action options 
          showDefaultTools: true,   /// Enable default toolbar
        ),
        // HighlightListView(
        //   items: List.generate(8, (index) => 'Item $index'),
        // ),
        // ListView( 
        //   children: List.generate(10, (index) {
        //     return ListTile(
        //       leading: Icon(Icons.label),
        //       title: Text('Item $index'),
        //       mouseCursor: SystemMouseCursors.move,
        //       selectedColor: Color.fromARGB(255, 137, 11, 11), 
        //       hoverColor: Color.fromARGB(255,255,0, 255),
        //       tileColor: Color.fromARGB(255, 0, 204, 204),
        //       selectedTileColor: Color.fromARGB(255, 255, 255, 0),
        //     );
        //   })
    );
  }
}

class HighlightListView extends StatefulWidget {
  final List<String> items;

  HighlightListView({super.key, required this.items});

  @override
  _HighlightListViewState createState() => _HighlightListViewState();
}

class _HighlightListViewState extends State<HighlightListView> {
  int? _highlightedIndex;
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        bool isHighlighted = _highlightedIndex == index;
        bool isSelected = _selectedIndex == index;
        return MouseRegion(
          onEnter: (event) => _highlight(index),
          onExit: (event) => _highlight(null),
          child: ListTile(
            title: Text(widget.items[index]),
            selected: isSelected, // 使用selected属性来显示高亮效果
            selectedColor: Colors.white, // 高亮颜色
            selectedTileColor: Colors.green, // 选中颜色
            trailing: Icon(Icons.star, color: (isHighlighted||isSelected) ?Colors.white:Colors.grey),
            onTap: () {
              // 处理点击事件
              _selectedIndex = index;
              setState(() {});
            },
          ),
        );
      },
    );
  }

  void _highlight(int? index) {
    setState(() {
      _highlightedIndex = index;
    });
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

class ImageSelectionScreen extends StatefulWidget {
  const ImageSelectionScreen({super.key});

  @override
  State<ImageSelectionScreen> createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _imageKey = GlobalKey();
  
  // 选区相关状态
  Rect? _selectionRect;
  Offset? _startPoint;
  bool _isSelecting = false;
  MouseCursor _cursor = SystemMouseCursors.basic;
  TrackerHit _currentHit = TrackerHit.hitNothing;
  ui.Image? _image;


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
      body: Column(
        children: [
          // 操作提示
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: const Text(
              '使用双指缩放和拖动图片，点击选区按钮后拖动鼠标选择区域',
              textAlign: TextAlign.center,
            ),
          ),
          
          // 图片和选区区域
          Expanded(
            child: Stack(
              children: _image != null ? _imageTrackview():[Text("Loading Image...")],
            ),
          ),
          
          // 操作按钮
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _selectionRect == null ? null : _cropImage,
                  child: const Text('裁剪选中区域'),
                ),
                ElevatedButton(
                  onPressed: _resetView,
                  child: const Text('重置视图'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        cursor = SystemMouseCursors.move;
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
              painter: _SelectionPainter(
                image: _image,
                selectionRect: _selectionRect,
                isSelecting: _isSelecting,
              ),
            ),
          ),
        ),
      ),
    ];
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

    setState(() {
      if( _currentHit != TrackerHit.hitNothing ) {
        // 开始移动选区
        _startPoint = event.localPosition;
        return;
      }

      _isSelecting = true;
      _startPoint = event.localPosition;
      _selectionRect = Rect.fromPoints(_startPoint!, _startPoint!);
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    // dragging move
    //var ht = _trackerHitTest(event.localPosition);
    // print('Hit Test: $ht');
    // _setCursor(ht);
    setState(() {
      _updateTrackerRect(event);
    });
  }

  void _onPointerHover(PointerHoverEvent event) {
    var ht = _trackerHitTest(event.localPosition);
    print('Hit Test: $ht');
    _setCursor(ht);
  }

  void _onPointerUp(PointerUpEvent event) {
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
      }
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

  void _resetView() {
    _transformationController.value = Matrix4.identity();
    //_clearSelection();
  }
}

// 自定义绘制选区
class _SelectionPainter extends CustomPainter {
  final Rect? selectionRect;
  final bool isSelecting;
  final ui.Image? image;

  const _SelectionPainter({
    required this.selectionRect,
    required this.isSelecting,
    required this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectionRect == null) {
      return;
    }

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

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
  }

  @override
  bool shouldRepaint(covariant _SelectionPainter oldDelegate) {
    return oldDelegate.selectionRect != selectionRect ||
        oldDelegate.isSelecting != isSelecting;
  }
}