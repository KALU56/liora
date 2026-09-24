import '../models/point_2d.dart';
import '../models/stroke.dart';

class EraserService {
  /// Determines if a given stroke intersects with an eraser touch point circle.
  static bool isStrokeIntersected(
    Stroke stroke,
    Point2D eraserCenter,
    double eraserRadius,
  ) {
    if (stroke.points.isEmpty) return false;

    final threshold = eraserRadius + (stroke.strokeWidth / 2);

    if (stroke.points.length == 1) {
      return stroke.points.first.position.distanceTo(eraserCenter) <= threshold;
    }

    for (int i = 0; i < stroke.points.length - 1; i++) {
      final a = stroke.points[i].position;
      final b = stroke.points[i + 1].position;

      if (_isPointNearSegment(eraserCenter, a, b, threshold)) {
        return true;
      }
    }

    return false;
  }

  /// Erases strokes from a list that intersect with the eraser touch point.
  static List<Stroke> eraseStrokesAtPoint(
    List<Stroke> strokes,
    Point2D eraserCenter,
    double eraserRadius,
  ) {
    return strokes
        .where(
          (stroke) => !isStrokeIntersected(stroke, eraserCenter, eraserRadius),
        )
        .toList();
  }

  static bool _isPointNearSegment(
    Point2D point,
    Point2D segA,
    Point2D segB,
    double maxDist,
  ) {
    final dx = segB.x - segA.x;
    final dy = segB.y - segA.y;
    final double l2 = dx * dx + dy * dy;
    if (l2 == 0) return point.distanceTo(segA) <= maxDist;

    final double t =
        (((point.x - segA.x) * dx + (point.y - segA.y) * dy) / l2)
            .clamp(0.0, 1.0);

    final projection = Point2D(
      segA.x + t * dx,
      segA.y + t * dy,
    );

    return point.distanceTo(projection) <= maxDist;
  }
}
