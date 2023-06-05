import 'dart:math'as m;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../node.dart';
import '../tree_layout.dart';

/// 缩进树布局
class IndentedLayout extends TreeLayout<TreeLayoutNode> {
  Direction2 direction;

  IndentedLayout({
    this.direction = Direction2.ttb,
    super.gapFun,
    super.levelGapFun,
    super.sizeFun,
  });

  @override
  void doLayout(Context context, TreeLayoutNode root, num width, num height) {
    Direction2 direction = this.direction;
    if (direction != Direction2.ltr && direction != Direction2.rtl && direction != Direction2.h) {
      direction = Direction2.ltr;
    }
    if (direction == Direction2.ltr || direction == Direction2.rtl) {
      _layoutTree(root, width, height, direction);
    } else {
      _layoutCenter(root, width, height);
    }

    onLayoutEnd();
  }

  void _layoutCenter(TreeLayoutNode root, num width, num height) {
    if (root.childCount <= 1) {
      _layoutTree(root, width, height, Direction2.ltr);
      return ;
    }
    TreeLayoutNode leftRoot = TreeLayoutNode(null, root.data);
    TreeLayoutNode rightRoot = TreeLayoutNode(null, root.data);
    int i = 0;
    for (var element in root.children) {
      if (i % 2 == 0) {
        leftRoot.add(element);
      } else {
        rightRoot.add(element);
      }
      i++;
    }
    _layoutTree(leftRoot, width, height, Direction2.rtl);
    _layoutTree(rightRoot, width, height, Direction2.ltr);

    Offset leftOffset = leftRoot.position;
    Offset rightOffset = rightRoot.position;
    Offset center = Offset(width / 2, 0);
    double tx = center.dx - leftOffset.dx;
    double ty = center.dy - leftOffset.dy;
    leftRoot.each((node, index, startNode) {
      if (node != leftRoot) {
        Offset of = node.position.translate(tx, ty);
        node.x = of.dx;
        node.y = of.dy;
      }
      return false;
    });
    tx = center.dx - rightOffset.dx;
    ty = center.dy - rightOffset.dy;
    rightRoot.each((node, index, startNode) {
      if (node != rightRoot) {
        Offset of = node.position.translate(tx, ty);
        node.x = of.dx;
        node.y = of.dy;
      }
      return false;
    });
    root.clear();
    for (var node in leftRoot.children) {
      root.add(node);
    }
    for (var node in rightRoot.children) {
      root.add(node);
    }
    root.x = center.dx;
    root.y = center.dy;
  }

  void _layoutTree(TreeLayoutNode root, num width, num height, Direction2 direction) {
    double topOffset = 0;
    root.eachBefore((p0, p1, p2) {
      if (!p0.expand) {
        return false;
      }
      Size size = getSize(p0);
      Offset gap = getNodeGap(p0, p0);
      double l = m.max(0, gap.dx) * p0.deep.toDouble();
      if (direction == Direction2.ltr) {
        p0.x=l;
        p0.y=topOffset;
      } else {
        p0.x=width-l;
        p0.y=topOffset;
      }
      topOffset += gap.dy + size.height;

      return false;
    });
  }
}
