import 'package:chart_xutil/chart_xutil.dart';
import '../model/tree_data.dart';

class TreeLayoutNode extends TreeNode<TreeLayoutNode> {
  final TreeData data;

  TreeLayoutNode(super.parent, this.data, {super.deep, super.maxDeep, super.value});

  @override
  String toString() {
    return '$data x:${x.toStringAsFixed(2)} y:${y.toStringAsFixed(2)}';
  }
}
