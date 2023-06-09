import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'dice.dart';
import 'layout.dart';
import '../node.dart';
import 'slice.dart';

class SliceDiceLayout extends TreemapLayout {

  @override
  void doLayout(Context context,TreeMapNode root, Rect area) {
    if(root.deep%2==0){
      SliceLayout.layoutChildren(area, root.children);
    }else{
      DiceLayout.layoutChildren(area, root.children);
    }
  }
}
