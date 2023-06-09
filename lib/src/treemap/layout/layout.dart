import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../node.dart';

abstract class TreemapLayout extends ChartLayout{
  ///给定一个区域范围和节点，对该节点的Children进行布局(不包含孩子的孩子)
  void doLayout(Context context,TreeMapNode root, Rect area);
}

///计算所有子节点的比例和
///因为(parent节点的数据>=children的数据和)
///因此会出现无法占满的情况，因此在treeMap中需要归一化
double computeAllRatio(List<TreeMapNode> list) {
  double area = 0;
  for (var element in list) {
    area += element.areaRatio;
  }
  return area;
}
