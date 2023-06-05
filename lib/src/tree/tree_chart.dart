import 'dart:math' as m;
import 'package:chart_xutil/chart_xutil.dart';
import 'package:flutter/material.dart';
import 'package:e_chart/e_chart.dart';
import 'node.dart';
import 'tree_series.dart';
import '../model/tree_data.dart';
class TreeView extends  ChartView {
  final TreeSeries series;
  late TreeLayoutNode _rootNode;
  final List<TreeLayoutNode> _nodeList = [];

  TreeView(this.series);

  RectGesture gesture = RectGesture();
  Offset transOffset = Offset.zero;
  Offset moveOffset = Offset.zero;

  @override
  void onAttach() {
    super.onAttach();
    series.layout.layoutEnd = () {
      invalidate();
    };
    series.layout.layoutUpdate = () {
      invalidate();
    };
    initListener();
  }

  void initListener() {
    context.addGesture(gesture);
    if (context.config.dragType == DragType.longPress) {
      gesture.longPressMove = (e) {
        var dx = e.offsetFromOrigin.dx - moveOffset.dx;
        var dy = e.offsetFromOrigin.dy - moveOffset.dy;
        moveOffset = e.offsetFromOrigin;
        transOffset = transOffset.translate(dx, dy);
        invalidate();
      };
      gesture.longPressEnd = (e) {
        cancelDrag();
      };
      gesture.longPressCancel = cancelDrag;
    } else {
      gesture.horizontalDragStart = (e) {
        moveOffset = e.globalPosition;
      };
      gesture.horizontalDragMove = (e) {
        var dx = e.globalPosition.dx - moveOffset.dx;
        var dy = e.globalPosition.dy - moveOffset.dy;
        moveOffset = e.globalPosition;
        transOffset = transOffset.translate(dx, dy);
        invalidate();
      };
      gesture.horizontalDragEnd = (e) {
        cancelDrag();
      };
      gesture.horizontalDragCancel = cancelDrag;

      gesture.verticalDragStart = (e) {
        moveOffset = e.globalPosition;
      };
      gesture.verticalDragMove = (e) {
        var dx = e.globalPosition.dx - moveOffset.dx;
        var dy = e.globalPosition.dy - moveOffset.dy;
        moveOffset = e.globalPosition;
        transOffset = transOffset.translate(dx, dy);
        invalidate();
      };
      gesture.verticalDragEnd = (e) {
        cancelDrag();
      };
      gesture.verticalDragCancel = cancelDrag;
    }
  }

  void cancelDrag() {
    moveOffset = Offset.zero;
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    gesture.rect = globalAreaBound;
    _rootNode = toTree<TreeData, TreeLayoutNode>(series.data, (p0) => p0.children, (p0, p1) => TreeLayoutNode(p0, p1));
    _nodeList.clear();
    _nodeList.addAll(_rootNode.descendants());
    _rootNode.leaves().forEach((leaf) {
      leaf.computeHeight(leaf);
    });
    double width = this.width * 0.8;
    double height = this.height * 0.8;
    series.layout.doLayout(context, _rootNode, width, height);
    num minLeft = _rootNode.x;
    num maxRight = _rootNode.x;
    num minTop = _rootNode.y;
    num maxBottom = _rootNode.y;
    _rootNode.each((node, index, startNode) {
      minLeft = m.min(minLeft, node.x);
      maxRight = m.max(maxRight, node.x);
      minTop = m.min(minTop, node.y);
      maxBottom = m.max(maxBottom, node.y);
      return false;
    });
    num w = maxRight - minLeft;
    num h = maxBottom - minTop;
    double tw = (this.width - w) / 2;
    double th = (this.height - h) / 2;
    _rootNode.each((node, index, startNode) {
      node.x += tw;
      node.y += th;
      return false;
    });
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    canvas.translate(transOffset.dx, transOffset.dy);
    List<TreeLayoutNode> leaves = _rootNode.leaves();
    List<TreeLayoutNode> pres = [];
    while (leaves.isNotEmpty) {
      for (var node in leaves) {
        if (node.parent != null) {
          _drawLine(canvas, node, node.parent!);
          pres.add(node.parent!);
        }
      }
      leaves = pres;
      pres = [];
    }
    for (var element in _nodeList) {
      _drawSymbol(canvas, element);
    }
    canvas.restore();
  }

  void _drawSymbol(Canvas canvas, TreeLayoutNode node) {
    Offset offset = node.position;
    if (offset.dx.isNaN || offset.dy.isNaN) {
      return;
    }
    if (node == _rootNode) {
      CircleSymbol(innerColor: Colors.red, outerColor: Colors.red).draw(canvas, mPaint, offset);
    } else {
      series.symbolStyleFun.call(node, null)!.draw(canvas, mPaint, offset);
    }
  }

  void _drawLine(Canvas canvas, TreeLayoutNode node1, TreeLayoutNode node2) {
    _drawEdge(canvas, node1, node2, series.lineType);
  }

  void _drawEdge(Canvas canvas, TreeLayoutNode node1, TreeLayoutNode node2, LineType type) {
    Line line = Line([node1.position, node2.position]);
    // if (type == LineType.step) {
    //   line = Line(line.step());
    // } else if (type == LineType.stepBefore) {
    //   line = Line(line.stepBefore());
    // } else if (type == LineType.stepAfter) {
    //   line = Line(line.stepAfter());
    // }

    Path path = line.toPath(false);
    series.lineStyleFun.call(node1, node2, null)?.drawPath(canvas, mPaint, path);
  }
}
