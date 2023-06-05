import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import '../model/tree_data.dart';

class TreeLayoutNode extends TreeNode<TreeLayoutNode> {
  final TreeData data;
  ///记录节点坐标
  num x = 0;
  num y = 0;

  TreeLayoutNode(super.parent, this.data, {super.deep, super.maxDeep, super.value});

  Offset get position{
    return Offset(x.toDouble(), y.toDouble());
  }
}
