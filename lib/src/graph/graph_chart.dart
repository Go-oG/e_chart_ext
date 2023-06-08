import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'graph_series.dart';

class GraphView extends SeriesView<GraphSeries> {
  GraphView(super.series);

  RectGesture gesture = RectGesture();

  @override
  void onStart() {
    super.onStart();
    unBindSeries();
    series.addListener(handleSeriesCommand);
    series.layout.addListener(handleLayoutCommand);
    context.addGesture(gesture);
    series.bindGesture(this, gesture);
  }

  void handleSeriesCommand(Command c) {
    if (c.code == Command.reLayout) {
      series.layout.stopLayout();
      series.layout.doLayout(context, series.graph, width, height);
    }
  }

  void handleLayoutCommand() {
    invalidate();
  }

  @override
  void onStop() {
    series.removeListener(handleSeriesCommand);
    series.layout.removeListener(handleLayoutCommand);
    super.onStop();
  }

  @override
  void onDestroy() {
    series.dispose();
    super.onDestroy();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    gesture.rect = areaBounds;
    series.layout.stopLayout();
    series.layout.doLayout(context, series.graph, width, height);
  }

  @override
  void onDraw(Canvas canvas) {
    Offset offset = series.layout.getTranslationOffset(width, height);
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    for (var edge in series.graph.edges) {
      var source = edge.source;
      var target = edge.target;
      LineStyle? style = series.lineFun?.call(source, target);
      if (style == null) {
        continue;
      }
      Line line;
      if (edge.points.length <= 2) {
        line = Line([Offset(source.x, source.y), Offset(target.x, target.y)]);
      } else {
        line = Line(edge.points);
      }
      style.drawPath(canvas, mPaint, line.toPath(false), drawDash: true);
    }
    for (var node in series.graph.nodes) {
      Offset offset = Offset(node.x, node.y);
      ChartSymbol symbol = series.symbolFun.call(node, series.layout.getNodeSize(node));
      symbol.draw(canvas, mPaint, offset);
    }
    canvas.restore();
  }
}
