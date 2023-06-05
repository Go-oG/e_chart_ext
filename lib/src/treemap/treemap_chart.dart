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
  final RectGesture gesture = RectGesture();

  ///记录显示的层级
  final List<TreeMapNode> showStack = [];
  List<TreeMapNode> drawList = [];
  double tx = 0;
  double ty = 0;
  Offset moveOffset = Offset.zero;

  ///记录当前画布坐标原点和绘图坐标原点的偏移量
  TreeMapView(super.series) {
    helper = LayoutHelper(series);
  }

  @override
  void onAttach() {
    super.onAttach();
    initListener();
  }

  void initListener() {
    series.addListener((p0) {
      if (p0.code == TreeMapSeries.commandBack) {
        back();
        return;
      }
    });
    context.addGesture(gesture);
    gesture.click = _handleClick;
    if (context.config.dragType == DragType.longPress) {
      gesture.longPressMove = (e) {
        Offset of = e.offsetFromOrigin;
        var dx = of.dx - moveOffset.dx;
        var dy = of.dy - moveOffset.dy;
        moveOffset = of;
        tx += dx;
        ty += dy;
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
        tx += dx;
        ty += dy;
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
        tx += dx;
        ty += dy;
        invalidate();
      };
      gesture.verticalDragEnd = (e) {
        cancelDrag();
      };
      gesture.verticalDragCancel = cancelDrag;
    }
    if (context.config.scaleType == ScaleType.doubleTap) {
      gesture.doubleClickCancel = () {
        invalidate();
      };
    } else {
      ///缩放
    }
  }

  void cancelDrag() {
    moveOffset = Offset.zero;
  }

  ///回退
  void back() {}

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    gesture.rect = globalAreaBound;
    rootNode = toTree<TreeData, TreeMapNode>(series.data, (p0) => p0.children, (p0, p1) => TreeMapNode(p0, p1));
    rootNode.sum((p0) => p0.data.value);
    rootNode.removeWhere((p0) => p0.value <= 0, true);
    for (var leaf in rootNode.leaves()) {
      leaf.computeHeight(leaf);
    }
    rootNode.position = Rect.fromLTWH(0, 0, width, height);

    ///直接布局测量全部
    helper.layout(rootNode, rootNode.position);
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
    Rect rect = node.position;
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
  void _handleClick(NormalEvent e) {
    Offset offset = toLocalOffset(e.globalPosition);
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
      Rect rect = c.position;
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
    Size rootSize = rootNode.position.size;
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
    ch =cw/(rootSize.width/rootSize.height);

    if (cw < width || ch < height) {
      cw = width;
      ch = height;
    }

    rootNode.each((node, index, startNode) {
      node.start = node.cur.copy();
      return false;
    });

    ///重新测量位置
    rootNode.position = Rect.fromLTWH(0, 0, cw, ch);
    helper.layout(rootNode, rootNode.position);
    rootNode.each((node, index, startNode) {
      node.end = node.cur.copy();
      return false;
    });

    ///计算平移量
    Offset center = clickNode.position.center;
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
        tmp.position = rectTween.safeGetValue(v);
        return false;
      });
      invalidate();
    });
    tween.start(context);
  }
}
