import 'dart:math' as m;
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart_ext/src/hexbin/hex_bin_node.dart';
import 'package:e_chart_ext/src/hexbin/hex_bin_series.dart';
import 'package:flutter/widgets.dart';
import '../hex.dart';
import 'hex_layout.dart';

///三角形布局
///将忽略 flat
class HexTriangleLayout extends HexbinLayout {
  Direction2 direction;

  HexTriangleLayout({
    this.direction = Direction2.ttb,
    super.center = const [SNumber.percent(50), SNumber.percent(50)],
    super.flat,
    super.radius,
  });

  int _level = 0;

  void checkFlat() {
    Direction2 direction = this.direction;
    if (direction == Direction2.v) {
      direction = Direction2.ttb;
    } else if (direction == Direction2.h) {
      direction = Direction2.ltr;
    }
    flat = !(direction == Direction2.ttb || direction == Direction2.btt);
  }

  @override
  void doLayout(Context context,HexbinSeries series, List<HexbinNode> nodes, num width, num height) {
    checkFlat();
    super.doLayout(context,series, nodes, width, height);
  }

  @override
  void onLayout(HexbinSeries series, List<HexbinNode> nodes, num width, num height) {
    Direction2 direction = this.direction;
    if (direction == Direction2.v) {
      direction = Direction2.ttb;
    } else if (direction == Direction2.h) {
      direction = Direction2.ltr;
    }
    _level = computeLevel(nodes.length);
    List<Hex> hexList = triangle(_level, direction);
    each(nodes, (node, i) {
      node.hex = hexList[i];
    });
  }

  @override
  Offset computeZeroCenter(HexbinSeries series, num width, num height) {
    Direction2 direction = this.direction;
    if (direction == Direction2.v) {
      direction = Direction2.ttb;
    } else if (direction == Direction2.h) {
      direction = Direction2.ltr;
    }
    double x = center[0].convert(width);
    double y = center[1].convert(height);
    if (direction == Direction2.ttb || direction == Direction2.btt) {
      ///竖直
      double h = radius * 2;
      double cx = x;
      double cy;
      int c = _level ~/ 2;
      double d;
      if (_level % 2 == 0) {
        d = c * (h + radius);
      } else {
        d = (c + 1) * h + (c * radius);
      }
      d = d / 2;
      d-=radius;
      cy = direction == Direction2.ttb ? y - d : y + d;
      return Offset(cx, cy);
    } else {
      /// 水平
      double w = radius * 2;
      double cy = y;
      double cx;
      double d;
      int c = _level ~/ 2;
      if (_level % 2 == 0) {
        d = c * (w + radius);
      } else {
        d = (c + 1) * w + (c * radius);
      }
      d = d / 2;
      d -= radius;
      cx = direction == Direction2.ltr ?x - d : x + d;
      return Offset(cx, cy);
    }
  }

  List<Hex> triangle(int levelCount, Direction2 direction) {
    List<Hex> hexList = [];
    if (direction == Direction2.ttb) {
      for (int i = 0; i < levelCount; i++) {
        int s = levelCount - i - 1;
        int e = s + i;
        for (int j = s; j <= e; j++) {
          var q = j - levelCount + 1;
          var r = i;
          hexList.add(Hex(q, r, -q - r));
        }
      }
      return hexList;
    }

    if (direction == Direction2.btt) {
      for (int r = levelCount - 1; r >= 0; r--) {
        for (int q = 0; q < levelCount - r; q++) {
          var t = r - (levelCount - 1);
          hexList.add(Hex(q, t, -q - t));
        }
      }
      return hexList;
    }

    if (direction == Direction2.ltr) {
      for (int q = 0; q < levelCount; q++) {
        int e = -q;
        int s = -2 * q;
        for (int r = e; r >= s; r--) {
          var t = -q - r - q;
          Hex hex = Hex(q, t, -q - t);
          hexList.add(hex);
        }
      }
      return hexList;
    }

    if (direction == Direction2.rtl) {
      for (int q = levelCount - 1; q >= 0; q--) {
        var t = q - levelCount + 1;
        int s = 0;
        int e = s + levelCount - q - 1;
        for (int r = s; r <= e; r++) {
          hexList.add(Hex(t, r, -t - r));
        }
      }
      return hexList;
    }

    return hexList;
  }

  ///计算当采用三角形排列时需要的层数
  int computeLevel(int nodeCount) {
    num a = 0.5;
    num b = 0.5;
    int c = -nodeCount;
    num b24ac = m.sqrt(b * b - 4 * a * c);
    num a2 = a * 2;
    int x1 = ((-b + b24ac) / a2).round();
    int x2 = ((-b - b24ac) / a2).round();
    if (x1 < 0 && x2 < 0) {
      throw FlutterError('计算异常');
    }

    if ((x1 + (x1 * (x1 - 1)) / 2) >= nodeCount) {
      return x1;
    }
    if ((x2 + (x2 * (x2 - 1)) / 2) >= nodeCount) {
      return x2;
    }
    return m.max(x1.abs(), x2.abs()) + 1;
  }
}
