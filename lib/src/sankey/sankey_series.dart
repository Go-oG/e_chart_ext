import 'package:e_chart/e_chart.dart';

import 'sankey_align.dart';
import 'sort.dart';

class SankeySeries extends RectSeries {
  List<ItemData> data;
  List<SankeyLinkData> links;
  double nodeWidth;
  double gap;
  int iterationCount;
  SankeyAlign align;
  NodeSort? nodeSort;
  LinkSort? linkSort;
  Direction direction;
  StyleFun<ItemData, AreaStyle> nodeStyle;
  StyleFun2<ItemData, ItemData, AreaStyle>? linkStyleFun;

  SankeySeries({
    required this.data,
    required this.links,
    this.nodeWidth = 16,
    this.gap = 8,
    this.iterationCount = 6,
    this.align = const JustifyAlign(),
    this.direction = Direction.horizontal,
    this.nodeSort,
    this.linkSort,
    required this.nodeStyle,
    this.linkStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.tooltip,
    super.animation,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.clip,
    super.z,
  }) : super(
          xAxisIndex: -1,
          yAxisIndex: -1,
          polarAxisIndex: -1,
          radarIndex: -1,
          calendarIndex: -1,
          parallelIndex: -1,
        );
}

class SankeyLinkData {
  ItemData src;
  ItemData target;
  double value;
  DynamicText? label;

  SankeyLinkData(this.src, this.target, this.value, {this.label});

  @override
  int get hashCode {
    return Object.hash(src, target);
  }

  @override
  bool operator ==(Object other) {
    return other is SankeyLinkData && other.src == src && other.target == target;
  }
}
