
import 'package:flutter/material.dart';


typedef ColorSelectedCallback = void Function(Color color);
typedef LineSizeSelectedCallback = void Function( int linesize );
typedef FontSizeSelectedCallback = void Function( int fontsize );


class CaptureToolbarOptions extends StatefulWidget {
  final ColorSelectedCallback onColorSelected;
  final LineSizeSelectedCallback onLineSizeSelected;
  final FontSizeSelectedCallback onFontSizeSelected;
  
  final Color selectedColor;
  final int lineSize;
  final int fontSize;


  const CaptureToolbarOptions({
    super.key,
    this.selectedColor = Colors.red,
    this.lineSize = 2,
    this.fontSize = 16,
    required this.onColorSelected,
    required this.onFontSizeSelected,
    required this.onLineSizeSelected,
  });


  
  @override
  State<StatefulWidget> createState() => _CaptureToolbarState();
}

class _CaptureToolbarState extends State<CaptureToolbarOptions> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    // 颜色列表 
    List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    //Colors.white,
    Colors.black,
    ];
 

    return Container(
      padding: EdgeInsets.fromLTRB( 10, 10, 10, 0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: 
        SizedBox(
        height: 60, 
        width: 240,
        
        child:
          GridView.count(
            shrinkWrap: true, // 让 GridView 根据内容调整大小
            physics: NeverScrollableScrollPhysics(), // 禁止滚动[citation:2]
            crossAxisCount: 8, 
            mainAxisSpacing: 3, // 主轴方向间距[citation:2]
            crossAxisSpacing: 0, // 交叉轴方向间距[citation:2]
            childAspectRatio: 1, // 宽高比，可根据内容调整
            children: _buildColorButtons(colors)
        )
      )
    );
  }

  List<Widget> _buildColorButtons(List<Color> colors) {
    return colors.map((color) {
      return  _buildColorButton(
            Icons.check,
            "",
            color,
            isSelected: color == widget.selectedColor,
        );
    }).toList();
  }


  Widget _buildColorButton(IconData icon, String tooltip, Color color,
      {bool isSelected = false}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          widget.onColorSelected(color);
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
          ),
          child: Icon(
            isSelected?icon:null,
            color: isSelected ? Colors.white : Colors.grey[300],
            size: 22,
          ),
        ),
      ),
    );
  }
}


