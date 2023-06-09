import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'layout/layout.dart';
import 'node.dart';
import 'treemap_series.dart';

class LayoutHelper {
  final TreeMapSeries series;
  late TreemapLayout _layout;
  bool _round = true;
  Map<int, num> _paddingStack = {};
  Fun2<TreeMapNode, TreeMapNode, int>? _sort;

  ///内部Children之间的间隔
  Fun1<TreeMapNode, num> _paddingInner = (a) {
    return 0;
  };

  ///自身的内容间距
  Fun1<TreeMapNode, num> _paddingTop = (a) {
    return 0;
  };
  Fun1<TreeMapNode, num> _paddingRight = (a) {
    return 0;
  };
  Fun1<TreeMapNode, num> _paddingBottom = (a) {
    return 0;
  };
  Fun1<TreeMapNode, num> _paddingLeft = (a) {
    return 0;
  };

  LayoutHelper(this.series) {
    _layout = series.layout;
    if (series.paddingInner != null) {
      _paddingInner = series.paddingInner!;
    }
    if (series.paddingLeft != null) {
      _paddingLeft = series.paddingLeft!;
    }
    if (series.paddingTop != null) {
      _paddingTop = series.paddingTop!;
    }
    if (series.paddingRight != null) {
      _paddingRight = series.paddingRight!;
    }
    if (series.paddingBottom != null) {
      _paddingBottom = series.paddingBottom!;
    }
  }


  TreeMapNode layout(Context context,TreeMapNode root, Rect rect) {
    root.setPosition(rect);
    if (_sort != null) {
      root.sort(_sort!, false);
    }
    root.eachBefore((node, index, startNode) {
      _layoutNodeChildren(context,node);
      return false;
    });
    _paddingStack = {};
    if (_round) {
      root.eachBefore(roundNode);
    }
    return root;
  }

  ///布局该节点(不包含子节点)
  void _layoutNodeChildren(Context context,TreeMapNode node) {
    var p = _paddingStack[node.deep] ?? 0;
    ///处理自身的padding
    var rect = node.getPosition();
    var x0 = rect.left + p;
    var y0 = rect.top + p;
    var x1 = rect.right - p;
    var y1 = rect.bottom - p;
    if (x1 < x0) x0 = x1 = (x0 + x1) / 2;
    if (y1 < y0) y0 = y1 = (y0 + y1) / 2;
    node.setPosition( Rect.fromLTRB(x0, y0, x1, y1));
    rect = node.getPosition();
    if (node.hasChild) {
      ///布局孩子
      p = _paddingStack[node.deep + 1] = _paddingInner(node);
      x0 += _paddingLeft(node) - p;
      y0 += _paddingTop(node) - p;
      x1 -= _paddingRight(node) - p;
      y1 -= _paddingBottom(node) - p;
      if (x1 < x0) x0 = x1 = (x0 + x1) / 2;
      if (y1 < y0) y0 = y1 = (y0 + y1) / 2;
      _layout.doLayout(context,node, Rect.fromLTRB(x0, y0, x1, y1));
    }
  }

  bool roundNode(TreeMapNode node, int index, TreeMapNode other) {
    node.setPosition(Rect.fromLTRB(
      node.getPosition().left.roundToDouble(),
      node.getPosition().top.roundToDouble(),
      node.getPosition().right.roundToDouble(),
      node.getPosition().bottom.roundToDouble(),
    ));
    return false;
  }

  set round(bool v) => _round = v;

  set paddingInner(Fun1<TreeMapNode, num> fun) => _paddingInner = fun;

  set paddingTop(Fun1<TreeMapNode, num> fun) => _paddingTop = fun;

  set paddingRight(Fun1<TreeMapNode, num> fun) => _paddingRight = fun;

  set paddingBottom(Fun1<TreeMapNode, num> fun) => _paddingBottom = fun;

  set paddingLeft(Fun1<TreeMapNode, num> fun) => _paddingLeft = fun;

  LayoutHelper sort(Fun2<TreeMapNode, TreeMapNode, int> fun) {
    _sort = fun;
    return this;
  }
}
