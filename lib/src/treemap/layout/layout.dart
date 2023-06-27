import 'package:e_chart_ext/e_chart_ext.dart';

abstract class TreemapLayout extends ChartLayout<TreeMapSeries,TreeMapNode>{

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
