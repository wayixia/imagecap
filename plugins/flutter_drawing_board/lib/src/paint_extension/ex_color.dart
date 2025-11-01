/*
  @override
  String toString() => 'Color(0x${value.toRadixString(16).padLeft(8, '0')})';

  @override
  String toString() => '${objectRuntimeType(this, 'ColorSwatch')}(primary value: ${super.toString()})';
*/

import 'dart:ui';

Color? stringToColor(String data) {
  if (data.startsWith('Color(0x')) {
    return Color(int.parse(data.split('0x')[1].split(')')[0], radix: 16));
  } else if (data.startsWith('ColorSwatch')) {
    return stringToColor(data.split('primary value: ')[1]);
  }

  return null;
}

int colorToInt(Color color) {
  return (color.a * 255).toInt() << 24 |
      (color.r * 255).toInt() << 16 |
      (color.g * 255).toInt() << 8 |
      (color.b * 255).toInt();
}
