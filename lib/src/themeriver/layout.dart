import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart_ext/e_chart_ext.dart';
import 'package:flutter/widgets.dart';

class ThemeRiverLayout extends ChartLayout{
  num maxTransX = 0,
      maxTransY = 0;

  void doLayout(Context context,ThemeRiverSeries series, List<LayoutNode> dataList, double width, double height) {
    if (dataList.isEmpty) {
      return;
    }
    final List<List<_InnerNode>> nodeList = [];
    for (var ele in dataList) {
      List<_InnerNode> tmp = [];
      for (var e2 in ele.data.childData) {
        tmp.add(_InnerNode(e2.value));
      }
      if (tmp.isNotEmpty) {
        nodeList.add(tmp);
      }
    }
    var base = _computeBaseline(nodeList);
    List<double> baseLine = base['y0'];
    Direction direction = series.direction;

    double tw = (direction == Direction.horizontal ? height : width) * 0.95;
    double ky = tw / base['max'];

    int n = nodeList.length;
    int m = nodeList[0].length;
    tw = direction == Direction.horizontal ? width : height;
    double iw = m <= 1 ? 0 : tw / (m - 1);
    if (m > 1&&series.minInterval!=null) {
      double minw = series.minInterval!.convert(tw);
      if (iw < minw) {
        iw = minw;
      }
    }
    double baseY0;
    for (int j = 0; j < m; ++j) {
      baseY0 = baseLine[j] * ky;
      nodeList[0][j].setItemLayout(0, iw * j, baseY0, nodeList[0][j].value * ky);
      for (int i = 1; i < n; ++i) {
        baseY0 += nodeList[i - 1][j].value * ky;
        nodeList[i][j].setItemLayout(i, iw * j, baseY0, nodeList[i][j].value * ky);
      }
    }
    for (int j = 0; j < nodeList.length; j++) {
      LayoutNode node = dataList[j];
      var ele = nodeList[j];
      List<Offset> pList = [];
      List<Offset> pList2 = [];
      for (int i = 0; i < ele.length; i++) {
        if (direction == Direction.horizontal) {
          pList.add(Offset(ele[i].x, ele[i].py0));
          pList2.add(Offset(ele[i].x, ele[i].py + ele[i].py0));
        } else {
          pList.add(Offset(ele[i].py0, ele[i].x));
          pList2.add(Offset(ele[i].py + ele[i].py0, ele[i].x));
        }
      }
      node._buildPath(pList, pList2, series.smooth,series.smoothRatio);
    }
    adjust(dataList, width, height, series);
  }

  void adjust(List<LayoutNode> nodeList, num width, num height, ThemeRiverSeries series) {
    Direction direction = series.direction;

    Rect first = nodeList.first.drawPath.getBounds();
    Rect last = nodeList.last.drawPath.getBounds();
    if (direction == Direction.horizontal) {
      maxTransX = first.width - width;
      maxTransX = max([0, maxTransX]);
      maxTransY = 0;
    } else {
      maxTransY = first.height - height;
      maxTransY = max([0, maxTransY]);
      maxTransX = 0;
    }
    Offset offset;
    if (direction == Direction.horizontal) {
      offset = Offset(0, ((first.top - last.bottom).abs() - height) / 2);
    } else {
      offset = Offset(((first.left - last.right).abs() - width) / 2, 0);
    }
    if (offset != Offset.zero) {
      for (var c in nodeList) {
        c._path = c._path.shift(offset);
      }
    }
  }

  Map<String, dynamic> _computeBaseline(List<List<_InnerNode>> data) {
    int layerNum = data.length;
    int pointNum = data[0].length;
    List<double> sums = [];
    double max = 0;

    ///按照时间序列 计算并保存每个序列值和，且和全局最大序列值和进行比较保留最大的
    for (int i = 0; i < pointNum; ++i) {
      double temp = 0;
      for (int j = 0; j < layerNum; ++j) {
        temp += data[j][i].value;
      }
      if (temp > max) {
        max = temp;
      }
      sums.add(temp);
    }

    ///计算每个序列与最大序列值差值的一半
    List<double> y0 = List.filled(pointNum, 0);
    for (int k = 0; k < pointNum; ++k) {
      y0[k] = (max - sums[k]) / 2;
    }

    max = 0;
    for (int l = 0; l < pointNum; ++l) {
      double sum = sums[l] + y0[l];
      if (sum > max) {
        max = sum;
      }
    }

    return {'y0': y0, 'max': max};
  }
}

class _InnerNode {
  final num value;
  int index = 0;
  double x = 0;
  double py = 0;
  double py0 = 0;

  _InnerNode(this.value);

  void setItemLayout(int index, double px, double py0, double py) {
    this.index = index;
    x = px;
    this.py = py;
    this.py0 = py0;
  }
}

class LayoutNode {
  final GroupData data;
  List<Offset> polygonList = [];
  int index = 0;
  NodeProps cur = NodeProps();
  NodeProps start = NodeProps();
  NodeProps end = NodeProps();

  LayoutNode(this.data);

  late Path _path;

  void _buildPath(List<Offset> pList, List<Offset> pList2, bool smooth, double ratio) {
    Area area = Area(pList, pList2, upSmooth: smooth, downSmooth: smooth, ratioA: ratio, ratioB: ratio);
    _path = area.toPath(true);
    polygonList = [];
    polygonList.addAll(pList);
    polygonList.addAll(pList2.reversed);
  }

  Path get drawPath => _path;

  AreaStyle? style;

  LabelStyle? labelStyle;
}

class NodeProps {
  bool hover = false;
  bool select = false;
}
