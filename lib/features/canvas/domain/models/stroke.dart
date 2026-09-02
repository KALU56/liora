import 'package:flutter/material.dart';

import 'touch_point.dart';

/// Data structure representing a single independent handwriting stroke object.
class Stroke {
  final String id;
  final List<TouchPoint> points;
  final Color color;
  final double strokeWidth;
  final bool isComplete;

  Stroke({
    required this.id,
    List<TouchPoint>? points,
    this.color = Colors.black,
    this.strokeWidth = 3.0,
    this.isComplete = false,
  }) : points = points ?? [];

  Stroke copyWith({
    String? id,
    List<TouchPoint>? points,
    Color? color,
    double? strokeWidth,
    bool? isComplete,
  }) {
    return Stroke(
      id: id ?? this.id,
      points: points ?? List.from(this.points),
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Converts stroke points into a smooth quadratic bezier curve Path object.
  Path toPath() {
    final Path path = Path();
    if (points.isEmpty) return path;

    if (points.length == 1) {
      final p = points.first.offset;
      path.addOval(Rect.fromCircle(center: p, radius: strokeWidth / 2));
      return path;
    }

    path.moveTo(points.first.offset.dx, points.first.offset.dy);

    for (int i = 1; i < points.length - 1; i++) {
      final p0 = points[i].offset;
      final p1 = points[i + 1].offset;
      final midX = (p0.dx + p1.dx) / 2;
      final midY = (p0.dy + p1.dy) / 2;
      path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
    }

    if (points.length > 1) {
      path.lineTo(points.last.offset.dx, points.last.offset.dy);
    }

    return path;
  }
}
