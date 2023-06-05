import 'dart:math';

import 'package:flutter/material.dart';
import 'package:e_chart/e_chart.dart';
abstract class GaugePoint {
  void draw(Canvas canvas, Paint paint, Offset center, double radius, double angle, Offset end);
}

class GaugePoint1 extends GaugePoint {
  final double outerRadius;
  final double innerRadius;
  final Color innerColor;
  final Color outerColor;
  final double angleSize;

  GaugePoint1({
    this.outerRadius = 15,
    this.innerRadius = 7,
    this.angleSize = 20,
    this.innerColor = Colors.white,
    this.outerColor = Colors.blueAccent,
  });

  @override
  void draw(Canvas canvas, Paint paint, Offset center, double radius, double angle, Offset end) {
    paint.reset();
    paint.style = PaintingStyle.fill;
    paint.color = outerColor;
    canvas.drawCircle(center, outerRadius, paint);
    double r = radius * 0.5;
    double unit = pi / 180;
    double x1 = outerRadius * cos((angle - angleSize / 2) * unit);
    double y1 = outerRadius * sin((angle - angleSize / 2) * unit);
    double x2 = outerRadius * cos((angle + angleSize / 2) * unit);
    double y2 = outerRadius * sin((angle + angleSize / 2) * unit);
    double x3 = r * cos((angle) * unit);
    double y3 = r * sin((angle) * unit);

    Path path = Path();
    path.moveTo(x1, y1);
    path.arcToPoint(Offset(x2, y2), radius: Radius.circular(outerRadius));
    path.lineTo(x3, y3);
    path.close();
    canvas.drawPath(path, paint);
    paint.color = innerColor;
    canvas.drawCircle(center, innerRadius, paint);
  }
}
