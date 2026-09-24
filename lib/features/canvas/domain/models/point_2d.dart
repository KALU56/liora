import 'dart:math' as math;

class Point2D {
  final double x;
  final double y;

  const Point2D(this.x, this.y);

  double distanceTo(Point2D other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double get distanceSquared => x * x + y * y;

  @override
  bool operator ==(Object other) {
    return other is Point2D && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}
