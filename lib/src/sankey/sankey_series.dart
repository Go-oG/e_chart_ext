import 'package:uuid/uuid.dart';
import 'package:e_chart/e_chart.dart';

import 'sankey_align.dart';
import 'sort.dart';

class SankeySeries extends RectSeries {
  List<SankeyData> nodes;
  List<SankeyLinkData> links;
  double nodeWidth;
  double gap;
  int iterationCount;
  SankeyAlign align;
  NodeSort? nodeSort;
  LinkSort? linkSort;
  Direction direction;
  StyleFun<SankeyData, AreaStyle> nodeStyle;
  StyleFun2<SankeyData, SankeyData, AreaStyle>? linkStyleFun;

  SankeySeries({
    required this.nodes,
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
    super.touch,
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

class SankeyData {
  late final String id;
  final String name;

  SankeyData(this.name, {String? id}) {
    if (id == null || id.isEmpty) {
      this.id = const Uuid().v4().toString().replaceAll('-', '');
    } else {
      this.id = id;
    }
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is SankeyData && other.id == id;
  }
}

class SankeyLinkData {
  final SankeyData src;
  final SankeyData target;
  final double value;

  SankeyLinkData(this.src, this.target, this.value);

  @override
  int get hashCode {
    return Object.hash(src, target);
  }

  @override
  bool operator ==(Object other) {
    return other is SankeyLinkData && other.src == src && other.target == target;
  }
}
