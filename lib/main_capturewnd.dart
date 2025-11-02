
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
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

class RectangleSelectionDemo extends StatefulWidget {
  @override
  _RectangleSelectionDemoState createState() => _RectangleSelectionDemoState();
}

class _RectangleSelectionDemoState extends State<RectangleSelectionDemo> {
  // 选区状态
  Offset? _selectionStart;
  Offset? _selectionEnd;
  bool _isSelecting = false;
  
  // 被选中的项目
  Set<int> _selectedItems = {};

  // 清除选区
  void _clearSelection() {
    setState(() {
      _selectionStart = null;
      _selectionEnd = null;
      _isSelecting = false;
      _selectedItems.clear();
    });
  }

  // 获取选区矩形
  Rect? get _selectionRect {
    if (_selectionStart == null || _selectionEnd == null) return null;
    return Rect.fromPoints(_selectionStart!, _selectionEnd!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('矩形选区示例'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearSelection,
            tooltip: '清除选区',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 内容网格
          _buildContentGrid(),
          
          // 选区覆盖层
          _buildSelectionOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('选中项目: $_selectedItems');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已选中 ${_selectedItems.length} 个项目')),
          );
        },
        child: Icon(Icons.check),
      ),
    );
  }

  // 构建内容网格
  Widget _buildContentGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 50,
      itemBuilder: (context, index) {
        final isSelected = _selectedItems.contains(index);
        return Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.7) : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建选区覆盖层
  Widget _buildSelectionOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          painter: _SelectionPainter(
            selectionRect: _selectionRect,
            isSelecting: _isSelecting,
          ),
        ),
      ),
    );
  }

  // 手势开始
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _selectionStart = details.localPosition;
      _selectionEnd = details.localPosition;
      _isSelecting = true;
    });
  }

  // 手势更新
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _selectionEnd = details.localPosition;
      _updateSelectedItems();
    });
  }

  // 手势结束
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isSelecting = false;
    });
  }

  // 更新选中的项目
  void _updateSelectedItems() {
    final selectionRect = _selectionRect;
    if (selectionRect == null) return;

    final selected = <int>{};
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    
    // 遍历所有网格项，检查是否在选区内
    for (int i = 0; i < 50; i++) {
      // 在实际应用中，你需要获取每个网格项的实际位置
      // 这里简化处理，假设网格项按5列排列
      final row = i ~/ 5;
      final col = i % 5;
      
      // 计算网格项的大致位置（需要根据实际布局调整）
      final itemSize = (MediaQuery.of(context).size.width - 16 * 2 - 8 * 4) / 5;
      final itemLeft = 16 + col * (itemSize + 8);
      final itemTop = 16 + row * (itemSize + 8);
      
      final itemRect = Rect.fromLTWH(
        itemLeft, 
        itemTop, 
        itemSize, 
        itemSize
      );
      
      if (selectionRect.overlaps(itemRect)) {
        selected.add(i);
      }
    }
    
    setState(() {
      _selectedItems = selected;
    });
  }
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
  
  // 图片信息
  final String imageUrl =
      'https://fastly.picsum.photos/id/658/800/600.jpg?hmac=SMvl4-C3gJJUQ3C38MK0sGBnKcWdTZmooGG5FoL9l24'; // 替换为你的图片URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片选区功能'),
        actions: [
          IconButton(
            icon: const Icon(Icons.crop_free),
            onPressed: _startSelection,
            tooltip: '开始选区',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSelection,
            tooltip: '清除选区',
          ),
        ],
      ),
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
          
          // 选区信息显示
          if (_selectionRect != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue[50],
              child: Text(
                '选区信息: ${_selectionRect!.topLeft.dx.toStringAsFixed(1)}, '
                '${_selectionRect!.topLeft.dy.toStringAsFixed(1)} - '
                '${_selectionRect!.bottomRight.dx.toStringAsFixed(1)}, '
                '${_selectionRect!.bottomRight.dy.toStringAsFixed(1)} '
                '大小: ${_selectionRect!.width.toStringAsFixed(1)}×${_selectionRect!.height.toStringAsFixed(1)}',
                textAlign: TextAlign.center,
              ),
            ),
          
          // 图片和选区区域
          Expanded(
            child: Center(
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.1,
                maxScale: 4.0,
                child: Stack(
                  children: [
                    // 图片
                    Image.asset("assets/images/capture.png",
                      key: _imageKey,
                      fit: BoxFit.contain,
                    ),
                    // Image.network(
                    //   imageUrl,
                    //   key: _imageKey,
                    //   fit: BoxFit.contain,
                    // ),
                    
                    // 选区覆盖层
                    Positioned.fill(
                      child: Listener(
                        onPointerDown: _onPointerDown,
                        onPointerMove: _onPointerMove,
                        onPointerUp: _onPointerUp,
                        child: CustomPaint(
                          painter: _SelectionPainter(
                            selectionRect: _selectionRect,
                            isSelecting: _isSelecting,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

  void _startSelection() {
    setState(() {
      _isSelecting = true;
      _selectionRect = null;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectionRect = null;
      _isSelecting = false;
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!_isSelecting) return;
    
    setState(() {
      _startPoint = event.localPosition;
      _selectionRect = Rect.fromPoints(_startPoint!, _startPoint!);
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isSelecting || _startPoint == null) return;
    
    setState(() {
      _selectionRect = Rect.fromPoints(
        _startPoint!,
        event.localPosition,
      );
    });
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
    _clearSelection();
  }
}

// 自定义绘制选区
class _SelectionPainter extends CustomPainter {
  final Rect? selectionRect;
  final bool isSelecting;

  const _SelectionPainter({
    required this.selectionRect,
    required this.isSelecting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectionRect == null) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 绘制选区矩形
    canvas.drawRect(selectionRect!, paint);
    canvas.drawRect(selectionRect!, borderPaint);

    // 绘制选区角落的控制点
    final controlPointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    const controlPointSize = 8.0;
    final points = [
      selectionRect!.topLeft,
      selectionRect!.topRight,
      selectionRect!.bottomRight,
      selectionRect!.bottomLeft,
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