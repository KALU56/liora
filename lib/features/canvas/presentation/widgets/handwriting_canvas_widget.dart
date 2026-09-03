import 'package:flutter/material.dart';

import '../../domain/models/stroke.dart';
import '../../domain/models/touch_point.dart';
import '../../domain/models/writing_tool.dart';
import '../../domain/services/eraser_service.dart';
import 'stroke_painter.dart';

/// Widget capturing touch/stylus gestures to draw, erase, and render handwriting strokes in real-time.
class HandwritingCanvasWidget extends StatefulWidget {
  final List<Stroke> strokes;
  final ValueChanged<List<Stroke>>? onStrokesChanged;
  final bool isDrawingMode;
  final ToolConfig toolConfig;
  final Color currentColor;
  final double currentStrokeWidth;
  final Widget? child;

  const HandwritingCanvasWidget({
    super.key,
    required this.strokes,
    this.onStrokesChanged,
    this.isDrawingMode = true,
    this.toolConfig = const ToolConfig(),
    this.currentColor = Colors.black,
    this.currentStrokeWidth = 3.0,
    this.child,
  });

  @override
  State<HandwritingCanvasWidget> createState() =>
      _HandwritingCanvasWidgetState();
}

class _HandwritingCanvasWidgetState extends State<HandwritingCanvasWidget> {
  Stroke? _activeStroke;
  Offset? _eraserPosition;
  int _strokeCounter = 0;
  late List<Stroke> _internalStrokes;

  @override
  void initState() {
    super.initState();
    _internalStrokes = List<Stroke>.from(widget.strokes);
  }

  @override
  void didUpdateWidget(HandwritingCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.strokes != oldWidget.strokes ||
        widget.strokes.length != _internalStrokes.length) {
      _internalStrokes = List<Stroke>.from(widget.strokes);
    }
  }

  ToolConfig get _effectiveConfig {
    if (widget.toolConfig.toolType == WritingToolType.pen &&
        (widget.currentColor != Colors.black || widget.currentStrokeWidth != 3.0)) {
      return widget.toolConfig.copyWith(
        color: widget.currentColor,
        strokeWidth: widget.currentStrokeWidth,
      );
    }
    return widget.toolConfig;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.isDrawingMode) return;

    final config = _effectiveConfig;

    if (config.toolType == WritingToolType.eraser) {
      _handleEraserTouch(event.localPosition);
      return;
    }

    _strokeCounter++;
    final newPoint = TouchPoint(
      offset: event.localPosition,
      pressure: event.pressure > 0 ? event.pressure : 1.0,
      timestamp: DateTime.now(),
    );

    setState(() {
      _activeStroke = Stroke(
        id: '${DateTime.now().microsecondsSinceEpoch}_$_strokeCounter',
        points: [newPoint],
        color: config.color,
        strokeWidth: config.strokeWidth,
        toolType: config.toolType,
        opacity: config.opacity,
      );
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!widget.isDrawingMode) return;

    final config = _effectiveConfig;

    if (config.toolType == WritingToolType.eraser) {
      _handleEraserTouch(event.localPosition);
      return;
    }

    if (_activeStroke == null) return;

    final newPoint = TouchPoint(
      offset: event.localPosition,
      pressure: event.pressure > 0 ? event.pressure : 1.0,
      timestamp: DateTime.now(),
    );

    setState(() {
      _activeStroke!.points.add(newPoint);
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!widget.isDrawingMode) return;

    final config = _effectiveConfig;

    if (config.toolType == WritingToolType.eraser) {
      setState(() {
        _eraserPosition = null;
      });
      return;
    }

    if (_activeStroke == null) return;

    final finalPoint = TouchPoint(
      offset: event.localPosition,
      pressure: event.pressure > 0 ? event.pressure : 1.0,
      timestamp: DateTime.now(),
    );

    final completedStroke = _activeStroke!.copyWith(
      points: [..._activeStroke!.points, finalPoint],
      isComplete: true,
    );

    _internalStrokes.add(completedStroke);

    setState(() {
      _activeStroke = null;
    });

    widget.onStrokesChanged?.call(List<Stroke>.from(_internalStrokes));
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!widget.isDrawingMode) return;

    final config = _effectiveConfig;

    if (config.toolType == WritingToolType.eraser) {
      setState(() {
        _eraserPosition = null;
      });
      return;
    }

    if (_activeStroke == null) return;

    if (_activeStroke!.points.isNotEmpty) {
      final completedStroke = _activeStroke!.copyWith(isComplete: true);
      _internalStrokes.add(completedStroke);
      widget.onStrokesChanged?.call(List<Stroke>.from(_internalStrokes));
    }

    setState(() {
      _activeStroke = null;
    });
  }

  void _handleEraserTouch(Offset localPosition) {
    final radius = _effectiveConfig.eraserSize.radius;
    final updatedStrokes = EraserService.eraseStrokesAtPoint(
      _internalStrokes,
      localPosition,
      radius,
    );

    final strokesWereRemoved = updatedStrokes.length != _internalStrokes.length;
    _internalStrokes = updatedStrokes;

    setState(() {
      _eraserPosition = localPosition;
    });

    if (strokesWereRemoved) {
      widget.onStrokesChanged?.call(List<Stroke>.from(_internalStrokes));
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = _effectiveConfig.eraserSize.radius;

    return Listener(
      key: const Key('handwriting_touch_listener'),
      behavior: widget.isDrawingMode
          ? HitTestBehavior.opaque
          : HitTestBehavior.deferToChild,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (widget.child != null) widget.child!,
          Positioned.fill(
            child: CustomPaint(
              key: const Key('stroke_canvas_paint'),
              painter: StrokePainter(
                strokes: _internalStrokes,
                activeStroke: _activeStroke,
                eraserPosition: _eraserPosition,
                eraserRadius: radius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
