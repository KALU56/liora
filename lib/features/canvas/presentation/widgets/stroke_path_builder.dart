import 'package:flutter/material.dart';

import '../../domain/models/stroke.dart';

/// Converts a domain stroke into a Flutter path for rendering.
class StrokePathBuilder {
  const StrokePathBuilder();

  Path build(Stroke stroke) {
    final path = Path();
    if (stroke.points.isEmpty) return path;

    if (stroke.points.length == 1) {
      final point = stroke.points.first.position;
      path.addOval(
        Rect.fromCircle(
          center: Offset(point.x, point.y),
          radius: stroke.strokeWidth / 2,
        ),
      );
      return path;
    }

    path.moveTo(stroke.points.first.position.x, stroke.points.first.position.y);

    for (var index = 1; index < stroke.points.length - 1; index++) {
      final current = stroke.points[index].position;
      final next = stroke.points[index + 1].position;
      final midpoint = Offset(
        (current.x + next.x) / 2,
        (current.y + next.y) / 2,
      );
      path.quadraticBezierTo(current.x, current.y, midpoint.dx, midpoint.dy);
    }

    path.lineTo(stroke.points.last.position.x, stroke.points.last.position.y);
    return path;
  }
}
