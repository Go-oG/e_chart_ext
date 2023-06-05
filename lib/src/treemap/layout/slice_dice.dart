import 'dart:ui';

import 'dice.dart';
import 'layout.dart';
import '../node.dart';
import 'slice.dart';

class SliceDiceLayout extends TreemapLayout {

  @override
  void layout(TreeMapNode root, Rect area) {
    if(root.deep%2==0){
      SliceLayout.layoutChildren(area, root.children);
    }else{
      DiceLayout.layoutChildren(area, root.children);
    }
  }
}
