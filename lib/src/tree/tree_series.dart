import 'package:e_chart/e_chart.dart';
import 'node.dart';
import 'tree_layout.dart';
import '../model/tree_data.dart';
class TreeSeries extends RectSeries {
  TreeData data;
  TreeLayout<TreeLayoutNode> layout;
  LineType lineType;
  SelectedMode selectedMode;
  StyleFun<TreeLayoutNode, ChartSymbol> symbolStyleFun;
  StyleFun<TreeLayoutNode, LabelStyle>? labelStyleFun;
  StyleFun2<TreeLayoutNode, TreeLayoutNode, LineStyle> lineStyleFun;

  TreeSeries(
    this.data,
    this.layout, {
    this.selectedMode = SelectedMode.single,
    this.lineType = LineType.step,
    required this.symbolStyleFun,
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
    super.touch,
    super.clip,
    super.z,
  }) : super(xAxisIndex: -1, yAxisIndex: -1, calendarIndex: -1, parallelIndex: -1, polarAxisIndex: -1, radarIndex: -1);
}

enum LineType { line, stepAfter, step, stepBefore }
