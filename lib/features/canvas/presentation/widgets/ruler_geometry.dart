import 'dart:math' as math;

import 'package:flutter/material.dart';

class RulerGeometry {
  final Offset center;
  final double angle;
  final double length;
  final double thickness;

  const RulerGeometry({
    required this.center,
    required this.angle,
    this.length = 240,
    this.thickness = 44,
  });

  Offset toLocal(Offset canvasPosition) {
    final delta = canvasPosition - center;
    final cosine = math.cos(angle);
    final sine = math.sin(angle);
    return Offset(
      delta.dx * cosine + delta.dy * sine,
      -delta.dx * sine + delta.dy * cosine,
    );
  }

  Offset toCanvas(Offset rulerPosition) {
    final cosine = math.cos(angle);
    final sine = math.sin(angle);
    return center +
        Offset(
          rulerPosition.dx * cosine - rulerPosition.dy * sine,
          rulerPosition.dx * sine + rulerPosition.dy * cosine,
        );
  }

  bool containsBody(Offset canvasPosition) {
    final local = toLocal(canvasPosition);
    return local.dx.abs() <= length / 2 && local.dy.abs() <= thickness / 2;
  }

  bool isOnDrawingEdge(Offset canvasPosition) {
    final local = toLocal(canvasPosition);
    return local.dx.abs() <= length / 2 &&
        (local.dy + thickness / 2).abs() <= 9;
  }

  bool isOnRotationHandle(Offset canvasPosition) {
    final handle = toCanvas(Offset(length / 2 + 20, 0));
    return (canvasPosition - handle).distance <= 22;
  }

  Offset projectToDrawingEdge(Offset canvasPosition) {
    final local = toLocal(canvasPosition);
    return toCanvas(
      Offset(
        local.dx.clamp(-length / 2, length / 2).toDouble(),
        -thickness / 2,
      ),
    );
  }
}
