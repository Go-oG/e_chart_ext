
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import '../node.dart';
import '../tree_layout.dart';

/// 生态树布局
/// 布局时不考虑节点大小总是将其视作为1，
/// 并且所有的叶子节点总是占满对应的尺寸
class DendrogramLayout extends TreeLayout<TreeLayoutNode> {
  ///分隔函数，用于分隔节点间距
  Fun2<TreeLayoutNode, TreeLayoutNode, num> splitFun = (a, b) {
    return a.parent == b.parent ? 1 : 2;
  };

  /// 当该参数为true时，表示布局传入的参数为每层之间的间距
  /// 为false时则表示映射到给定的布局参数
  bool diff;

  Direction2 direction;

  DendrogramLayout({
    this.direction = Direction2.ttb,
    this.diff = false,
  });

  @override
  void doLayout(Context context, TreeLayoutNode root, num width, num height) {
    bool v = direction == Direction2.ttb || direction == Direction2.btt || direction == Direction2.v;
    num w = v ? width : height;
    num h = v ? height : width;
    _innerLayout(root, diff, w, h);
    onLayoutEnd();
  }

  void _innerLayout(TreeLayoutNode root, bool diff, num dx, num dy) {
    ///第一步计算初始化位置(归一化)
    TreeLayoutNode? preNode;
    num x = 0;
    root.eachAfter((node, index, startNode) {
      if (node.hasChild) {
        //求平均值(居中)
        node.x = aveBy<TreeLayoutNode>(node.children, (p0) => p0.x);
        ///Y方向倒序(root在最下面(值最大))
        node.y = 1 + maxBy<TreeLayoutNode>(node.children, (p0) => p0.y).y;
      } else {
        node.x = preNode != null ? (x += splitFun(node, preNode!)) : 0;
        node.y = 0;
        preNode = node;
      }
      return false;
    });

    ///进行坐标映射
    TreeFun<TreeLayoutNode> fun;
    if (diff) {
      ///将坐标直接进行映射
      fun = (TreeLayoutNode node, b, c) {
        node.x = (node.x - root.x) * dx;
        node.y = (root.y - node.y) * dy;
        return false;
      };
    } else {
      TreeLayoutNode left = root.leafLeft();
      TreeLayoutNode right = root.leafRight();

      ///修正偏移
      num x0 = left.x - splitFun.call(left, right) / 2;
      num x1 = right.x + splitFun.call(right, left) / 2;
      fun = (TreeLayoutNode node, b, c) {
        node.x = (node.x - x0) / (x1 - x0) * dx;
        ///将 Y倒置并映射位置
        node.y = (1 - (root.y != 0 ? (node.y / root.y) : 1)) * dy;
        return false;
      };
    }
    root.eachAfter(fun);
    if (direction == Direction2.ttb) {
      return;
    }
    var ll = root.leaves();
    num maxV = maxBy<TreeLayoutNode>(ll, (p0) => p0.y).y;

    ///修正方向
    root.each((node, index, startNode) {
      if (direction == Direction2.btt) {
        node.y = (maxV - node.y);
      } else if (direction == Direction2.ltr || direction == Direction2.rtl) {
        num t = node.x;
        node.x = node.y;
        node.y = t;
        if (direction == Direction2.rtl) {
          node.x = maxV - node.x;
        }
      }
      return false;
    });
  }
}
