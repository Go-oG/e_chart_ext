import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'layout.dart';
import '../node.dart';

/// 从上到下
class SliceLayout extends TreemapLayout {
  @override
  void layout(TreeMapNode root, Rect area) {
    layoutChildren(area, root.children);
  }

  ///从上到下
  static void layoutChildren(Rect rect, List<TreeMapNode> nodeList) {
    double w = rect.width;
    double h = rect.height;
    double allValue = computeAllRatio(nodeList);
    double topOffset = rect.top;
    for (var node in nodeList) {
      double ratio = node.areaRatio / allValue;
      double h2 = ratio * h;
      node.position = Rect.fromLTWH(rect.left, topOffset, w, h2);
      topOffset += node.position.height;
    }
  }

}
