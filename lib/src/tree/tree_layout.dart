import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';
import '../model/tree_data.dart';
import 'node.dart';

abstract class TreeLayout extends ValueNotifier<Command> {
  static const int layoutEnd = 1;
  static const int layoutUpdate = 2;

  ///描述根节点的位置
  List<SNumber> center;
  bool centerIsRoot;

  ///连接线的类型(某些布局只支持某些特定类型)
  LineType lineType;

  ///是否平滑连接线
  bool smooth;

  ///节点大小配置
  Size? nodeSize;
  Fun1<TreeLayoutNode, Size>? sizeFun;

  ///节点之间的间距函数
  Offset? nodeGapSize;
  Fun2<TreeLayoutNode, TreeLayoutNode, Offset>? gapFun;

  ///节点之间的层级间距函数优先级：fun> levelGapSize
  num? levelGapSize;
  Fun2<int, int, num>? levelGapFun;

  Offset _transOffset = Offset.zero;

  TreeLayout({
    this.center = const [SNumber.number(0), SNumber.percent(50)],
    this.lineType = LineType.line,
    this.smooth = false,
    this.centerIsRoot = true,
    this.nodeSize,
    this.sizeFun,
    this.nodeGapSize,
    this.gapFun,
    this.levelGapSize,
    this.levelGapFun,
  }) : super(Command(0));

  //========布局中使用的变量=============
  ///保存数据和节点之间的映射关系，以便在O(1)时间中处理数据
  Map<TreeData, TreeLayoutNode> _nodeMap = {};

  ///外部传入的数据映射
  ///所有的操作都是对该树进行操作
  TreeLayoutNode _rootNode = TreeLayoutNode(null, TreeData(0, []));
  Context? _context;
  num width = 0;
  num height = 0;

  ///记录节点数
  int nodeCount = 0;

  @mustCallSuper
  void doLayout(Context context, TreeData data, num width, num height) {
    _context = context;
    this.width = width;
    this.height = height;
    _nodeMap = {};
    _rootNode = toTree<TreeData, TreeLayoutNode>(data, (p0) => p0.children, (p0, p1) {
      TreeLayoutNode node = TreeLayoutNode(p0, p1);
      _nodeMap[p1] = node;
      return node;
    });
    _startLayout(_rootNode);
  }

  void _startLayout(TreeLayoutNode root, [bool notify = true]) {
    if (_context == null) {
      throw FlutterError('在调用该方法前，必须先调用doLayout一次');
    }
    nodeCount = 0;
    root.each((node, index, startNode) {
      nodeCount += 1;
      return false;
    });

    ///计算树的深度和高度
    root.resetDeep(0);
    root.computeHeight();
    onLayout(_context!, root, width, height);

    ///计算偏移量
    double x = center[0].convert(width);
    double y = center[1].convert(height);
    double dx, dy;
    if (centerIsRoot) {
      dx = x - root.x;
      dy = y - root.y;
    } else {
      Offset c = root.getBoundBox().center;
      dx = x - c.dx;
      dy = y - c.dy;
    }
    root.translate(dx, dy);
    _transOffset = Offset.zero;
    if (notify) {
      notifyLayoutEnd();
    }
  }

  void onLayout(Context context, TreeLayoutNode root, num width, num height);

  TreeLayoutNode get rootNode => _rootNode;

  Offset get translationOffset => _transOffset;

  ///获取父节点和根节点之间的路径
  Path? getPath(TreeLayoutNode parent, TreeLayoutNode child, [List<double>? dash]) {
    Line line = Line([parent.center, child.center]);
    List<Offset> ol = [];
    if (lineType == LineType.step) {
      ol = line.step();
    } else if (lineType == LineType.stepBefore) {
      ol = line.stepBefore();
    } else if (lineType == LineType.stepAfter) {
      ol = line.stepAfter();
    } else {
      ol = [parent.center, child.center];
    }
    if (smooth) {
      return Line(ol, smoothRatio: 0.25, dashList: dash).toPath(false);
    } else {
      return Line(ol, smoothRatio: null, dashList: dash).toPath(false);
    }
  }

  ///折叠一个节点
  void collapseNode(TreeLayoutNode node, [bool runAnimation = true]) {
    var data = node.data;
    TreeLayoutNode clickNode = _nodeMap[data]!;
    if (clickNode.notChild) {
      debugPrint('点击节点无子节点');
      return;
    }

    ///存储旧位置
    Map<TreeData, Offset> oldPositionMap = {};
    Map<TreeData, Size> oldSizeMap = {};
    _rootNode.each((node, index, startNode) {
      oldPositionMap[node.data] = node.center;
      oldSizeMap[node.data] = node.size;
      return false;
    });

    Set<TreeLayoutNode> nodeSet = Set.from(clickNode.descendants());
    nodeSet.remove(clickNode);

    ///移除要折叠的节点
    List<TreeLayoutNode> children = List.from(clickNode.children);
    clickNode.clear();

    ///测量一次布局后的位置
    _startLayout(_rootNode, false);

    ///记录新的位置
    Map<TreeData, Offset> positionMap = {};
    Map<TreeData, Size> sizeMap = {};
    _rootNode.each((node, index, startNode) {
      positionMap[node.data] = node.center;
      sizeMap[node.data] = node.size;
      return false;
    });

    each(children, (node, i) {
      node.each((cNode, index, startNode) {
        positionMap[cNode.data] = clickNode.center;
        sizeMap[cNode.data] = Size.zero;
        return false;
      });
    });

    ///还原现有节点
    for (var n in children) {
      clickNode.add(n);
    }

    doAnimator(_rootNode, oldPositionMap, positionMap, oldSizeMap, sizeMap, () {
      clickNode.clear();
      notifyLayoutEnd();
    });
  }

