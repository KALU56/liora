import 'package:flutter/material.dart';

/// Represents an individual sample point along a touch gesture/stroke.
class TouchPoint {
  final Offset offset;
  final double pressure;
  final DateTime timestamp;

  const TouchPoint({
    required this.offset,
    this.pressure = 1.0,
    required this.timestamp,
  });

  TouchPoint copyWith({Offset? offset, double? pressure, DateTime? timestamp}) {
    return TouchPoint(
      offset: offset ?? this.offset,
      pressure: pressure ?? this.pressure,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dx': offset.dx,
      'dy': offset.dy,
      'pressure': pressure,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TouchPoint.fromMap(Map<String, dynamic> map) {
    return TouchPoint(
      offset: Offset(
        (map['dx'] as num?)?.toDouble() ?? 0.0,
        (map['dy'] as num?)?.toDouble() ?? 0.0,
      ),
      pressure: (map['pressure'] as num?)?.toDouble() ?? 1.0,
      timestamp: map['timestamp'] is String
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
