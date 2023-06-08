import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart_ext/src/tree/node.dart';
import 'package:flutter/material.dart';

import '../tree_layout.dart';

///生态树布局
class DendrogramLayout extends TreeLayout {
  Direction2 direction;

  DendrogramLayout({
    this.direction = Direction2.ttb,
    super.center,
    super.centerIsRoot,
    super.gapFun,
    super.levelGapFun,
    super.levelGapSize,
    super.lineType,
    super.nodeGapSize,
    super.nodeSize,
    super.sizeFun,
    super.smooth,
  });

  @override
  void onLayout(Context context, TreeLayoutNode root, num width, num height) {
    if (direction != Direction2.v && direction != Direction2.h) {
      return _layoutNode(root, direction);
    }
    int c = root.childCount;
    if (c <= 1) {
      Direction2 d = direction == Direction2.v ? Direction2.ttb : Direction2.ltr;
      return _layoutNode(root, d);
    }
    TreeLayoutNode leftNode = TreeLayoutNode(null, root.data);
    TreeLayoutNode rightNode = TreeLayoutNode(null, root.data);
    int middle = c ~/ 2;
    each(root.children, (node, i) {
      if (i <= middle) {
        leftNode.add(node);
      } else {
        rightNode.add(node);
      }
    });

    ///重新计算子树的深度和高度
    leftNode.resetDeep(0, false);
    int maxHeight = maxBy<TreeLayoutNode>(leftNode.children, (p0) => p0.height).height;
    leftNode.resetHeight(maxHeight + 1, false);

    rightNode.resetDeep(0, false);
    maxHeight = maxBy<TreeLayoutNode>(rightNode.children, (p0) => p0.height).height;
    rightNode.resetHeight(maxHeight + 1, false);

    if (direction == Direction2.v) {
      _layoutNode(leftNode, Direction2.btt);
      _layoutNode(rightNode, Direction2.ttb);
    } else {
      _layoutNode(leftNode, Direction2.rtl);
      _layoutNode(rightNode, Direction2.ltr);
    }
    bool b = leftNode.childCount > rightNode.childCount;
    if (b) {
      ///将right 平移到left
      num dx = leftNode.x - rightNode.x;
      num dy = leftNode.y - rightNode.y;
      rightNode.translate(dx, dy);
    } else {
      ///将left 平移到right
      num dx = rightNode.x - leftNode.x;
      num dy = rightNode.y - leftNode.y;
      leftNode.translate(dx, dy);
    }
    ///还原节点之间的关系
    root.clear();
    root.size = rightNode.size;
    root.x = b ? leftNode.x : rightNode.x;
    root.y = b ? leftNode.y : rightNode.y;
    for (var node in leftNode.children) {
      root.add(node);
    }
    for (var node in rightNode.children) {
      root.add(node);
    }
    ///还原树的高度和深度
    root.resetDeep(0, false);
    root.resetHeight(max([leftNode.height, rightNode.height]).toInt() + 1, false);
  }

  void _layoutNode(TreeLayoutNode root, Direction2 direction) {
    if (direction == Direction2.v || direction == Direction2.h) {
      throw FlutterError('该方法不支持 Direction2.v 和Direction2.h');
    }
    bool v = direction == Direction2.ttb || direction == Direction2.btt;
    List<TreeLayoutNode> leafList = [];
    root.eachBefore((node, index, startNode) {
      if (node.notChild) {
        leafList.add(node);
      }
      return false;
    });

    ///计算Y轴方向上的位置
    List<num> yList = List.filled(root.height + 1, 0);
    for (int i = 1; i <= root.height; i++) {
      num levelGap = getLevelGap(i - 1, i);
      yList[i] = levelGap + yList[i - 1];
    }
    yList = List.from(yList.reversed);
    root.each((node, index, startNode) {
      if (v) {
        node.y = yList[node.height];
      } else {
        node.x = yList[node.height];
      }
      return false;
    });

    ///处理X轴方向的位置
    num offset = 0;
    TreeLayoutNode? preNode;
    List<TreeLayoutNode> preLeafList = [];
    Set<TreeLayoutNode> preLeafSet = {};
    for (var node in leafList) {
      Size size = getNodeSize(node);
      node.size = size;
      if (v) {
        node.x = offset + size.width / 2;
        offset += size.width + getNodeGap(preNode ?? node, node).dx;
      } else {
        node.y = offset + size.height / 2;
        offset += size.height + getNodeGap(preNode ?? node, node).dy;
      }
      if (node.parent != null && (node.parent!.height - node.height).abs() == 1 && !preLeafSet.contains(node.parent!)) {
        preLeafList.add(node.parent!);
      }
    }

    List<TreeLayoutNode> nextLeafList = [];
    while (preLeafList.isNotEmpty) {
      preLeafSet = {};
      for (var node in preLeafList) {
        var right = node.leafRight();
        var left = node.leafLeft();
        if (v) {
          node.x = (right.x + left.x) / 2;
        } else {
          node.y = (right.y + left.y) / 2;
        }
        var parent = node.parent;
        if (parent != null && (parent.height - node.height).abs() == 1 && !preLeafSet.contains(parent)) {
          nextLeafList.add(parent);
          preLeafSet.add(parent);
        }
      }
      preLeafList = nextLeafList;
      nextLeafList = [];
    }

    if (direction == Direction2.btt) {
      root.bottom2Top();
    } else if (direction == Direction2.rtl) {
      root.right2Left();
    }
  }
}
