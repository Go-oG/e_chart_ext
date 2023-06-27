import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'node.dart';
import 'tree_layout.dart';
import '../model/tree_data.dart';

class TreeSeries extends RectSeries {
  TreeData data;
  TreeLayout layout;
  SelectedMode selectedMode;
  Fun3<TreeLayoutNode, Size, ChartSymbol> symbolFun;
  Fun2<TreeLayoutNode, LabelStyle>? labelStyleFun;
  Fun3<TreeLayoutNode, TreeLayoutNode, LineStyle> lineStyleFun;

  TreeSeries(
    this.data,
    this.layout, {
    this.selectedMode = SelectedMode.single,
    required this.symbolFun,
    required this.lineStyleFun,
    this.labelStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.tooltip,
    super.animation,
    super.enableClick,
    super.enableDrag = true,
    super.enableHover,
    super.enableScale,
    super.clip,
    super.z,
  }) : super(xAxisIndex: -1, yAxisIndex: -1, calendarIndex: -1, parallelIndex: -1, polarAxisIndex: -1, radarIndex: -1);
}
