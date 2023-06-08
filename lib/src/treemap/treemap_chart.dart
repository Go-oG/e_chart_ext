import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../model/tree_data.dart';
import 'layout_helper.dart';
import 'node.dart';
import 'treemap_series.dart';

/// 矩形树图
class TreeMapView extends SeriesView<TreeMapSeries> {
  late TreeMapNode rootNode;
  late LayoutHelper helper;

  ///记录显示的层级
  final List<TreeMapNode> showStack = [];
  List<TreeMapNode> drawList = [];
  double tx = 0;
  double ty = 0;

  ///记录当前画布坐标原点和绘图坐标原点的偏移量
  TreeMapView(super.series) {
    helper = LayoutHelper(series);
  }

  @override
  void onAttach() {
    super.onAttach();
    series.addListener((p0) {
      if (p0.code == TreeMapSeries.commandBack) {
        back();
        return;
      }
    });
  }

  @override
  void onClick(Offset offset) {
    handleClick(offset);
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    tx += diff.dx;
    ty += diff.dy;
    invalidate();
  }

  @override
  void onScaleUpdate(Offset offset, double rotation, double scale, double hScale, double vScale, bool doubleClick) {
    // TODO: 待实现
  }

  ///回退
  void back() {
    //TODO 待实现
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    rootNode = toTree<TreeData, TreeMapNode>(series.data, (p0) => p0.children, (p0, p1) => TreeMapNode(p0, p1));
    rootNode.sum((p0) => p0.data.value);
    rootNode.removeWhere((p0) => p0.value <= 0, true);
    for (var leaf in rootNode.leaves()) {
      leaf.computeHeight(leaf);
    }
    rootNode.setPosition(Rect.fromLTWH(0, 0, width, height));

    ///直接布局测量全部
    helper.layout(rootNode, rootNode.getPosition());
    showStack.clear();
    showStack.add(rootNode);
    adjustDrawList();
  }

  void adjustDrawList() {
    List<TreeMapNode> list = [rootNode];
    List<TreeMapNode> next = [];
    int deep = showStack.last.deep + 1;
    drawList = [];
    while (list.isNotEmpty) {
      for (var node in list) {
        if (node.deep > deep) {
          continue;
        }
        if (!node.hasChild) {
          drawList.add(node);
          continue;
        }
        if (node.deep + 1 == deep) {
          drawList.addAll(node.children);
        } else {
          next.addAll(node.children);
        }
      }
      list = next;
      next = [];
    }
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, width, height));
    canvas.translate(tx, ty);
    for (var c in drawList) {
      _drawNode(canvas, c);
    }
    canvas.restore();
  }

  void _drawNode(Canvas canvas, TreeMapNode node) {
    AreaStyle? style = series.areaStyleFun.call(node, null);
    if (style == null || !style.show) {
      return;
    }
    Rect rect = node.getPosition();
    style.drawRect(canvas, mPaint, rect);
    String label = node.data.label ?? '';
    if (label.isEmpty) {
      return;
    }
    if (rect.width * rect.height <= 300) {
      return;
    }
    LabelStyle? labelStyle = series.labelStyleFun?.call(node, null);
    if (labelStyle == null || !labelStyle.show) {
      return;
    }
    if (rect.height < (labelStyle.textStyle.fontSize ?? 0)) {
      return;
    }
    if (rect.width < (labelStyle.textStyle.fontSize ?? 0) * 2) {
      return;
    }

    Alignment align = series.alignFun?.call(node) ?? Alignment.topLeft;
    double x = rect.center.dx + align.x * rect.width / 2;
    double y = rect.center.dy + align.y * rect.height / 2;

    TextDrawConfig config = TextDrawConfig(
      Offset(x, y),
      maxWidth: rect.width * 0.8,
      maxHeight: rect.height * 0.8,
      align: toInnerAlign(align),
      textAlign: TextAlign.start,
      maxLines: 2,
      ignoreOverText: true,
    );

    labelStyle.draw(canvas, mPaint, label, config);
  }

  ///处理点击事件
  void handleClick(Offset local) {
    Offset offset = local;
    TreeMapNode? clickNode = findClickNode(offset);
    if (clickNode == null) {
      debugPrint('无法找到点击节点');
      return;
    }
    if (clickNode == rootNode && clickNode.children.isEmpty) {
      back();
      return;
    }
    zoomOut(clickNode);
  }

  TreeMapNode? findClickNode(Offset offset) {
    offset = offset.translate(-tx, -ty);
    for (var c in drawList) {
      Rect rect = c.getPosition();
      if (rect.contains(offset)) {
        return c;
      }
    }
    return null;
  }

  /// 缩小
  void zoomIn(TreeMapNode node, double ratio) {}

  ///放大
  void zoomOut(TreeMapNode clickNode) {
    if (clickNode == rootNode) {
      return;
    }
    series.onClick?.call(clickNode.data);
    showStack.clear();
    showStack.addAll(clickNode.ancestors().reversed);
    adjustDrawList();

    ///保持当前比例不变
    Size rootSize = rootNode.getPosition().size;
    double rootArea = rootSize.width * rootSize.height;
    double areaRadio = clickNode.value / rootNode.value;

    ///计算新的画布大小
    double cw = 0;
    double ch = 0;

    double factory = clickNode.childCount > 1 ? 0.45 : 0.25;

    double w = min([width, height]) * factory;
    double h = w * 0.75;

    double rootArea2 = w * h / areaRadio;
    double scale = rootArea2 / rootArea;
    cw = rootSize.width * scale;
    // ch = rootSize.height * scale;
    ch = cw / (rootSize.width / rootSize.height);

    if (cw < width || ch < height) {
      cw = width;
      ch = height;
    }

    rootNode.each((node, index, startNode) {
      node.start = node.cur.copy();
      return false;
    });

    ///重新测量位置
    rootNode.setPosition(Rect.fromLTWH(0, 0, cw, ch));
    helper.layout(rootNode, rootNode.getPosition());
    rootNode.each((node, index, startNode) {
      node.end = node.cur.copy();
      return false;
    });

    ///计算平移量
    Offset center = clickNode.getPosition().center;
    double tw = width / 2 - center.dx;
    double th = height / 2 - center.dy;

    double diffTx = (tw - tx);
    double diffTy = (th - ty);
    double oldTx = tx;
    double oldTy = ty;

    /// 执行动画
    Duration duration = const Duration(milliseconds: 500);
    ChartRectTween rectTween = ChartRectTween(Rect.zero, Rect.zero, curve: Curves.linear, duration: duration);
    ChartDoubleTween tween = ChartDoubleTween(0, 1, curve: Curves.linear, duration: duration);
    tween.addListener(() {
      double v = tween.value;
      tx = oldTx + diffTx * v;
      ty = oldTy + diffTy * v;
      rootNode.each((tmp, index, startNode) {
        rectTween.changeValue(tmp.start.position, tmp.end.position);
        tmp.setPosition(rectTween.safeGetValue(v));
        return false;
      });
      invalidate();
    });
    tween.start(context);
  }
}
