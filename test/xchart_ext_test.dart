import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int count = 72;
  int n1 = computeMinLevel(count);
  int n2 = computeLevel2(count);
  debugPrint('L1:$n1  L2:$n2');
}

int computeLevel2(int nodeCount) {
  int c = -nodeCount;
  int a = 3;
  int b = -2;
  int x1 = ((-b + sqrt(4 - 4 * a * c)) / 6).round();
  int x2 = ((-b - sqrt(4 - 4 * a * c)) / 6).round();
  if (x1 < 0 && x2 < 0) {
    throw FlutterError('计算异常');
  }
  if ((3 * x1 * x1 - 2 * x1) >= nodeCount) {
    return x1;
  }
  if ((3 * x2 * x2 - 2 * x2) >= nodeCount) {
    return x2;
  }
  return max(x1.abs(), x2.abs()) + 1;
}

int computeMinLevel(int nodeCount) {
  int c = -nodeCount;
  int a = 3;
  int b = -2;
  int x1 = ((-b + sqrt(4 - 4 * a * c)) / 6).round();
  int x2 = ((-b - sqrt(4 - 4 * a * c)) / 6).round();
  if (x1 < 0 && x2 < 0) {
    throw FlutterError('计算异常');
  }
  if (x1>0&&(3 * x1 * x1 - 2 * x1) >= nodeCount) {
    return x1;
  }
  if (x2>0&&(3 * x2 * x2 - 2 * x2) >= nodeCount) {
    return x2;
  }
  return max(x1.abs(), x2.abs()) + 1;
}
