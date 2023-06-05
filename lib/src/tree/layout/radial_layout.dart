import 'dart:math' as math;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

import '../node.dart';
import '../tree_layout.dart';
import 'd3_tree_layout.dart';
import 'dendrogram_layout.dart';

///环形分布
class RadialTreeLayout extends TreeLayout<TreeLayoutNode> {
  List<SNumber> center;
  num? radiusGap;
  num rotateAngle;
  num sweepAngle;
  bool dendrogram;
  bool clockwise;
  Fun2<TreeLayoutNode, TreeLayoutNode, num>? splitFun;

  RadialTreeLayout({
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.radiusGap,
    this.rotateAngle = 0,
    this.sweepAngle = 360,
    this.dendrogram = true,
    this.clockwise = true,
    this.splitFun,
  });

  @override
  void doLayout(Context context, TreeLayoutNode root, num width, num height) {
    Offset center = Offset(this.center[0].convert(width), this.center[1].convert(height));
    num radius = math.min(width, height) * 0.5;

    if (dendrogram) {
      _layoutForDendrogram(context, root, sweepAngle, radius);
    } else {
      _layoutForTidy(context, root, sweepAngle, radius);
    }

    root.each((node, index, startNode) {
      Offset c;
      if (clockwise) {
        c = circlePoint(node.y, node.x + rotateAngle, center);
      } else {
        c = circlePoint(node.y, sweepAngle - (node.x + rotateAngle), center);
      }
      node.x = c.dx;
      node.y = c.dy;
      return false;
    });
    root.x = center.dx;
    root.y = center.dy;
  }

  void _layoutForDendrogram(Context context, TreeLayoutNode root, num sweepAngle, num radius) {
    root.sort((p0, p1) => p1.height.compareTo(p0.height));
    DendrogramLayout layout = DendrogramLayout(direction: Direction2.ttb, diff: false);
    if (splitFun != null) {
      layout.splitFun = splitFun!;
    }
    layout.doLayout(context, root, sweepAngle, radius);
  }

  void _layoutForTidy(Context context, TreeLayoutNode root, num sweepAngle, num radius) {
    D3TreeLayout layout = D3TreeLayout();
    if (splitFun != null) {
      layout.splitFun = splitFun!;
    }
    layout.diff = false;
    layout.doLayout(context, root, sweepAngle, radius);
  }
}
