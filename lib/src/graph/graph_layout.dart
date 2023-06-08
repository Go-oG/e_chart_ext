import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

import '../model/graph/graph.dart';
import '../model/graph/graph_node.dart';

abstract class GraphLayout extends ValueNotifier<Command> {
  static const int layoutEnd = 1;
  static const int layoutUpdate = 2;

  ///是否在工作线程中布局
  bool workerThread;

  ///节点大小获取优先级: Node.size>sizeFun>>nodeSize>default（8）
  Size? nodeSize;
  Fun1<GraphNode, Size>? sizeFun;
  Fun2<Graph, List<GraphNode>, Map<GraphNode, num>>? sort;
  Fun1<GraphNode, num>? nodeSpaceFun;

  GraphLayout({
    this.nodeSize,
    this.sizeFun,
    this.nodeSpaceFun,
    this.sort,
    this.workerThread = false,
  }) : super(Command(0));

  void notifyLayoutEnd() {
    if (!hasInterrupted) {
      value = Command(layoutEnd);
    }
  }

  void notifyLayoutUpdate() {
    if (!hasInterrupted) {
      value = Command(layoutUpdate);
    }
  }

  void doLayout(Context context, Graph graph, num width, num height);

  void stopLayout() {}

  ///给定一个节点返回节点的大小
  Size getNodeSize(GraphNode node) {
    if (nodeSize != null) {
      return nodeSize!;
    }
    Size size = Size.zero;
    if (sizeFun != null) {
      size = sizeFun!.call(node);
    }
    if (size.width <= 0 || size.height <= 0) {
      size = const Size.square(8);
    }
    return size;
  }

  ///获取节点的半径大小
  double getNodeRadius(GraphNode node, [bool maxValue = false]) {
    Size size = getNodeSize(node);
    if (maxValue) {
      return max(size.width, size.height) * 0.5;
    } else {
      return min(size.width, size.height) * 0.5;
    }
  }

  ///获取节点间距
  num getNodeSpace(GraphNode node) {
    return nodeSpaceFun?.call(node) ?? 8;
  }

  void sortNode(Graph graph, List<GraphNode> list, [bool asc = false]) {
    if (sort == null) {
      return;
    }
    Map<GraphNode, num> sortMap = sort!.call(graph, list);
    list.sort((a, b) {
      num av = sortMap[a] ?? 0;
      num bv = sortMap[b] ?? 0;
      if (asc) {
        return av.compareTo(bv);
      } else {
        return bv.compareTo(av);
      }
    });
  }

  ///返回Graph应该平移的偏移量
  Offset getTranslationOffset(num width, num height) {
    return Offset.zero;
  }

  ///是否允许运行
  bool _allowRun = true;

  void clearInterrupt() {
    _allowRun = true;
  }

  void interrupt() {
    _allowRun = false;
  }

  void checkInterrupt() {
    if (!_allowRun) {
      throw FlutterError('当前已经被中断了');
    }
  }

  bool get hasInterrupted => !_allowRun;
}
