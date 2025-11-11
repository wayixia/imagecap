import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';


typedef ToolSelectedCallback = void Function(String? tool);


class CaptureToolbar extends StatefulWidget {
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback onSave;
  final VoidCallback onClose;
  final ToolSelectedCallback onToolSelected;
  final bool canUndo;
  final bool canRedo;
  
  String? selectedTool;
  bool showTextInput;


  CaptureToolbar({
    super.key,
    this.selectedTool,
    this.showTextInput = false,
    required this.onToolSelected,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.onSave,
    required this.onClose,
    this.canUndo = false,
    this.canRedo = false,
  });


  
  @override
  State<StatefulWidget> createState() => _CaptureToolbarState();
}

class _CaptureToolbarState extends State<CaptureToolbar> {
  //String? _selectedTool;
  //bool? _showTextInput = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> tools = [
      {'icon': Icons.edit, 'label': '画笔', 'tool': 'pen', 'onpress': () {}},
      {'icon': Icons.brush, 'label': '荧光笔', 'tool': 'highlighter'},
      {'icon': Icons.horizontal_rule, 'label': '直线', 'tool': 'line'},
      {'icon': Icons.crop_square, 'label': '矩形', 'tool': 'rectangle'},
      {'icon': Icons.panorama_fish_eye, 'label': '椭圆', 'tool': 'ellipse'},
      {'icon': Icons.text_fields, 'label': '文本', 'tool': 'text'},
      {'icon': Icons.arrow_right_alt, 'label': '箭头', 'tool': 'arrow'},
      {'icon': Icons.blur_on, 'label': '模糊', 'tool': 'blur'},
    ];

    List<Map<String, dynamic>> actions = [
      {'icon': Icons.undo, 'label': '撤销', 'tool':'undo', 'action': widget.onUndo, 'enabled': widget.canUndo},
      {'icon': Icons.redo, 'label': '重做', 'tool':'redo', 'action': widget.onRedo, 'enabled': widget.canRedo},
      {'icon': Icons.delete, 'label': '清除', 'tool':'clear', 'action': widget.onClear, 'enabled': true},
      {'icon': Icons.save, 'label': '保存', 'tool':'save', 'action': widget.onSave, 'enabled': true},
      {'icon': Icons.close, 'label': '关闭', 'tool':'close', 'action': widget.onClose, 'enabled': true},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Row(children: _buildToolButtons(tools),),
          Row(children: _buildActionButtons(actions),),
        ],
      ),
    );
    // return Container(
    //   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    //   decoration: BoxDecoration(
    //     color: Colors.black.withOpacity(0.7),
    //     borderRadius: BorderRadius.circular(25),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withOpacity(0.3),
    //         blurRadius: 10,
    //         offset: Offset(0, 4),
    //       ),
    //     ],
    //   ),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       Row(
    //         children: [
    //           IconButton(
    //             icon: Icon(Icons.undo, color: canUndo ? Colors.white : Colors.grey),
    //             onPressed: canUndo ? onUndo : null,
    //           ),
    //           SizedBox(width: 10),
    //           IconButton(
    //             icon: Icon(Icons.redo, color: canRedo ? Colors.white : Colors.grey),
    //             onPressed: canRedo ? onRedo : null,
    //           ),
    //           SizedBox(width: 10),
    //           IconButton(
    //             icon: Icon(Icons.delete, color: Colors.white),
    //             onPressed: onClear,
    //           ),
    //         ],
    //       ),
    //       Row(
    //         children: [
    //           IconButton(
    //             icon: Icon(Icons.save, color: Colors.white),
    //             onPressed: onSave,
    //           ),
    //           SizedBox(width: 10),
    //           IconButton(
    //             icon: Icon(Icons.close, color: Colors.white),
    //             onPressed: onClose,
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );

  }

  Widget _buildToolButton(IconData icon, String tooltip, String tool,
      {bool isSelected = false}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          widget.onToolSelected(isSelected ? null : tool);
          // setState(() {
          // });
        },
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[300],
            size: 22,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildToolButtons( List<Map<String, dynamic>> tools ) {
    return tools.map((tool) {
      return Row(
        children: [
          _buildToolButton(
            tool['icon'],
            tool['label'],
            tool['tool'],
            isSelected: tool['tool'] == widget.selectedTool,

          ),
          SizedBox(height: 15),
        ],
      );
    }).toList();
  }

  Widget _buildActionButton(IconData icon, String tooltip, String tool,
      {VoidCallback? onpressed}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onpressed,
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.grey[300],
            size: 22,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons( List<Map<String, dynamic>> actions ) {
    return actions.map((action){
      return Row(
        children: [
          _buildActionButton( action['icon'], action['label'], action['tool'], onpressed: action['enabled'] ? action['action'] : null ),
          SizedBox(height: 15),
        ],
      );
    }).toList();
  }
}




