import 'dart:math';
import 'dart:ui';

class Ellipse {
  final Offset center;
  final double a; // 半长轴
  final double b; // 半短轴
  
  Ellipse(this.center, this.a, this.b);
  
  // 判断点是否在椭圆内部或边缘上
  bool containsPoint(Offset point, {double tolerance = 1e-10}) {
    // 使用椭圆方程 (x - h)²/a² + (y - k)²/b² = 1
    // 其中 (h, k) 是椭圆中心，a 是半长轴，b 是半短轴
    // tolerance 用于处理浮点数精度问题
    if (a <= 0 || b <= 0) {
      return false;
      //throw ArgumentError('半长轴和半短轴必须大于零');
    }

    // Y轴对称性处理
    double expectedY = center.dy + b * sqrt(1 - pow((point.dx - center.dx) / a, 2));
    double expectedY2 = center.dy - b * sqrt(1 - pow((point.dx - center.dx) / a, 2));

    if( (point.dy >= (expectedY - tolerance) ) && point.dy <= ( expectedY + tolerance) ) {
      return true;
    }
    if( (point.dy >= (expectedY2 - tolerance) ) && point.dy <= ( expectedY2 + tolerance )) {
      return true;
    }

    // X轴对称性处理
    double expectedX = center.dx + a * sqrt(1 - pow((point.dy - center.dy) / b, 2));
    double expectedX2 = center.dx - a * sqrt(1 - pow((point.dy - center.dy) / b, 2));

    if( (point.dx >= (expectedX - tolerance) ) && point.dx <= ( expectedX + tolerance) ) {
      return true;
    }
    if( (point.dx >= (expectedX2 - tolerance) ) && point.dx <= ( expectedX2 + tolerance )) {
      return true;
    }

    return false;
  }
  
  // 判断点是否严格在椭圆内部（不包括边缘）
  bool containsPointStrictly(Offset point) {
    final double value = 
        pow(point.dx - center.dx, 2) / pow(a, 2) + 
        pow(point.dy - center.dy, 2) / pow(b, 2);
    
    return value < 1.0;
  }
  
  // 获取点到椭圆边缘的关系
  String getPointRelation(Offset point, {double tolerance = 1e-10}) {
    final double value = 
        pow(point.dx - center.dx, 2) / pow(a, 2) + 
        pow(point.dy - center.dy, 2) / pow(b, 2);
    
    if ((value - 1.0).abs() < tolerance) {
      return '在椭圆边缘上';
    } else if (value < 1.0) {
      return '在椭圆内部';
    } else {
      return '在椭圆外部';
    }
  }
}