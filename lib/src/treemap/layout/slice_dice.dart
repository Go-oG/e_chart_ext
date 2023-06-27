import 'package:e_chart/e_chart.dart';

import 'dice.dart';
import 'layout.dart';
import '../node.dart';
import 'slice.dart';

class SliceDiceLayout extends TreemapLayout {

  @override
  void onLayout(TreeMapNode root, LayoutAnimatorType type) {
    if(root.deep%2==0){
      SliceLayout.layoutChildren(rect, root.children);
    }else{
      DiceLayout.layoutChildren(rect, root.children);
    }
  }
}
