import 'package:e_chart/e_chart.dart';

import 'gauge_point.dart';

///仪表盘
class GaugeSeries extends RectSeries {
  SNumber radius;
  List<SNumber> center;
  List<AngleAxis> axisList;
  List<GaugeData> groupList;
  StyleFun<GaugeData, LabelStyle>? labelStyleFun;

  GaugeSeries({
    this.radius = const SNumber(75, true),
    this.center = const [SNumber(50, true), SNumber(50, true)],
    required this.groupList,
    this.axisList = const [AngleAxis()],
    this.labelStyleFun,
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
    super.z,
  }) : super(
          coordSystem: null,
          xAxisIndex: -1,
          yAxisIndex: -1,
          polarAxisIndex: -1,
          parallelIndex: -1,
          radarIndex: -1,
          calendarIndex: -1,
        );
}

class GaugeProgress {
  bool enable;
  Align2 align;
  bool overlap;
  bool roundCap;
  bool clip;
  FormatterFun<double>? formatter;
  StyleFun<double, LineStyle>? styleFun;
  LineStyle? backgroundStyle;
  GaugeProgress? progress;

  GaugeProgress(
      {this.enable = true,
      this.overlap = true,
      this.roundCap = false,
      this.clip = false,
      this.align = Align2.end,
      required this.styleFun,
      this.backgroundStyle,
      this.progress,
      this.formatter});
}

class GaugeData {
  late final String id;
  int axisIndex;
  DynamicData data;
  GaugePoint? point;

  GaugeData(this.data, {this.axisIndex = 0, this.point, String? id}) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }
}
