import 'package:e_chart/e_chart.dart';

class ThemeRiverSeries extends RectSeries {
  List<GroupData> data;
  Direction direction;
  SNumber? minInterval;
  bool smooth;
  double smoothRatio;
  Fun2<GroupData, AreaStyle> areaStyleFun;
  Fun2<GroupData, LabelStyle>? labelStyleFun;

  ThemeRiverSeries(
    this.data, {
    this.direction = Direction.horizontal,
    this.minInterval,
    this.labelStyleFun,
    this.smooth = true,
    this.smoothRatio = 0.25,
    required this.areaStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.tooltip,
        super.backgroundColor,
        super.id,
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
          calendarIndex: -1,
          parallelIndex: -1,
          polarAxisIndex: -1,
          radarIndex: -1,
        );
}
