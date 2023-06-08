import 'dart:math';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

import '../../model/graph/graph.dart';
import '../../model/graph/graph_node.dart';
import '../graph_layout.dart';

///随机布局
class RandomLayout extends GraphLayout {
  List<SNumber> center;

  ///用于处理重叠时的迭代次数
  int maxIterations;

  RandomLayout({
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.maxIterations = 30,
    super.nodeSize,
    super.sizeFun,
    super.nodeSpaceFun,
    super.sort,
    super.workerThread,
  });

  @override
  void doLayout(Context context, Graph graph, num width, num height) {
    stopLayout();
    clearInterrupt();
    if (workerThread) {
      Future.doWhile(() {
        runLayout(context, graph, width, height);
        return false;
      });
    } else {
      runLayout(context, graph, width, height);
    }
  }

  void runLayout(Context context, Graph graph, num width, num height) {
    Random random = Random();
    QuadTree<GraphNode> tree = QuadTree((p0) => p0.x, (p0) => p0.y, 0, 0, width, height);
    num cx = center[0].convert(width);
    num cy = center[1].convert(height);
    num maxRadius = min([width, height]) * 0.4;
    List<GraphNode> nodes = [...graph.nodes];
    if (sort != null) {
      Map<GraphNode, num> sortMap = sort!.call(graph, nodes);
      nodes.sort((a, b) {
        checkInterrupt();
        return (sortMap[a] ?? 0).compareTo((sortMap[b] ?? 0));
      });
    }

    for (var node in nodes) {
      checkInterrupt();
      double nr = getNodeRadius(node);
      num nspace = getNodeSpace(node);
      int c = maxIterations;
      double r = random.nextDouble() * maxRadius;
      double angle = random.nextDouble() * 360;
      while (c > 0) {
        checkInterrupt();
        var a = angle * pi / 180;
        double x = cx + r * cos(a);
        double y = cy + r * sin(a);
        if (!hasCover(tree, x, y, nr, nspace) || c == 1) {
          node.x = x;
          node.y = y;
          tree.add(node);
          break;
        }
        if (random.nextDouble() > 0.5) {
          r += nr / 2;
        } else {
          angle = random.nextDouble() * 360;
        }
        c--;
      }
    }
    notifyLayoutEnd();
  }

  @override
  void stopLayout() {
    super.stopLayout();
    interrupt();
  }
  bool hasCover(QuadTree<GraphNode> tree, double x, double y, double r, num space) {
    bool covered = false;
    tree.each((node, x1, y1, x2, y2) {
      if (covered) {
        return true;
      }
      if (node.data == null) {
        return false;
      }

      var data = node.data!;
      var dx = (data.x - x).abs();
      var dy = (data.y - y).abs();
      var dis = dx * dx + dy * dy;
      var dis2 = r + getNodeRadius(data, true) + space;
      dis2 = dis2 * dis2;
      if (dis < dis2) {
        covered = true;
      }
      return covered;
    });
    return covered;
  }
}
