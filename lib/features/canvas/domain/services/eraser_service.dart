import 'package:flutter/material.dart';

import '../models/stroke.dart';

class EraserService {
  /// Determines if a given stroke intersects with an eraser touch point circle.
  static bool isStrokeIntersected(
    Stroke stroke,
    Offset eraserCenter,
    double eraserRadius,
  ) {
    if (stroke.points.isEmpty) return false;

    final threshold = eraserRadius + (stroke.strokeWidth / 2);

    if (stroke.points.length == 1) {
      return (stroke.points.first.offset - eraserCenter).distance <= threshold;
    }

    for (int i = 0; i < stroke.points.length - 1; i++) {
      final a = stroke.points[i].offset;
      final b = stroke.points[i + 1].offset;

      if (_isPointNearSegment(eraserCenter, a, b, threshold)) {
        return true;
      }
    }

    return false;
  }

  /// Erases strokes from a list that intersect with the eraser touch point.
  static List<Stroke> eraseStrokesAtPoint(
    List<Stroke> strokes,
    Offset eraserCenter,
    double eraserRadius,
  ) {
    return strokes
        .where((stroke) => !isStrokeIntersected(stroke, eraserCenter, eraserRadius))
        .toList();
  }

  static bool _isPointNearSegment(
    Offset point,
    Offset segA,
    Offset segB,
    double maxDist,
  ) {
    final double l2 = (segB - segA).distanceSquared;
    if (l2 == 0) return (point - segA).distance <= maxDist;

    final double t = (((point.dx - segA.dx) * (segB.dx - segA.dx) +
                (point.dy - segA.dy) * (segB.dy - segA.dy)) /
            l2)
        .clamp(0.0, 1.0);

    final Offset projection = Offset(
      segA.dx + t * (segB.dx - segA.dx),
      segA.dy + t * (segB.dy - segA.dy),
    );

    return (point - projection).distance <= maxDist;
  }
}
