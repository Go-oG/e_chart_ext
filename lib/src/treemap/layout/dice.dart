import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

import 'layout.dart';
import '../node.dart';

//从左至右
class DiceLayout extends TreemapLayout {

  @override
  void onLayout(TreeMapNode root,LayoutAnimatorType type) {
    if (root.notChild) {
      return;
    }
    layoutChildren(rect, root.children);
  }

  static void layoutChildren(Rect area, List<TreeMapNode> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    double leftOffset = area.left;
    double w = area.width;
    double h = area.height;
    num allRatio = computeAllRatio(nodeList);
    for (var node in nodeList) {
      double p = node.areaRatio / allRatio;
      double w2 = w * p;
      Rect rect = Rect.fromLTWH(leftOffset, area.top, w2, h);
      node.setPosition(rect);
      leftOffset += rect.width;
    }
  }
}
