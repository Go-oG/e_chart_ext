import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'layout.dart';
import 'theme_river_series.dart';

class ThemeRiverView extends SeriesView<ThemeRiverSeries> {
  final List<LayoutNode> nodeList = [];
  final ThemeRiverLayout layer = ThemeRiverLayout();
  LayoutNode? oldHoverNode;
  double animatorPercent = 1;
  double tx = 0;
  double ty = 0;

  ThemeRiverView(super.series) {
    for (var d in series.data) {
      LayoutNode node = LayoutNode(d);
      nodeList.add(node);
    }
  }

  void handleHover(Offset local) {
    Offset offset = local.translate(-tx, -ty);
    if (oldHoverNode != null && oldHoverNode!.drawPath.contains(offset)) {
      return;
    }
    LayoutNode? selectNode;
    for (var element in nodeList) {
      if (element.drawPath.contains(offset)) {
        element.cur.hover = true;
        element.index = 100;
        selectNode = element;
      } else {
        element.cur.hover = false;
        element.index = 0;
      }
    }
    ChartDoubleTween tween = ChartDoubleTween(0, 1, duration: const Duration(milliseconds: 200));
    AreaStyleTween? selectTween;
    AreaStyleTween? unselectTween;
    if (selectNode != null && selectNode.style != null) {
      selectTween = AreaStyleTween(selectNode.style!, series.areaStyleFun.call(selectNode.data, HoverAction())!);
      selectNode.index = 100;
    }
    LayoutNode? oldNode = oldHoverNode;
    oldHoverNode = selectNode;
    if (oldNode != null && oldNode.style != null) {
      unselectTween = AreaStyleTween(oldNode.style!, series.areaStyleFun.call(oldNode.data, null)!);
      oldNode.index = 0;
    }
    nodeList.sort((a, b) {
      return a.index.compareTo(b.index);
    });
    tween.addListener(() {
      double p = tween.value;
      if (selectTween != null) {
        selectNode!.style = selectTween.safeGetValue(p);
      }
      if (unselectTween != null) {
        oldNode!.style = unselectTween.safeGetValue(p);
      }
      invalidate();
    });
    tween.start(context);
  }

  void handleCancel() {
    oldHoverNode?.cur.hover = false;
    oldHoverNode?.cur.select = false;
  }

  @override
  void onHoverStart(Offset offset) {
    handleHover(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    handleHover(offset);
  }

  @override
  void onHoverEnd() {
    handleCancel();
  }

  @override
  void onClick(Offset offset) {
    handleHover(offset);
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    double oldTx = tx;
    double oldTy = ty;
    tx += diff.dx;
    ty += diff.dy;
    if (tx > 0) {
      tx = 0;
    }
    if (ty > 0) {
      ty = 0;
    }
    if (tx.abs() > layer.maxTransX) {
      tx = -layer.maxTransX.toDouble();
    }
    if (ty.abs() > layer.maxTransY) {
      ty = -layer.maxTransY.toDouble();
    }
    if (oldTx == tx && oldTy == ty) {
      return;
    }
    invalidate();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    layer.doLayout(series, nodeList, width, height);
    tx = ty = 0;
    doAnimator();
  }

  void doAnimator() {
    AnimatorProps? info = series.animation;
    if (info == null) {
      return;
    }
    ChartDoubleTween tween = ChartDoubleTween.fromAnimator(info);
    tween.addListener(() {
      animatorPercent = tween.value;
      invalidate();
    });
    tween.start(context);
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    canvas.translate(tx, ty);
    if (series.direction == Direction.horizontal) {
      canvas.clipRect(Rect.fromLTWH(tx.abs(), ty.abs(), width * animatorPercent, height));
    } else {
      canvas.clipRect(Rect.fromLTWH(tx.abs(), ty.abs(), width, height * animatorPercent));
    }
    for (var ele in nodeList) {
      AreaStyle? style = ele.style ?? series.areaStyleFun.call(ele.data, ele.cur.hover ? HoverAction() : null);
      style?.drawPath(canvas, mPaint, ele.drawPath);
    }
    //这里拆分开是为了避免文字被遮挡
    for (var element in nodeList) {
      drawText(canvas, element);
    }
    canvas.restore();
  }

  void drawText(Canvas canvas, LayoutNode node) {
    String? label = node.data.label;

    if (label == null || label.isEmpty) {
      return;
    }
    LabelStyle? style = node.labelStyle ?? series.labelStyleFun?.call(node.data, node.cur.hover ? HoverAction() : null);
    if (style == null) {
      return;
    }
    Offset o1 = node.polygonList.first;
    Offset o2 = node.polygonList.last;
    if (series.direction == Direction.horizontal) {
      Offset offset = Offset(o1.dx, (o1.dy + o2.dy) * 0.5);
      TextDrawConfig config = TextDrawConfig(offset, align: Alignment.centerLeft);
      style.draw(canvas, mPaint, label, config);
    } else {
      Offset offset = Offset((o1.dx + o2.dx) / 2, o1.dy);
      TextDrawConfig config = TextDrawConfig(offset, align: Alignment.topCenter);
      style.draw(canvas, mPaint, label, config);
    }
  }
}
