import 'argb_color.dart';
import 'touch_point.dart';
import 'writing_tool.dart';

/// Data structure representing a single independent handwriting stroke object.
class Stroke {
  final String id;
  final List<TouchPoint> points;
  final ArgbColor color;
  final double strokeWidth;
  final WritingToolType toolType;
  final double opacity;
  final bool isComplete;

  Stroke({
    required this.id,
    List<TouchPoint>? points,
    this.color = const ArgbColor(0xFF000000),
    this.strokeWidth = 3.0,
    this.toolType = WritingToolType.pen,
    this.opacity = 1.0,
    this.isComplete = false,
  }) : points = points ?? [];

  Stroke copyWith({
    String? id,
    List<TouchPoint>? points,
    ArgbColor? color,
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

}
