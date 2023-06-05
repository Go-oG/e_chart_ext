import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import '../model/tree_data.dart';
import 'pack_node.dart';

class PackSeries extends RectSeries {
  TreeData data;
  bool optTextDraw;
  Color? backgroundColor;
  Fun1<PackNode, AreaStyle> areaStyleFun;
  Fun1<PackNode, LabelStyle?>? labelStyleFun;
  Fun1<PackNode, num>? paddingFun;
  Fun1<PackNode, num>? radiusFun;
  Fun2<PackNode, PackNode, int>? sortFun;
  ValueCallback<TreeData>? onClick;

  PackSeries(
    this.data, {
    this.optTextDraw = true,
    this.radiusFun,
    required this.areaStyleFun,
    this.labelStyleFun,
    this.paddingFun,
    this.sortFun,
    this.backgroundColor,
    this.onClick,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.touch,
    super.tooltip,
    super.clip,
    super.z,
  }) : super(parallelIndex: -1, polarAxisIndex: -1, calendarIndex: -1, coordSystem: null, xAxisIndex: -1, yAxisIndex: -1, radarIndex: -1);
}