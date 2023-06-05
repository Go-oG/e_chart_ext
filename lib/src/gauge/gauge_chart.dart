import 'dart:math' as m;
import 'package:flutter/material.dart';
import 'package:e_chart/e_chart.dart';

import 'gauge_series.dart';

///仪表盘
class GaugeView extends  ChartView {
  final GaugeSeries series;
  final List<ArcAxisImpl> _angleAxisList = [];
  final ArcGesture gesture = ArcGesture();
  double radius = 0;

  GaugeView(this.series) {
    _angleAxisList.clear();
    for (var element in series.axisList) {
      _angleAxisList.add(ArcAxisImpl(element));
    }
  }

  @override
  void onAttach() {
    super.onAttach();
    context.addGesture(gesture);
    gesture.edgeFun = (offset) {
      return globalAreaBound.contains(offset);
    };
  }

  @override
  void onDetach() {
    series.dispose();
    _angleAxisList.clear();
    gesture.clear();
    context.removeGesture(gesture);
    super.onDetach();
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double size = m.min(parentWidth, parentHeight);
    radius = series.radius.convert(size);
    return Size(parentWidth, parentHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    radius = series.radius.convert(m.min(width, height));
    for (var ele in _angleAxisList) {
      ArcProps angleProps = ArcProps(
        Offset.zero,
        ele.axis.offsetAngle.toDouble(),
        radius + ele.axis.radiusOffset,
        sweepAngle: ele.axis.sweepAngle.toDouble(),
      );
      ele.layout(angleProps, [DynamicData(0), DynamicData(100)]);
    }
    gesture.startAngle = 0;
    gesture.sweepAngle = 360;
    gesture.innerRadius = 0;
    gesture.outerRadius = radius;
  }

  @override
  void onDraw(Canvas canvas) {
    double dx = series.center[0].convert(width);
    double dy = series.center[1].convert(height);
    canvas.save();
    canvas.translate(dx, dy);
    for (var element in _angleAxisList) {
      element.draw(canvas, mPaint);
    }
    for (var ele in series.groupList) {
      ArcAxisImpl node = _angleAxisList[ele.axisIndex];
      num angle = node.dataToAngle(ele.data);
      Offset o = circlePoint(radius, angle);
      ele.point?.draw(canvas, mPaint, Offset.zero, radius, angle.toDouble(), o);
    }
    canvas.restore();
  }
}
