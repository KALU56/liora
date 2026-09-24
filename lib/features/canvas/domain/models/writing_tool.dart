import 'argb_color.dart';

enum WritingToolType { pen, pencil, highlighter, eraser }

enum EraserSize {
  small(16.0),
  large(36.0);

  final double radius;
  const EraserSize(this.radius);
}

class ToolConfig {
  final WritingToolType toolType;
  final ArgbColor color;
  final double strokeWidth;
  final double opacity;
  final EraserSize eraserSize;

  const ToolConfig({
    this.toolType = WritingToolType.pen,
    this.color = const ArgbColor(0xFF000000),
    this.strokeWidth = 3.0,
    this.opacity = 1.0,
    this.eraserSize = EraserSize.small,
  });

  ToolConfig copyWith({
    WritingToolType? toolType,
    ArgbColor? color,
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

  /// Preset configurations for quick tool selection
  static const ToolConfig defaultPen = ToolConfig(
    toolType: WritingToolType.pen,
    color: ArgbColor(0xFF000000),
    strokeWidth: 3.0,
    opacity: 1.0,
  );

  static const ToolConfig defaultPencil = ToolConfig(
    toolType: WritingToolType.pencil,
    color: ArgbColor(0xFF4A4A4A),
    strokeWidth: 2.0,
    opacity: 0.8,
  );

  static const ToolConfig defaultHighlighter = ToolConfig(
    toolType: WritingToolType.highlighter,
    color: ArgbColor(0xFFFFEB3B),
    strokeWidth: 16.0,
    opacity: 0.4,
  );

  static const ToolConfig defaultEraser = ToolConfig(
    toolType: WritingToolType.eraser,
    eraserSize: EraserSize.small,
  );
}