  ///展开一个节点
  void expandNode(TreeLayoutNode node, [bool runAnimation = true]) {
    var data = node.data;
    TreeLayoutNode tmpNode = _nodeMap[data]!;
    if (tmpNode.hasChild || data.children.isEmpty) {
      return;
    }

    Map<TreeData, Offset> oldPositionMap = {};
    Map<TreeData, Size> oldSizeMap = {};
    if (runAnimation) {
      _rootNode.each((node, index, startNode) {
        oldPositionMap[node.data] = node.center;
        oldSizeMap[node.data] = node.size;
        return false;
      });
    }

    for (var c in data.children) {
      TreeLayoutNode cNode = _nodeMap[c]!;
      tmpNode.add(cNode);
    }

    ///开始重新布局
    if (!runAnimation) {
      _startLayout(_rootNode, true);
      return;
    }
    Offset oldOffset = tmpNode.center;

    ///执行动画
    _startLayout(_rootNode, false);
    Map<TreeData, Offset> positionMap = {};
    Map<TreeData, Size> sizeMap = {};
    _rootNode.each((node, index, startNode) {
      if (!oldPositionMap.containsKey(node.data)) {
        oldPositionMap[node.data] = oldOffset;
        oldSizeMap[node.data] = Size.zero;
      }
      positionMap[node.data] = node.center;
      node.size = getNodeSize(node);
      sizeMap[node.data] = node.size;
      return false;
    });
    doAnimator(_rootNode, oldPositionMap, positionMap, oldSizeMap, sizeMap);
  }

  void doAnimator(
    TreeLayoutNode root,
    Map<TreeData, Offset> oldPositionMap,
    Map<TreeData, Offset> positionMap,
    Map<TreeData, Size> oldSizeMap,
    Map<TreeData, Size> sizeMap, [
    VoidCallback? endCallback,
  ]) {
    ChartDoubleTween tween = ChartDoubleTween(0, 1, duration: const Duration(milliseconds: 600));
    OffsetTween offsetTween = OffsetTween(Offset.zero, Offset.zero);
    ChartSizeTween sizeTween = ChartSizeTween(Size.zero, Size.zero);
    tween.addListener(() {
      double v = tween.value;
      root.each((node, index, startNode) {
        Offset begin = oldPositionMap[node.data] ?? node.center;
        Offset end = positionMap[node.data] ?? node.center;
        offsetTween.changeValue(begin, end);
        Offset p = offsetTween.safeGetValue(v);
        node.x = p.dx;
        node.y = p.dy;
        Size beginSize = oldSizeMap[node.data] ?? Size.zero;
        Size endSize = sizeMap[node.data] ?? node.size;
        sizeTween.changeValue(beginSize, endSize);
        node.size = sizeTween.safeGetValue(v);
        return false;
      });
      notifyLayoutUpdate();
    });
    if (endCallback != null) {
      tween.statusListener = (s) {
        if (s == AnimationStatus.dismissed || s == AnimationStatus.completed) {
          endCallback.call();
        }
      };
    }
    tween.start(_context!);
  }

  TreeLayoutNode? findNode(Offset local) {
    TreeLayoutNode? result;
    _rootNode.eachAfter((node, index, startNode) {
      double d = node.center.distance2(local);
      double r = getNodeSize(node).shortestSide / 2;
      debugPrint('D:$d  R:$r');
      if (d <= r) {
        result = node;
        return true;
      }
      return false;
    });
    return result;
  }

  void notifyLayoutEnd() {
    value = Command(layoutEnd);
  }

  void notifyLayoutUpdate() {
    value = Command(layoutUpdate);
  }

  @override
  void dispose() {
    _context = null;
    super.dispose();
  }

  ///========普通函数=============
  Size getNodeSize(TreeLayoutNode node) {
    Size? size = sizeFun?.call(node) ?? nodeSize;
    if (size != null) {
      return size;
    }
    return const Size.square(8);
  }

  Offset getNodeGap(TreeLayoutNode node1, TreeLayoutNode node2) {
    Offset? offset = gapFun?.call(node1, node2) ?? nodeGapSize;
    if (offset != null) {
      return offset;
    }
    return const Offset(8, 8);
  }

  double getLevelGap(int level1, int level2) {
    if (levelGapFun != null) {
      return levelGapFun!.call(level1, level2).toDouble();
    }
    if (levelGapSize != null) {
      return levelGapSize!.toDouble();
    }
    return 24;
  }
}

enum LineType { line, stepAfter, step, stepBefore }
