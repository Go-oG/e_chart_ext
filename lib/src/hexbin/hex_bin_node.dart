import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'hex.dart';
import 'hex_bin_series.dart';

class HexbinNode {
  final HexbinData data;
  Hex hex = Hex(0, 0, 0);
  HexbinNode(this.data);

  PositiveShape shape=PositiveShape(count: 0);

  //中心点坐标
  Offset center = Offset.zero;
}