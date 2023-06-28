import 'package:e_chart/e_chart.dart';

import 'hex_bin_node.dart';
import 'layout/hex_hexagons_layout.dart';
import 'layout/hex_layout.dart';

class HexbinSeries extends RectSeries {
  HexbinLayout layout = HexagonsLayout();
  List<ItemData> data;
  Fun2<HexbinNode, AreaStyle> styleFun;
  Fun2<HexbinNode, LabelStyle>? labelStyleFun;

  ///半径函数(可单独对某一个节点设置其大小)
  Fun2<HexbinNode, num?>? radiusFun;
  bool clock = false;

  HexbinSeries(
    this.data, {
    required this.styleFun,
    this.labelStyleFun,
    HexbinLayout? layout,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.clip,
    super.tooltip,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.z,
  }) : super(
          coordSystem: null,
          xAxisIndex: -1,
          yAxisIndex: -1,
          polarAxisIndex: -1,
          parallelIndex: -1,
          radarIndex: -1,
          calendarIndex: -1,
        ) {
    if (layout != null) {
      this.layout = layout;
    }
  }
}