// class DrawingPoint {
//   Offset offset;
//   Color color;
//   double strokeWidth;
//   String tool;

//   DrawingPoint({
//     required this.offset,
//     required this.color,
//     required this.strokeWidth,
//     required this.tool,
//   });
// }

// class DrawingPath {
//   List<DrawingPoint> points = [];
//   Color color;
//   double strokeWidth;
//   String tool;

//   DrawingPath({
//     required this.color,
//     required this.strokeWidth,
//     required this.tool,
//   });
// }

// class ScreenshotEditor extends StatefulWidget {
//   @override
//   _ScreenshotEditorState createState() => _ScreenshotEditorState();
// }

// class _ScreenshotEditorState extends State<ScreenshotEditor> {
//   // 全局Key用于截图
//   GlobalKey _globalKey = GlobalKey();

//   // 绘图相关状态
//   List<DrawingPath> paths = [];
//   List<DrawingPath> redoPaths = [];
//   String selectedTool = 'pen';
//   Color selectedColor = Colors.red;
//   double strokeWidth = 3.0;
//   bool isDrawing = false;
//   Offset? currentOffset;
//   TextEditingController? textController;
//   Offset? textPosition;
//   bool showTextInput = false;

//   // 颜色列表
//   List<Color> colors = [
//     Colors.red,
//     Colors.orange,
//     Colors.yellow,
//     Colors.green,
//     Colors.blue,
//     Colors.indigo,
//     Colors.purple,
//     Colors.white,
//     Colors.black,
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[900],
//       body: Stack(
//         children: [
//           // 可绘制的截屏区域
//           RepaintBoundary(
//             key: _globalKey,
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               child: GestureDetector(
//                 onPanStart: _onPanStart,
//                 onPanUpdate: _onPanUpdate,
//                 onPanEnd: _onPanEnd,
//                 onTapDown: _onTapDown,
//                 child: CustomPaint(
//                   painter: DrawingPainter(
//                     paths: paths,
//                     textPosition: textPosition,
//                     textContent: textController?.text,
//                     textColor: selectedColor,
//                   ),
//                   // child: Container(
//                   //   decoration: BoxDecoration(
//                   //     image: DecorationImage(
//                   //       image: AssetImage(
//                   //           'assets/images/capture.png'),
//                   //       fit: BoxFit.cover,
//                   //     ),
//                   //   ),
//                   // ),
//                 ),
//               ),
//             ),
//           ),

//           // 文本输入框
//           if (showTextInput && textPosition != null)
//             Positioned(
//               left: textPosition!.dx,
//               top: textPosition!.dy,
//               child: Container(
//                 width: 200,
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: TextField(
//                   controller: textController,
//                   style: TextStyle(color: selectedColor, fontSize: 16),
//                   decoration: InputDecoration(
//                     hintText: '输入文字...',
//                     hintStyle: TextStyle(color: Colors.grey),
//                     border: InputBorder.none,
//                   ),
//                   autofocus: true,
//                   onSubmitted: (value) {
//                     setState(() {
//                       showTextInput = false;
//                     });
//                   },
//                 ),
//               ),
//             ),

//           // 顶部工具条
//           Positioned(
//             top: 50,
//             left: 20,
//             right: 20,
//             child: _buildTopToolbar(),
//           ),

//           // 左侧工具条
//           Positioned(
//             left: 20,
//             top: MediaQuery.of(context).size.height / 2 - 100,
//             child: _buildLeftToolbar(),
//           ),

//           // 底部工具条
//           Positioned(
//             bottom: 30,
//             left: 20,
//             right: 20,
//             child: _buildBottomToolbar(),
//           ),

//           // 颜色选择工具条
//           if (selectedTool == 'pen' || selectedTool == 'highlighter' || selectedTool == 'text')
//             Positioned(
//               bottom: 100,
//               left: 0,
//               right: 0,
//               child: _buildColorToolbar(),
//             ),
//         ],
//       ),
//     );
//   }

//   // 绘图相关方法
//   void _onPanStart(DragStartDetails details) {
//     if (selectedTool == 'text') return;

//     setState(() {
//       isDrawing = true;
//       redoPaths.clear();
      
//       if (selectedTool == 'pen' || selectedTool == 'highlighter') {
//         paths.add(DrawingPath(
//           color: selectedColor,
//           strokeWidth: strokeWidth,
//           tool: selectedTool,
//         ));
        
//         paths.last.points.add(DrawingPoint(
//           offset: details.localPosition,
//           color: selectedColor,
//           strokeWidth: strokeWidth,
//           tool: selectedTool,
//         ));
//       } else {
//         currentOffset = details.localPosition;
//       }
//     });
//   }

//   void _onPanUpdate(DragUpdateDetails details) {
//     if (!isDrawing || selectedTool == 'text') return;

//     setState(() {
//       if (selectedTool == 'pen' || selectedTool == 'highlighter') {
//         paths.last.points.add(DrawingPoint(
//           offset: details.localPosition,
//           color: selectedColor,
//           strokeWidth: strokeWidth,
//           tool: selectedTool,
//         ));
//       } else {
//         currentOffset = details.localPosition;
//       }
//     });
//   }

//   void _onPanEnd(DragEndDetails details) {
//     if (selectedTool == 'text') return;

//     setState(() {
//       isDrawing = false;
//       if (selectedTool != 'pen' && selectedTool != 'highlighter' && currentOffset != null) {
//         // 对于形状工具，添加完整的路径
//         paths.add(DrawingPath(
//           color: selectedColor,
//           strokeWidth: strokeWidth,
//           tool: selectedTool,
//         ));
        
//         paths.last.points.add(DrawingPoint(
//           offset: currentOffset!,
//           color: selectedColor,
//           strokeWidth: strokeWidth,
//           tool: selectedTool,
//         ));
//       }
//       currentOffset = null;
//     });
//   }

//   void _onTapDown(TapDownDetails details) {
//     if (selectedTool == 'text') {
//       setState(() {
//         textPosition = details.localPosition;
//         textController = TextEditingController();
//         showTextInput = true;
//       });
//     }
//   }

//   // 工具方法
//   void _undo() {
//     if (paths.isNotEmpty) {
//       setState(() {
//         redoPaths.add(paths.removeLast());
//       });
//     }
//   }

//   void _redo() {
//     if (redoPaths.isNotEmpty) {
//       setState(() {
//         paths.add(redoPaths.removeLast());
//       });
//     }
//   }

//   void _clearAll() {
//     setState(() {
//       paths.clear();
//       redoPaths.clear();
//       showTextInput = false;
//       textPosition = null;
//     });
//   }

//   Future<void> _saveImage() async {
//     try {
//       // 请求存储权限
//       // var status = await Permission.storage.request();
//       // if (!status.isGranted) {
//       //   _showSnackBar('需要存储权限来保存图片');
//       //   return;
//       // }

//       // 截取屏幕
//       RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       Uint8List pngBytes = byteData!.buffer.asUint8List();

//       // 保存到相册
//       // final result = await ImageGallerySaver.saveImage(pngBytes);
      
//       // if (result['isSuccess']) {
//       //   _showSnackBar('图片保存成功');
//       // } else {
//       //   _showSnackBar('保存失败');
//       // }
//     } catch (e) {
//       _showSnackBar('保存出错: $e');
//     }
//   }

//   Future<void> _shareImage() async {
//     // 这里可以集成分享插件，如 share_plus
//     _showSnackBar('分享功能准备中...');
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   // 工具栏构建方法
//   Widget _buildTopToolbar() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               _buildIconButton(
//                 Icons.undo, 
//                 '撤销', 
//                 paths.isNotEmpty ? _undo : null,
//                 isActive: paths.isNotEmpty,
//               ),
//               SizedBox(width: 10),
//               _buildIconButton(
//                 Icons.redo, 
//                 '重做', 
//                 redoPaths.isNotEmpty ? _redo : null,
//                 isActive: redoPaths.isNotEmpty,
//               ),
//               SizedBox(width: 10),
//               _buildIconButton(
//                 Icons.delete, 
//                 '清除', 
//                 paths.isNotEmpty || textPosition != null ? _clearAll : null,
//                 isActive: paths.isNotEmpty || textPosition != null,
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               _buildIconButton(Icons.save, '保存', _saveImage),
//               SizedBox(width: 10),
//               _buildIconButton(Icons.share, '分享', _shareImage),
//               SizedBox(width: 10),
//               _buildIconButton(Icons.close, '关闭', () {
//                 Navigator.of(context).pop();
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLeftToolbar() {
//     List<Map<String, dynamic>> tools = [
//       {'icon': Icons.edit, 'label': '画笔', 'tool': 'pen'},
//       {'icon': Icons.brush, 'label': '荧光笔', 'tool': 'highlighter'},
//       {'icon': Icons.horizontal_rule, 'label': '直线', 'tool': 'line'},
//       {'icon': Icons.crop_square, 'label': '矩形', 'tool': 'rectangle'},
//       {'icon': Icons.panorama_fish_eye, 'label': '椭圆', 'tool': 'ellipse'},
//       {'icon': Icons.text_fields, 'label': '文本', 'tool': 'text'},
//       {'icon': Icons.arrow_right_alt, 'label': '箭头', 'tool': 'arrow'},
//       {'icon': Icons.blur_on, 'label': '模糊', 'tool': 'blur'},
//     ];

//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: tools.map((tool) {
//           return Column(
//             children: [
//               _buildToolButton(
//                 tool['icon'],
//                 tool['label'],
//                 tool['tool'],
//                 isSelected: selectedTool == tool['tool'],
//               ),
//               SizedBox(height: 15),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildBottomToolbar() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           if (selectedTool == 'pen' || selectedTool == 'highlighter')
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   '粗细',
//                   style: TextStyle(color: Colors.white, fontSize: 14),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Slider(
//                     value: strokeWidth,
//                     min: 1,
//                     max: selectedTool == 'highlighter' ? 30 : 20,
//                     divisions: 19,
//                     onChanged: (value) {
//                       setState(() {
//                         strokeWidth = value;
//                       });
//                     },
//                     activeColor: Colors.white,
//                     inactiveColor: Colors.grey,
//                   ),
//                 ),
//                 Container(
//                   width: 30,
//                   height: 30,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text(
//                       strokeWidth.round().toString(),
//                       style: TextStyle(fontSize: 12, color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           if (selectedTool == 'pen' || selectedTool == 'highlighter') 
//             SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildIconButton(Icons.crop, '裁剪', () {
//                 _showSnackBar('裁剪功能准备中...');
//               }),
//               _buildIconButton(Icons.rotate_left, '旋转', () {
//                 _showSnackBar('旋转功能准备中...');
//               }),
//               _buildIconButton(Icons.filter, '滤镜', () {
//                 _showSnackBar('滤镜功能准备中...');
//               }),
//               _buildIconButton(Icons.format_color_text, '文字颜色', () {
//                 setState(() {
//                   selectedTool = 'text';
//                 });
//               }),
//               _buildIconButton(Icons.more_horiz, '更多', () {
//                 _showMoreOptions();
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildColorToolbar() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 50),
//       padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: colors.map((color) {
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedColor = color;
//               });
//             },
//             child: Container(
//               width: 30,
//               height: 30,
//               decoration: BoxDecoration(
//                 color: color,
//                 shape: BoxShape.circle,
//                 border: color == Colors.white || color == Colors.yellow
//                     ? Border.all(color: Colors.grey, width: 1)
//                     : null,
//               ),
//               child: selectedColor == color
//                   ? Icon(Icons.check, color: getContrastColor(color), size: 18)
//                   : null,
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildToolButton(IconData icon, String tooltip, String tool,
//       {bool isSelected = false}) {
//     return Tooltip(
//       message: tooltip,
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             selectedTool = tool;
//             showTextInput = false;
//           });
//         },
//         child: Container(
//           width: 45,
//           height: 45,
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.blue : Colors.transparent,
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             icon,
//             color: isSelected ? Colors.white : Colors.grey[300],
//             size: 22,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildIconButton(IconData icon, String tooltip, VoidCallback? onPressed,
//       {bool isActive = true}) {
//     return Tooltip(
//       message: tooltip,
//       child: IconButton(
//         icon: Icon(icon, 
//           color: isActive ? Colors.white : Colors.grey,
//         ),
//         onPressed: onPressed,
//         iconSize: 22,
//       ),
//     );
//   }

//   void _showMoreOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           height: 200,
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.8),
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             children: [
//               ListTile(
//                 leading: Icon(Icons.settings, color: Colors.white),
//                 title: Text('设置', style: TextStyle(color: Colors.white)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showSnackBar('设置功能准备中...');
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.help, color: Colors.white),
//                 title: Text('帮助', style: TextStyle(color: Colors.white)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showSnackBar('帮助文档准备中...');
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.info, color: Colors.white),
//                 title: Text('关于', style: TextStyle(color: Colors.white)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showSnackBar('截屏工具 v1.0.0');
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Color getContrastColor(Color color) {
//     double luminance = color.computeLuminance();
//     return luminance > 0.5 ? Colors.black : Colors.white;
//   }
// }

// // 自定义绘图器
// class DrawingPainter extends CustomPainter {
//   final List<DrawingPath> paths;
//   final Offset? textPosition;
//   final String? textContent;
//   final Color textColor;

//   DrawingPainter({
//     required this.paths,
//     this.textPosition,
//     this.textContent,
//     required this.textColor,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // 绘制所有路径
//     for (var path in paths) {
//       final paint = Paint()
//         ..color = path.tool == 'highlighter' 
//             ? path.color.withOpacity(0.3) 
//             : path.color
//         ..strokeWidth = path.strokeWidth
//         ..strokeCap = StrokeCap.round
//         ..strokeJoin = StrokeJoin.round
//         ..style = PaintingStyle.stroke;

//       if (path.tool == 'highlighter') {
//         paint.blendMode = BlendMode.multiply;
//       }

//       if (path.points.isNotEmpty) {
//         if (path.tool == 'pen' || path.tool == 'highlighter') {
//           // 自由绘制
//           for (int i = 0; i < path.points.length - 1; i++) {
//             canvas.drawLine(
//               path.points[i].offset,
//               path.points[i + 1].offset,
//               paint,
//             );
//           }
//         } else if (path.tool == 'line' && path.points.length >= 2) {
//           // 直线
//           canvas.drawLine(path.points.first.offset, path.points.last.offset, paint);
//         } else if (path.tool == 'rectangle' && path.points.length >= 2) {
//           // 矩形
//           final rect = Rect.fromPoints(path.points.first.offset, path.points.last.offset);
//           canvas.drawRect(rect, paint);
//         } else if (path.tool == 'ellipse' && path.points.length >= 2) {
//           // 椭圆
//           final rect = Rect.fromPoints(path.points.first.offset, path.points.last.offset);
//           canvas.drawOval(rect, paint);
//         } else if (path.tool == 'arrow' && path.points.length >= 2) {
//           // 箭头
//           _drawArrow(canvas, path.points.first.offset, path.points.last.offset, paint);
//         }
//       }
//     }

//     // 绘制文本
//     if (textPosition != null && textContent != null && textContent!.isNotEmpty) {
//       final textPainter = TextPainter(
//         text: TextSpan(
//           text: textContent,
//           style: TextStyle(
//             color: textColor,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//       );
//       textPainter.layout();
//       textPainter.paint(canvas, textPosition!);
//     }
//   }

//   void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
//     // 绘制直线
//     canvas.drawLine(start, end, paint);

//     // 绘制箭头头部
//     final angle = (end - start).direction;
//     const arrowLength = 15.0;
//     const arrowAngle = 0.5;

//     final arrowEnd1 = end - Offset(
//       arrowLength * cos(angle - arrowAngle),
//       arrowLength * sin(angle - arrowAngle),
//     );
//     final arrowEnd2 = end - Offset(
//       arrowLength * cos(angle + arrowAngle),
//       arrowLength * sin(angle + arrowAngle),
//     );

//     canvas.drawLine(end, arrowEnd1, paint);
//     canvas.drawLine(end, arrowEnd2, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }