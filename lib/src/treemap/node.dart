import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';

import '../model/tree_data.dart';

class TreeMapNode extends TreeNode<TreeMapNode> {
  final TreeData data;
  NodeProps cur = NodeProps(); // 当前对象
  NodeProps start = NodeProps(); //动画开始帧
  NodeProps end = NodeProps(); //动画结束帧

  TreeMapNode(super.parent, this.data, {super.deep, super.maxDeep, super.value}){
    setExpand(false,false);
  }

  ///计算面积比
  double get areaRatio {
    if (parent == null) {
      return 1;
    }
    return value / parent!.value;
  }

  Rect get position => cur.position;

  set position(Rect rect) {
    cur.position = rect;
  }
}

class NodeProps {
  Rect position = Rect.zero; //当前位置参数

  NodeProps copy() {
    NodeProps p = NodeProps();
    p.position = position;
    return p;
  }
}
