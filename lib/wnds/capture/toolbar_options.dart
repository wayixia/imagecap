import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';


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
    Colors.white,
    Colors.black,
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
      child: 
          GridView.count(
            crossAxisCount: 4, 
            children: _buildColorButtons(colors))
          //Row(children: _buildColorButtons(colors),),
          //Row(children: _buildActionButtons(actions),),
    );
  }

  List<Widget> _buildColorButtons(List<Color> colors) {
    return colors.map((color) {
      return Center(
        child: _buildColorButton(
            Icons.check,
            "",
            color,
            isSelected: color == widget.selectedColor,
        ),
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
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
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


