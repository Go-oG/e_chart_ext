import 'package:chart_xutil/chart_xutil.dart';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'layout/pack_layout.dart';
import 'pack_node.dart';
import 'pack_series.dart';
import '../model/tree_data.dart';

class PackView extends SeriesView<PackSeries> {
  PackNode root = PackNode(null, TreeData(0, []), value: 0);

  double tx = 0;
  double ty = 0;
  double scale = 1;

  ChartTween? tween;

  ///临时记录最大层级
  late PackNode showNode;

  PackView(super.series);

  void _handleSelect(Offset offset) {
    PackNode? clickNode = findNode(offset);
    if (clickNode == null || clickNode == root) {
      return;
    }

    PackNode pn = clickNode.parent == null ? clickNode : clickNode.parent!;
    if (pn == showNode) {
      return;
    }
    series.onClick?.call(clickNode.data);
    showNode = pn;

    ///计算新的缩放系数
    double oldScale = scale;
    double newScale = min([width, height]) * 0.5 / pn.props.r;
    double scaleDiff = newScale - oldScale;

    ///计算偏移变化值
    double oldTx = tx;
    double oldTy = ty;
    double ntx = width / 2 - newScale * pn.props.x;
    double nty = height / 2 - newScale * pn.props.y;
    double diffTx = (ntx - oldTx);
    double diffTy = (nty - oldTy);

    ChartDoubleTween tween = ChartDoubleTween(0, 1, duration: const Duration(milliseconds: 500));
    tween.addListener(() {
      var t = tween.value;
      scale = oldScale + scaleDiff * t;
      tx = oldTx + diffTx * t;
      ty = oldTy + diffTy * t;
      invalidate();
    });
    tween.statusListener = (s) {
      if (s == AnimationStatus.completed || s == AnimationStatus.dismissed) {
        this.tween = null;
      }
    };
    this.tween = tween;
    tween.start(context);
  }

  PackNode? findNode(Offset offset) {
    List<PackNode> rl = [root];
    PackNode? parent;
    while (rl.isNotEmpty) {
      PackNode node = rl.removeAt(0);
      Offset center = Offset(node.props.x, node.props.y);
      center = center.scale(scale, scale);
      center = center.translate(tx, ty);
      if (offset.inCircle(node.props.r * scale, center: center)) {
        parent = node;
        if (node.hasChild) {
          rl = [...node.children];
        } else {
          return node;
        }
      }
    }
    if (parent != null) {
      return parent;
    }
    return null;
  }

  //TODO 待完成
  void _handleCancelSelect() {}

  @override
  void onClick(Offset offset) {
    _handleSelect(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    _handleSelect(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    _handleSelect(offset);
  }

  @override
  void onHoverEnd() {
    _handleCancelSelect();
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    tx += diff.dx;
    ty += diff.dy;
    invalidate();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    PackNode node = PackNode.fromPackData(series.data);
    node.sum((p0) => p0.value);
    node.computeHeight();

    if (series.sortFun != null) {
      node.sort(series.sortFun!);
    } else {
      node.sort((p0, p1) => (p1.value - p0.value).toInt());
    }
    PackLayout layout = PackLayout();
    layout.size(Rect.fromLTWH(0, 0, width, height));
    if (series.paddingFun != null) {
      layout.padding(series.paddingFun!);
    }
    if (series.radiusFun != null) {
      layout.radius(series.radiusFun!);
    }
    root = layout.layout(node);
    showNode = root;
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    Matrix4 matrix4 = Matrix4.compose(Vector3(tx, ty, 0), Quaternion.identity(), Vector3(scale, scale, 1));
    canvas.transform(matrix4.storage);
    root.each((node, p1, p2) {
      AreaStyle style = series.areaStyleFun.call(node);
      Offset center = Offset(node.props.x, node.props.y);
      double r = node.props.r;
      style.drawCircle(canvas, mPaint, center, r);
      return false;
    });
    canvas.restore();
    if (tween == null || !tween!.isAnimating) {
      ///这里分开绘制是为了优化当存在textScaleFactory时文字高度计算有问题
      root.each((node, p1, p2) {
        if (node.data.label != null && node.data.label!.isNotEmpty) {
          String label = node.data.label!;
          LabelStyle? labelStyle = series.labelStyleFun?.call(node);
          if (labelStyle == null || !labelStyle.show) {
            return false;
          }
          double r = node.props.r;
          Offset center = Offset(node.props.x, node.props.y);
          center = center.scale(scale, scale);
          center = center.translate(tx, ty);
          if (series.optTextDraw && r * 2 * scale < label.length * (labelStyle.textStyle.fontSize ?? 8) * 0.5) {
            return false;
          }
          TextDrawConfig config = TextDrawConfig(
            center,
            align: Alignment.center,
            maxWidth: r * 2 * scale * 0.98,
            maxLines: 1,
          );
          labelStyle.draw(canvas, mPaint, label, config);
        }
        return false;
      });
    }
  }

  @override
  void drawBackground(Canvas canvas) {
    if (series.backgroundColor != null) {
      mPaint.reset();
      mPaint.color = series.backgroundColor!;
      mPaint.style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), mPaint);
    }
  }
}
