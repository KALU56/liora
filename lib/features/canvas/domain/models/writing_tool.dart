import 'package:flutter/material.dart';

enum WritingToolType { pen, pencil, highlighter, eraser }

enum EraserSize {
  small(16.0),
  large(36.0);

  final double radius;
  const EraserSize(this.radius);
}

class ToolConfig {
  final WritingToolType toolType;
  final Color color;
  final double strokeWidth;
  final double opacity;
  final EraserSize eraserSize;

  const ToolConfig({
    this.toolType = WritingToolType.pen,
    this.color = Colors.black,
    this.strokeWidth = 3.0,
    this.opacity = 1.0,
    this.eraserSize = EraserSize.small,
  });

  ToolConfig copyWith({
    WritingToolType? toolType,
    Color? color,
    double? strokeWidth,
    double? opacity,
    EraserSize? eraserSize,
  }) {
    return ToolConfig(
      toolType: toolType ?? this.toolType,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      opacity: opacity ?? this.opacity,
      eraserSize: eraserSize ?? this.eraserSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toolType': toolType.name,
      'color': color.toARGB32(),
      'strokeWidth': strokeWidth,
      'opacity': opacity,
      'eraserSize': eraserSize.name,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory ToolConfig.fromMap(Map<String, dynamic> map) {
    return ToolConfig(
      toolType: WritingToolType.values.firstWhere(
        (type) => type.name == map['toolType'],
        orElse: () => WritingToolType.pen,
      ),
      color: Color((map['color'] as num?)?.toInt() ?? Colors.black.toARGB32()),
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      opacity: (map['opacity'] as num?)?.toDouble() ?? 1.0,
      eraserSize: EraserSize.values.firstWhere(
        (size) => size.name == map['eraserSize'],
        orElse: () => EraserSize.small,
      ),
    );
  }

  factory ToolConfig.fromJson(Map<String, dynamic> json) =>
      ToolConfig.fromMap(json);

  /// Preset configurations for quick tool selection
  static const ToolConfig defaultPen = ToolConfig(
    toolType: WritingToolType.pen,
    color: Colors.black,
    strokeWidth: 3.0,
    opacity: 1.0,
  );

  static const ToolConfig defaultPencil = ToolConfig(
    toolType: WritingToolType.pencil,
    color: Color(0xFF4A4A4A),
    strokeWidth: 2.0,
    opacity: 0.8,
  );

  static const ToolConfig defaultHighlighter = ToolConfig(
    toolType: WritingToolType.highlighter,
    color: Color(0xFFFFEB3B), // Bright Yellow
    strokeWidth: 16.0,
    opacity: 0.4,
  );

  static const ToolConfig defaultEraser = ToolConfig(
    toolType: WritingToolType.eraser,
    eraserSize: EraserSize.small,
  );
}
