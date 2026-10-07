import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/canvas/presentation/widgets/ruler_geometry.dart';

void main() {
  test('ruler transforms preserve positions at any angle', () {
    const ruler = RulerGeometry(center: Offset(180, 240), angle: math.pi / 3);
    const localPoint = Offset(64, -11);

    expect(ruler.toLocal(ruler.toCanvas(localPoint)).dx, closeTo(64, 0.001));
    expect(ruler.toLocal(ruler.toCanvas(localPoint)).dy, closeTo(-11, 0.001));
  });

  test(
    'ruler edge projection stays straight and clamps to the edge length',
    () {
      const ruler = RulerGeometry(
        center: Offset(100, 120),
        angle: math.pi / 4,
        length: 200,
        thickness: 40,
      );
      final snapped = ruler.projectToDrawingEdge(const Offset(500, 500));
      final local = ruler.toLocal(snapped);

      expect(local.dx, 100);
      expect(local.dy, closeTo(-20, 0.001));
      expect(
        ruler.isOnDrawingEdge(ruler.toCanvas(const Offset(0, -20))),
        isTrue,
      );
      expect(
        ruler.isOnRotationHandle(ruler.toCanvas(const Offset(120, 0))),
        isTrue,
      );
    },
  );
}
