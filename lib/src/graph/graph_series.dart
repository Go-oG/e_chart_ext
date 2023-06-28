import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import '../model/graph/graph.dart';
import '../model/graph/graph_node.dart';
import 'graph_layout.dart';

class GraphSeries extends RectSeries with SeriesGesture {
  Graph graph;
  GraphLayout layout;
  Fun3<GraphNode, Size, ChartSymbol> symbolFun;
  Fun3<GraphNode, GraphNode, LineStyle>? lineFun;

  GraphSeries(
    this.graph,
    this.layout, {
    required this.symbolFun,
    this.lineFun,
    super.animation,
    super.backgroundColor,
    super.bottomMargin,
    super.calendarIndex,
    super.clip,
    super.coordSystem,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.height,
    super.id,
    super.leftMargin,
    super.parallelIndex,
    super.polarAxisIndex,
    super.radarIndex,
    super.rightMargin,
    super.tooltip,
    super.topMargin,
    super.width,
    super.xAxisIndex,
    super.yAxisIndex,
    super.z,
  });

  @override
  void dispose() {
    layout.dispose();
    clearGesture();
    super.dispose();
  }
}
