import 'package:flutter/material.dart';

import 'touch_point.dart';
import 'writing_tool.dart';

/// Data structure representing a single independent handwriting stroke object.
class Stroke {
  final String id;
  final List<TouchPoint> points;
  final Color color;
  final double strokeWidth;
  final WritingToolType toolType;
  final double opacity;
  final bool isComplete;

  Stroke({
    required this.id,
    List<TouchPoint>? points,
    this.color = Colors.black,
    this.strokeWidth = 3.0,
    this.toolType = WritingToolType.pen,
    this.opacity = 1.0,
    this.isComplete = false,
  }) : points = points ?? [];

  Stroke copyWith({
    String? id,
    List<TouchPoint>? points,
    Color? color,
    double? strokeWidth,
    WritingToolType? toolType,
    double? opacity,
    bool? isComplete,
  }) {
    return Stroke(
      id: id ?? this.id,
      points: points ?? List.from(this.points),
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      toolType: toolType ?? this.toolType,
      opacity: opacity ?? this.opacity,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Serializes every visual attribute as well as the sampled touch points.
  /// Using a 32-bit ARGB value avoids losing alpha from the selected color.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'points': points.map((point) => point.toMap()).toList(),
      'color': color.toARGB32(),
      'strokeWidth': strokeWidth,
      'toolType': toolType.name,
      'opacity': opacity,
      'isComplete': isComplete,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Stroke.fromMap(Map<String, dynamic> map) {
    final rawPoints = map['points'];
    return Stroke(
      id: map['id'] as String? ?? '',
      points: rawPoints is List
          ? rawPoints
                .whereType<Map>()
                .map(
                  (point) =>
                      TouchPoint.fromMap(Map<String, dynamic>.from(point)),
                )
                .toList()
          : const [],
      color: Color((map['color'] as num?)?.toInt() ?? Colors.black.toARGB32()),
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      toolType: WritingToolType.values.firstWhere(
        (type) => type.name == map['toolType'],
        orElse: () => WritingToolType.pen,
      ),
      opacity: (map['opacity'] as num?)?.toDouble() ?? 1.0,
      isComplete: map['isComplete'] as bool? ?? false,
    );
  }

  factory Stroke.fromJson(Map<String, dynamic> json) => Stroke.fromMap(json);

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
