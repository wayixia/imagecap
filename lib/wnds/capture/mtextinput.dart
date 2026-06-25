import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imagecap/utils/text_helper.dart';

class MTextInput extends StatefulWidget {
  final TextEditingController textController;
  final TextStyle textStyle;
  final Key? mkey;
  final FocusNode? focusNode; // = FocusNode();
  const MTextInput({
    super.key,
    this.mkey,
    this.focusNode,
    required this.textController,
    required this.textStyle,


  });
  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<MTextInput> {
  //final FocusNode _focusNode = FocusNode();

  // 校验是否超出最大高度
  bool _isOverHeight(String text, Size size) {
    // 计算行数
    double actualHeight = TextHelper.getActualHeight(text, widget.textStyle, size.width);
    //int lineCount = '\n'.allMatches(text).length + 1;
    //return lineCount * _lineHeight > (_selectionRect!.bottom-_drawStartPoint.dy);
    return actualHeight > size.height;
    //return actualHeight > (_selectionRect!.bottom-_drawStartPoint.dy);
  }

  @override
  void initState() {
    super.initState();

    // 为 FocusNode 添加 onKey 监听
    // _focusNode.onKey = (FocusNode node, RawKeyEvent event) {
    //   if (event is RawKeyDownEvent) {
    //     RenderBox rb = context.findRenderObject() as RenderBox;
    //     if( _isOverHeight(widget.textController.text, rb.size) )
    //     {
    //       print('超出高度，禁止输入');
    //       return KeyEventResult.handled; // 阻止输入
    //     }
    //     //print('按下的键 (FocusNode): ${event.logicalKey}');
    //     print('width: ${rb.size}, text: ${widget.textController.text}');
    //     // 返回 true 表示事件已被处理，TextField 将不再处理该事件[reference:6]
    //     // 返回 false 则事件会继续传递给 TextField
    //     //return KeyEventResult.handled; // 或者 return true;
    //   }
    //   return KeyEventResult.ignored; // 或者 return false;
    // };
  }

  @override
  void dispose() {
    //widget.focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField( 
      autofocus: true,
      key: widget.mkey,
      focusNode: widget.focusNode,
      controller: widget.textController,
      // 核心：拦截输入，超限禁止
      onChanged: (value) {
        RenderBox rb = context.findRenderObject() as RenderBox;
          if (_isOverHeight(value, rb.size)) {
            // 超出高度，截断内容，禁止新增
            String lastValidText = widget.textController.text;
            widget.textController.text = lastValidText;
            // 光标定位末尾
            widget.textController.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.textController.text.length),
            );
            return;
          }
          setState(() {});
        },
        minLines: 1,
        maxLines: null,
        // 禁止手动回车换行
        textInputAction: TextInputAction.done,
        style: widget.textStyle,
        decoration: const InputDecoration(
          hintText: "Enter text",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          isDense: true,
          fillColor: Colors.transparent,
          filled: true,
        ),
    );
  }
}


