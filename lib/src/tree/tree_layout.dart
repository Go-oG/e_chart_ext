
import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

abstract class TreeLayout<T extends TreeNode<T>> {
  Fun1<T, Size>? sizeFun;
  Fun2<T, T, Offset>? gapFun;
  Fun2<int, int, num>? levelGapFun;

  VoidCallback? _layoutEnd;
  VoidCallback? _layoutUpdate;

  TreeLayout({
    this.sizeFun,
    this.gapFun,
    this.levelGapFun,
  });

  void doLayout(Context context,T root, num width, num height);

  set layoutEnd(VoidCallback c) => _layoutEnd = c;

  set layoutUpdate(VoidCallback c) => _layoutUpdate = c;

  void onLayoutEnd() {
    _layoutEnd?.call();
  }

  void onLayoutUpdate() {
    _layoutUpdate?.call();
  }

  Size getSize(T node, [Size defaultSize = const Size(8, 8)]) {
    return sizeFun?.call(node) ?? defaultSize;
  }

  Offset getNodeGap(T node1, T node2, [Offset defaultGap = const Offset(8, 8)]) {
    return gapFun?.call(node1, node2) ?? defaultGap;
  }

  double getLevelGap(int level1, int level2, [double defaultGap = 24]) {
    return (levelGapFun?.call(level1, level2) ?? defaultGap).toDouble();
  }
}
