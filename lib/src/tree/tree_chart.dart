import 'package:flutter/material.dart';
import 'package:e_chart/e_chart.dart';
import 'node.dart';
import 'tree_layout.dart';
import 'tree_series.dart';

class TreeView extends SeriesView<TreeSeries> {
  TreeView(super.series);

  Offset transOffset = Offset.zero;

  @override
  void onAttach() {
    super.onAttach();
    series.layout.addListener(handleLayoutCommand);
  }

  @override
  void onSeriesConfigChangeCommand() {
    series.layout.removeListener(handleLayoutCommand);
    series.layout.addListener(handleLayoutCommand);
    super.onSeriesConfigChangeCommand();
  }

  void handleLayoutCommand() {
    Command command = series.layout.value;
    if (command.code == TreeLayout.layoutEnd) {
      invalidate();
    } else if (command.code == TreeLayout.layoutUpdate) {
      invalidate();
    }
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
      debugPrint('无法找到点击节点');
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
    double width = this.width * 0.8;
    double height = this.height * 0.8;
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
    canvas.restore();
  }

  void drawSymbol(Canvas canvas, TreeLayoutNode node) {
    Offset offset = node.position;
    if (offset.dx.isNaN || offset.dy.isNaN) {
      return;
    }
    Size nodeSize = series.layout.getNodeSize(node);
    series.symbolFun.call(node, nodeSize, null)!.draw(canvas, mPaint, offset);
    String label = node.data.label ?? '';
    if (label.isEmpty) {
      return;
    }
    LabelStyle? style = series.labelStyleFun?.call(node, null);
    TextDrawConfig config = TextDrawConfig(node.position);
    style?.draw(canvas, mPaint, label, config);
  }

  void drawLine(Canvas canvas, TreeLayoutNode parent, TreeLayoutNode child) {
    Path? path = series.layout.getPath(parent, child);
    if (path != null) {
      series.lineStyleFun.call(parent, child, null)?.drawPath(canvas, mPaint, path);
    }
  }
}
