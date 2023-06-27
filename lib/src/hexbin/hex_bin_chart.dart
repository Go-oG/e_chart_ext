import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'hex_bin_node.dart';
import 'hex_bin_series.dart';

class HexbinView extends SeriesView<HexbinSeries> {
  List<HexbinNode> nodeList = [];
  HexbinView(super.series);

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    nodeList=[];
    for (var data in series.data) {
      nodeList.add(HexbinNode(data));
    }
    series.layout.doLayout(context,series, nodeList, selfBoxBound,LayoutAnimatorType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    for (var node in nodeList) {
      AreaStyle style = series.styleFun.call(node);
      if (style.show) {
        Path path = node.shape.toPath(true);
        style.drawPath(canvas, mPaint, path);
      }
      DynamicText? s = node.data.label;
      if (s == null || s.isEmpty) {
        continue;
      }
      LabelStyle? labelStyle = series.labelStyleFun?.call(node);
      if (labelStyle != null && labelStyle.show) {
        TextDrawConfig config = TextDrawConfig(node.center, textAlign: TextAlign.center);
        labelStyle.draw(canvas, mPaint, s, config);
      }
    }
  }
}
