import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

import '../node.dart';
import '../tree_layout.dart';

class D3TreeLayout extends TreeLayout<TreeLayoutNode> {
  Fun2<TreeLayoutNode, TreeLayoutNode, num> splitFun = (a, b) {
    return a.parent == b.parent ? 1 : 2;
  };
  /// 当该参数为true时，表示布局传入的参数为每层之间的间距
  /// 为false时则表示映射到给定的布局参数
  bool diff = false;

  @override
  void doLayout(Context context, TreeLayoutNode root, num width, num height) {
    num dx = width;
    num dy = height;
    _InnerNode t = _treeRoot(root);
    t.eachAfter(_firstWalk);
    t.parent!.m = -t.z;
    t.eachBefore(_secondWalk);

    if (diff) {
      root.eachBefore((node, b, c) {
        _sizeNode(node, dx, dy);
        return false;
      });
    } else {
      var left = root, right = root, bottom = root;
      root.eachBefore((node, b, c) {
        if (node.x < left.x) left = node;
        if (node.x > right.x) right = node;
        if (node.deep > bottom.deep) bottom = node;
        return false;
      });
      var s = left == right ? 1 : splitFun.call(left, right) / 2,
          tx = s - left.x,
          kx = dx / (right.x + s + tx),
          ky = dy / (jsOr(bottom.deep, 1));
      root.eachBefore((node, b, c) {
        node.x = (node.x + tx) * kx;
        node.y = node.deep * ky;
        return false;
      });
    }
  }

  void _moveSubtree(_InnerNode wm, _InnerNode wp, num shift) {
    var change = shift / (wp.i - wm.i);
    wp.c -= change;
    wp.s += shift;
    wm.c += change;
    wp.z += shift;
    wp.m += shift;
  }

  void _executeShifts(_InnerNode v) {
    num shift = 0.0;
    num change = 0;
    var children = v.children;
    int i = children.length;
    _InnerNode w;
    while (--i >= 0) {
      w = children[i];
      w.z += shift;
      w.m += shift;
      shift += w.s + (change += w.c);
    }
  }

  _InnerNode _nextAncestor(_InnerNode vim, _InnerNode v, _InnerNode ancestor) {
    return vim.a!.parent == v.parent ? vim.a! : ancestor;
  }

  _InnerNode _treeRoot(TreeLayoutNode root) {
    _InnerNode tree = _InnerNode(null, root, 0);
    List<_InnerNode> nodes = [tree];
    List<TreeLayoutNode> children = [];
    while (nodes.isNotEmpty) {
      var node = nodes.removeLast();
      children = node.node!.children;
      if (children.isNotEmpty) {
        node.children.addAll(List.generate(children.length, (index) => _InnerNode(null, null, 0)));
        for (int i = children.length - 1; i >= 0; --i) {
          var child = node.children[i] = _InnerNode(null, children[i], i);
          nodes.add(child);
          child.parent = node;
        }
      }
    }
    var p = _InnerNode(null, null, 0);
    tree.parent = p;
    p.children.add(tree);
    return tree;
  }

  bool _firstWalk(_InnerNode v, b, c) {
    List<_InnerNode> children = v.children;
    var siblings = v.parent!.children;
    _InnerNode? w = isTrue(v.i) ? siblings[v.i - 1] : null;
    if (children.isNotEmpty) {
      _executeShifts(v);
      var midpoint = (children[0].z + children[children.length - 1].z) / 2;
      if (isTrue(w)) {
        v.z = w!.z + splitFun.call(v.node!, w.node!);
        v.m = v.z - midpoint;
      } else {
        v.z = midpoint;
      }
    } else if (isTrue(w)) {
      v.z = w!.z + splitFun.call(v.node!, w.node!);
    }
    v.parent?.A = _apportion(v, w, jsOr(v.parent?.A, siblings[0]));
    return false;
  }

  bool _secondWalk(_InnerNode v, b, c) {
    v.node!.x = v.z + v.parent!.m;
    v.m += v.parent!.m;
    return false;
  }

  _InnerNode _apportion(_InnerNode v, _InnerNode? w, _InnerNode ancestor) {
    if (w != null) {
      _InnerNode? vip = v;
      _InnerNode vop = v;
      _InnerNode? vim = w;
      _InnerNode vom = vip.parent!.children[0];
      num sip = vip.m;
      num sop = vop.m;
      num sim = vim.m;
      num som = vom.m;
      num shift;
      while (true) {
        vim = _nextRight(vim!);
        vip = _nextLeft(vip!);
        if (!jsAnd2(vim, vip)) {
          break;
        }

        vom = _nextLeft(vom)!;
        vop = _nextRight(vop)!;
        vop.a = v;
        shift = vim!.z + sim - vip!.z - sip + splitFun.call(vim.node!, vip.node!);
        if (shift > 0) {
          _moveSubtree(_nextAncestor(vim, v, ancestor), v, shift);
          sip += shift;
          sop += shift;
        }
        sim += vim.m;
        sip += vip.m;
        som += vom.m;
        sop += vop.m;
      }
      if (isTrue(vim) && !isTrue(_nextRight(vop))) {
        vop.t = vim!;
        vop.m += sim - sop;
      }
      if (isTrue(vip) && !isTrue(_nextLeft(vom))) {
        vom.t = vip!;
        vom.m += sip - som;
        ancestor = v;
      }
    }
    return ancestor;
  }

  void _sizeNode(TreeLayoutNode node, num dx, num dy) {
    node.x *= dx;
    node.y = node.deep * dy;
  }

  _InnerNode? _nextLeft(_InnerNode v) {
    var children = v.children;
    return children.isNotEmpty ? children[0] : v.t;
  }

  _InnerNode? _nextRight(_InnerNode v) {
    var children = v.children;
    return children.isNotEmpty ? children[children.length - 1] : v.t;
  }
}

class _InnerNode extends TreeNode<_InnerNode> {
  TreeLayoutNode? node;
  int i;
  _InnerNode? A; // default ancestor
  _InnerNode? a; // ancestor
  num z = 0; // prelim
  num m = 0; // mod
  num c = 0; // change
  num s = 0; // shift
  _InnerNode? t; // thread
  num x = 0;
  num y = 0;

  _InnerNode(super.parent, this.node, this.i) {
    a = this;
  }
}
