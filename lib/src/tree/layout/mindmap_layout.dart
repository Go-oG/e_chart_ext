
import 'package:e_chart/e_chart.dart';

import '../node.dart';
import '../tree_layout.dart';
import 'compact_layout.dart';

///思维导图
class MindMapLayout extends TreeLayout<TreeLayoutNode> {
  MindMapLayout({
    super.gapFun,
    super.levelGapFun,
    super.sizeFun,
  });

  @override
  void doLayout(Context context, TreeLayoutNode root, num width, num height) {
    if (root.childCount <= 1) {
      CompactLayout l = CompactLayout(
        levelAlign: Align2.start,
        direction: Direction2.ltr,
        gapFun: gapFun,
        levelGapFun: levelGapFun,
        sizeFun: sizeFun,
      );
      l.doLayout(context, root, width, height);
      return;
    }

    TreeLayoutNode leftRoot = TreeLayoutNode(null, root.data);
    TreeLayoutNode rightRoot = TreeLayoutNode(null, root.data);
    int rightTreeSize = (root.childCount / 2).round();
    int i = 0;
    for (var node in root.children) {
      if (i < rightTreeSize) {
        leftRoot.add(node);
      } else {
        rightRoot.add(node);
      }
      i++;
    }

    CompactLayout leftLayout = CompactLayout(
      levelAlign: Align2.start,
      direction: Direction2.rtl,
      gapFun: gapFun,
      levelGapFun: levelGapFun,
      sizeFun: sizeFun,
    );
    leftLayout.doLayout(context, leftRoot, width, height);

    CompactLayout rightLayout = CompactLayout(
      levelAlign: Align2.start,
      direction: Direction2.ltr,
      gapFun: gapFun,
      levelGapFun: levelGapFun,
      sizeFun: sizeFun,
    );
    rightLayout.doLayout(context, rightRoot, width, height);

    root.children.clear();
    for (var element in leftRoot.children) {
      root.add(element);
    }
    for (var element in rightRoot.children) {
      root.add(element);
    }

    num tx = leftRoot.x - rightRoot.x;
    num ty = leftRoot.y - rightRoot.y;
    rightRoot.each((node, index, startNode) {
      node.x += tx;
      node.y += ty;
      return false;
    });
    root.x = leftRoot.x;
    root.y = leftRoot.y;
  }
}
