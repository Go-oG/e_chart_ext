library e_chart_ext;

import 'package:e_chart/e_chart.dart';

import 'src/gauge/gauge_chart.dart';
import 'src/gauge/gauge_series.dart';
import 'src/graph/graph_chart.dart';
import 'src/graph/graph_series.dart';
import 'src/hexbin/hex_bin_chart.dart';
import 'src/hexbin/hex_bin_series.dart';
import 'src/pack/pack_chart.dart';
import 'src/pack/pack_series.dart';
import 'src/sankey/sankey_chart.dart';
import 'src/sankey/sankey_series.dart';
import 'src/sunburst/sunburst_chart.dart';
import 'src/sunburst/sunburst_series.dart';
import 'src/themeriver/theme_river_chart.dart';
import 'src/themeriver/theme_river_series.dart';
import 'src/tree/tree_chart.dart';
import 'src/tree/tree_series.dart';
import 'src/treemap/treemap_chart.dart';
import 'src/treemap/treemap_series.dart';

export 'src/gauge/gauge_point.dart';
export 'src/gauge/gauge_series.dart';

export 'src/graph/index.dart';

export 'src/hexbin/layout/hex_layout.dart' hide Orientation;
export 'src/hexbin/layout/hex_hexagons_layout.dart';
export 'src/hexbin/layout/hex_parallel_layout.dart';
export 'src/hexbin/layout/hex_rect_layout.dart';
export 'src/hexbin/layout/hex_triangle_layout.dart';
export 'src/hexbin/hex.dart';
export 'src/hexbin/hex_bin_node.dart';
export 'src/hexbin/hex_bin_series.dart';

export 'src/model/graph/graph.dart';
export 'src/model/graph/graph_node.dart';
export 'src/model/graph/edge.dart';
export 'src/model/tree_data.dart';

export 'src/pack/pack_series.dart';
export 'src/pack/pack_node.dart';

export 'src/sankey/sankey_series.dart';
export 'src/sankey/sankey_align.dart';
export 'src/sankey/sort.dart';
export 'src/sankey/layout_node.dart';

export 'src/sunburst/sunburst_series.dart';

export 'src/themeriver/theme_river_series.dart';

export 'src/tree/layout/compact_layout.dart';
export 'src/tree/layout/d3_tree_layout.dart' hide InnerNode;
export 'src/tree/layout/d3_dendrogram_layout.dart';
export 'src/tree/layout/dendrogram_layout.dart';
export 'src/tree/layout/indented_layout.dart';
export 'src/tree/layout/mindmap_layout.dart';
export 'src/tree/layout/radial_layout.dart';
export 'src/tree/node.dart';
export 'src/tree/tree_layout.dart';
export 'src/tree/tree_series.dart';

export 'src/treemap/layout/binary.dart' hide BinaryNode;
export 'src/treemap/layout/dice.dart';
export 'src/treemap/layout/layout.dart';
export 'src/treemap/layout/resquarify.dart';
export 'src/treemap/layout/slice.dart';
export 'src/treemap/layout/slice_dice.dart';
export 'src/treemap/layout/square.dart' hide Row;
export 'src/treemap/node.dart';
export 'src/treemap/treemap_series.dart';

export 'package:dart_dagre/dart_dagre.dart';
export 'package:e_chart/e_chart.dart';

class ChartExtConvert implements SeriesConvert {
  @override
  ChartView? convert(ChartSeries series) {
    if (series is GaugeSeries) {
      return GaugeView(series);
    }
    if (series is GraphSeries) {
      return GraphView(series);
    }
    if (series is PackSeries) {
      return PackView(series);
    }
    if (series is SankeySeries) {
      return SankeyView(series);
    }
    if (series is ThemeRiverSeries) {
      return ThemeRiverView(series);
    }
    if (series is TreeSeries) {
      return TreeView(series);
    }
    if (series is TreeMapSeries) {
      return TreeMapView(series);
    }
    if (series is SunburstSeries) {
      return SunburstView(series);
    }
    if (series is HexbinSeries) {
      return HexbinView(series);
    }
    return null;
  }
}
