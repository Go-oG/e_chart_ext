import 'dart:math' as m;
import 'dart:ui';
import 'package:e_chart/e_chart.dart';

import '../../graph/layout/force/lcg.dart';
import '../pack_node.dart';
import 'siblings.dart';

class PackLayout {
  Fun1<PackNode, num>? _radiusFun;
  Rect _rect = const Rect.fromLTWH(0, 0, 1, 1);
  num _dx = 1;
  num _dy = 1;
  Fun1<PackNode, num> _paddingFun = (a) {
    return 3;
  };

  PackNode layout(PackNode root) {
    LCG random = DefaultLCG();
    root.props.x = _dx / 2;
    root.props.y = _dy / 2;
    if (_radiusFun != null) {
      root.eachBefore(_radiusLeaf(_radiusFun!)).eachAfter(_packChildrenRandom(_paddingFun, 0.5, random)).eachBefore(_translateChild(1));
    } else {
      root
          .eachBefore(_radiusLeaf(_defaultRadius))
          .eachAfter(_packChildrenRandom((e) {
            return 0;
          }, 1, random))
          .eachAfter(_packChildrenRandom(_paddingFun, root.props.r / m.min(_dx, _dy), random))
          .eachBefore(_translateChild(m.min(_dx, _dy) / (2 * root.props.r)));
    }

    ///修正位置
    if (_rect.left != 0 || _rect.top != 0) {
      root.each((p0, p1, p2) {
        p0.props.x += _rect.left;
        p0.props.y += _rect.top;
        return false;
      });
    }
    return root;
  }

  PackLayout radius(Fun1<PackNode, num> fun1) {
    _radiusFun = fun1;
    return this;
  }

  PackLayout size(Rect rect) {
    _rect = rect;
    _dx = rect.width;
    _dy = rect.height;
    return this;
  }

  PackLayout padding(Fun1<PackNode, num> fun1) {
    _paddingFun = fun1;
    return this;
  }
}

double _defaultRadius(PackNode d) {
  return m.sqrt(d.value);
}

bool Function(PackNode, int, PackNode) _radiusLeaf(Fun1<PackNode, num> radiusFun) {
  return (PackNode node, int b, PackNode c) {
    if (node.notChild) {
      double r = m.max(0, radiusFun.call(node)).toDouble();
      node.props.r = r;
    }
    return false;
  };
}

bool Function(PackNode, int, PackNode) _packChildrenRandom(Fun1<PackNode, num> paddingFun, num k, LCG random) {
  return (PackNode node, int b, PackNode c) {
    List<PackNode> children = node.children;
    if (children.isNotEmpty) {
      int i, n = children.length;
      num r = paddingFun(node) * k, e;
      if (r != 0) {
        for (i = 0; i < n; ++i) {
          children[i].props.r += r;
        }
      }
      e = Siblings.packSiblingsRandom(children, random);
      if (r != 0) {
        for (i = 0; i < n; ++i) {
          children[i].props.r -= r;
        }
      }
      node.props.r = e + r.toDouble();
    }
    return false;
  };
}

bool Function(PackNode, int, PackNode) _translateChild(num k) {
  return (PackNode node, int b, PackNode c) {
    var parent = node.parent;
    node.props.r *= k;
    if (parent != null) {
      node.props.x = parent.props.x + k * node.props.x;
      node.props.y = parent.props.y + k * node.props.y;
    }

    return false;
  };
}
