import 'package:flutter/material.dart';

import '../../domain/models/argb_color.dart';
import '../../domain/models/canvas_action.dart';
import '../../domain/models/stroke.dart';
import '../../domain/models/writing_tool.dart';

/// Current callbacks and tool settings used by canvas pointer interactions.
class HandwritingCanvasConfiguration {
  final bool isDrawingMode;
  final ToolConfig toolConfig;
  final Color currentColor;
  final double currentStrokeWidth;
  final ValueChanged<List<Stroke>>? onStrokesChanged;
  final ValueChanged<CanvasAction>? onActionRecorded;
  final ValueChanged<Offset>? onCanvasTapDown;
  final ValueChanged<Offset>? onCanvasPointerMove;
  final ValueChanged<Offset>? onCanvasPointerUp;
  final bool Function(Offset position)? onCanvasPointerDownIntercept;
  final VoidCallback? onRulerDismissed;

  const HandwritingCanvasConfiguration({
    required this.isDrawingMode,
    required this.toolConfig,
    required this.currentColor,
    required this.currentStrokeWidth,
    this.onStrokesChanged,
    this.onActionRecorded,
    this.onCanvasTapDown,
    this.onCanvasPointerMove,
    this.onCanvasPointerUp,
    this.onCanvasPointerDownIntercept,
    this.onRulerDismissed,
  });

  ToolConfig get effectiveToolConfig {
    if (toolConfig.toolType == WritingToolType.pen &&
        (currentColor != Colors.black || currentStrokeWidth != 3)) {
      return toolConfig.copyWith(
        color: ArgbColor(currentColor.toARGB32()),
        strokeWidth: currentStrokeWidth,
      );
    }
    return toolConfig;
  }
}
