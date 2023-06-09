import 'package:e_chart/e_chart.dart';

class TreeData {
  final String? id;
  num value;
  List<TreeData> children;

  DynamicText? label;

  TreeData(this.value, this.children, {this.label, this.id});

  TreeData.label(this.label, this.children, {this.id}) : value = 0;

  @override
  int get hashCode {
    if (id == null || id!.isEmpty) {
      return super.hashCode;
    }
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is! TreeData) {
      return false;
    }
    bool a = other.id == null || other.id!.isEmpty;
    bool b = id == null || id!.isEmpty;
    if (a != b) {
      return false;
    }
    return a ? true : (other.id! == id!);
  }

  @override
  String toString() {
    return (label == null || label!.isEmpty) ? '$value' : '$label';
  }

  static int computeDeep(TreeData data) {
    List<TreeData> dl = [data];
    int deep = 0;
    List<TreeData> next = [];
    while (dl.isNotEmpty) {
      for (var element in dl) {
        next.addAll(element.children);
      }
      if (next.isEmpty) {
        break;
      }
      deep += 1;
      dl = next;
      next = [];
    }
    return deep;
  }
}
