import 'package:flutter/material.dart';

import '../../application/canvas_use_cases.dart';
import '../../domain/models/canvas_action.dart';
import '../../domain/models/stroke.dart';
import '../../domain/models/writing_tool.dart';
import 'handwriting_canvas_configuration.dart';
import 'handwriting_canvas_interaction_controller.dart';
import 'stroke_painter.dart';

/// Captures canvas gestures and composes the child page with rendered strokes.
class HandwritingCanvasWidget extends StatefulWidget {
  final List<Stroke> strokes;
  final ValueChanged<List<Stroke>>? onStrokesChanged;
  final ValueChanged<CanvasAction>? onActionRecorded;
  final ValueChanged<Offset>? onCanvasTapDown;
  final ValueChanged<Offset>? onCanvasPointerMove;
  final ValueChanged<Offset>? onCanvasPointerUp;
  final bool Function(Offset position)? onCanvasPointerDownIntercept;
  final VoidCallback? onRulerDismissed;
  final bool isDrawingMode;
  final ToolConfig toolConfig;
  final Color currentColor;
  final double currentStrokeWidth;
  final Widget? child;
  final CanvasUseCases? canvasUseCases;

  const HandwritingCanvasWidget({
    super.key,
    required this.strokes,
    this.onStrokesChanged,
    this.onActionRecorded,
    this.onCanvasTapDown,
    this.onCanvasPointerMove,
    this.onCanvasPointerUp,
    this.onCanvasPointerDownIntercept,
    this.onRulerDismissed,
    this.isDrawingMode = true,
    this.toolConfig = const ToolConfig(),
    this.currentColor = Colors.black,
    this.currentStrokeWidth = 3,
    this.child,
    this.canvasUseCases,
  });

  @override
  State<HandwritingCanvasWidget> createState() =>
      _HandwritingCanvasWidgetState();
}

class _HandwritingCanvasWidgetState extends State<HandwritingCanvasWidget> {
  late final HandwritingCanvasInteractionController _interaction;

  HandwritingCanvasConfiguration _configurationFor(
    HandwritingCanvasWidget widget,
  ) => HandwritingCanvasConfiguration(
    isDrawingMode: widget.isDrawingMode,
    toolConfig: widget.toolConfig,
    currentColor: widget.currentColor,
    currentStrokeWidth: widget.currentStrokeWidth,
    onStrokesChanged: widget.onStrokesChanged,
    onActionRecorded: widget.onActionRecorded,
    onCanvasTapDown: widget.onCanvasTapDown,
    onCanvasPointerMove: widget.onCanvasPointerMove,
    onCanvasPointerUp: widget.onCanvasPointerUp,
    onCanvasPointerDownIntercept: widget.onCanvasPointerDownIntercept,
    onRulerDismissed: widget.onRulerDismissed,
  );

  @override
  void initState() {
    super.initState();
    _interaction = HandwritingCanvasInteractionController(
      strokes: widget.strokes,
      canvasUseCases: widget.canvasUseCases,
      configuration: _configurationFor(widget),
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void didUpdateWidget(HandwritingCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _interaction.updateConfiguration(_configurationFor(widget));
    if (widget.strokes != oldWidget.strokes ||
        widget.strokes.length != _interaction.strokes.length) {
      _interaction.updateStrokes(widget.strokes);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _interaction.updateCanvasSize(
        Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
        ),
      );
      final config = _interaction.effectiveToolConfig;
      return Listener(
        key: const Key('handwriting_touch_listener'),
        behavior:
            widget.isDrawingMode ||
                widget.onCanvasTapDown != null ||
                widget.onCanvasPointerDownIntercept != null ||
                widget.onCanvasPointerMove != null ||
                widget.onCanvasPointerUp != null
            ? HitTestBehavior.opaque
            : HitTestBehavior.deferToChild,
        onPointerDown: _interaction.onPointerDown,
        onPointerMove: _interaction.onPointerMove,
        onPointerUp: _interaction.onPointerUp,
        onPointerCancel: _interaction.onPointerCancel,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            if (widget.child != null) widget.child!,
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  key: const Key('stroke_canvas_paint'),
                  painter: StrokePainter(
                    strokes: _interaction.strokes,
                    activeStroke: _interaction.activeStroke,
                    eraserPosition: _interaction.eraserPosition,
                    eraserRadius: config.eraserSize.radius,
                    ruler: _interaction.ruler,
                    rulerColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
