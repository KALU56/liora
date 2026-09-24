import 'point_2d.dart';

/// Represents an individual sample point along a touch gesture/stroke.
class TouchPoint {
  final Point2D position;
  final double pressure;
  final DateTime timestamp;

  const TouchPoint({
    required this.position,
    this.pressure = 1.0,
    required this.timestamp,
  });

  TouchPoint copyWith({
    Point2D? position,
    double? pressure,
    DateTime? timestamp,
  }) {
    return TouchPoint(
      position: position ?? this.position,
      pressure: pressure ?? this.pressure,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
