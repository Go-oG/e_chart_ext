
import 'package:e_chart/e_chart.dart';

import 'hex_bin_node.dart';
import 'layout/hex_hexagons_layout.dart';
import 'layout/hex_layout.dart';

class HexbinSeries extends RectSeries {
  HexbinLayout layout = HexagonsLayout();
  List<HexbinData> data;
  Fun1<HexbinNode, AreaStyle> styleFun;
  Fun1<HexbinNode, LabelStyle>? labelStyleFun;
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
    super.touch,
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

class HexbinData {
  final String id;
  final String? label;

  HexbinData(this.id, [this.label]);
}
