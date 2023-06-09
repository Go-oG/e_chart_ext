import 'package:flutter/material.dart';
import 'package:e_chart/e_chart.dart';
import 'node.dart';
import 'tree_series.dart';

class TreeView extends SeriesView<TreeSeries> {
  TreeView(super.series);

  Offset transOffset = Offset.zero;

  @override
  void onStart() {
    super.onStart();
    series.layout.addListener(handleLayoutCommand);
  }

  @override
  void onStop() {
    series.layout.removeListener(handleLayoutCommand);
    super.onStop();
  }

  void handleLayoutCommand() {
    Command command = series.layout.value;
    invalidate();
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    transOffset = transOffset.translate(diff.dx, diff.dy);
    invalidate();
  }

  @override
  void onClick(Offset offset) {
    offset = offset.translate(-transOffset.dx, -transOffset.dy);
    TreeLayoutNode? node = series.layout.findNode(offset);
    if (node == null) {
      debugPrint('无法找到点击节点:$offset');
      return;
    }
    if (node.notChild) {
      series.layout.expandNode(node);
      return;
    }
    series.layout.collapseNode(node);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    var treeLayout = series.layout;
    treeLayout.doLayout(context, series.data, width, height);
    transOffset = treeLayout.translationOffset;
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    canvas.translate(transOffset.dx, transOffset.dy);

    List<TreeLayoutNode> leaves = series.layout.rootNode.leaves();
    List<TreeLayoutNode> pres = [];
    while (leaves.isNotEmpty) {
      for (var node in leaves) {
        if (node.parent != null) {
          drawLine(canvas, node.parent!, node);
          pres.add(node.parent!);
        }
      }
      leaves = pres;
      pres = [];
    }
    series.layout.rootNode.each((node, index, startNode) {
      drawSymbol(canvas, node);
      return false;
    });

    Rect rect = series.layout.rootNode.getBoundBox();
    mPaint.style = PaintingStyle.stroke;
    mPaint.strokeWidth = 1;
    mPaint.color = Colors.deepPurple;
    canvas.drawRect(rect, mPaint);
    mPaint.style = PaintingStyle.fill;
    canvas.drawCircle(rect.center, 8, mPaint);
    canvas.restore();

    debugDraw(canvas, Offset(centerX, centerY));
  }

  void drawSymbol(Canvas canvas, TreeLayoutNode node) {
    Offset offset = node.center;
    if (offset.dx.isNaN || offset.dy.isNaN) {
      return;
    }
    Size nodeSize = node.size;
    series.symbolFun.call(node, nodeSize, null)!.draw(canvas, mPaint, offset);
    DynamicText label = node.data.label ?? DynamicText.empty;
    if (label.isEmpty) {
      return;
    }
    LabelStyle? style = series.labelStyleFun?.call(node, null);
    TextDrawConfig config = TextDrawConfig(offset);
    style?.draw(canvas, mPaint, label, config);
  }

  void drawLine(Canvas canvas, TreeLayoutNode parent, TreeLayoutNode child) {
    Path? path = series.layout.getPath(parent, child);
    if (path != null) {
      series.lineStyleFun.call(parent, child, null)?.drawPath(canvas, mPaint, path);
    }
  }
}
