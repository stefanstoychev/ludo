import 'package:vector_math/vector_math.dart';
import 'dart:math';

class Rotator {

  List<List<int>> rotate(List<List<int>> input) {

    var vectors = input.map((e) => Vector2(e[0].toDouble(), e[1].toDouble()));

    var rotation = Matrix2.rotation(pi/2.0);

    return vectors
        .map((e) => rotation.transform(e))
        .map((e) => [e.x.toInt() + 14, e.y.toInt()].toList())
        .toList();
  }
}
