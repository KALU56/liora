import 'package:flutter/material.dart';

import '../../application/canvas_use_cases.dart';
import '../../domain/models/argb_color.dart';
import '../../domain/models/canvas_action.dart';
import '../../domain/models/point_2d.dart';
import '../../domain/models/stroke.dart';
import '../../domain/models/touch_point.dart';
import '../../domain/models/writing_tool.dart';
import 'ruler_geometry.dart';
import 'stroke_painter.dart';

enum _RulerGesture { none, move, rotate, draw }

/// Widget capturing touch/stylus gestures to draw, erase, and render handwriting strokes in real-time.
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
    this.currentStrokeWidth = 3.0,
    this.child,
    this.canvasUseCases,
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
  final List<Stroke> _currentDragErasedStrokes = [];
  late final CanvasUseCases _canvas;
  Size _canvasSize = Size.zero;
  Offset? _rulerCenter;
  double _rulerAngle = 0;
  _RulerGesture _rulerGesture = _RulerGesture.none;
  Offset? _lastRulerPointer;
  double _rotationStartPointerAngle = 0;
  double _rotationStartAngle = 0;
  bool _pointerIntercepted = false;

  @override
  void initState() {
    super.initState();
    _internalStrokes = List<Stroke>.from(widget.strokes);
    _canvas = widget.canvasUseCases ?? CanvasUseCases();
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
        (widget.currentColor != Colors.black ||
            widget.currentStrokeWidth != 3.0)) {
      return widget.toolConfig.copyWith(
        color: ArgbColor(widget.currentColor.toARGB32()),
        strokeWidth: widget.currentStrokeWidth,
      );
    }
    return widget.toolConfig;
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerIntercepted =
        widget.onCanvasPointerDownIntercept?.call(event.localPosition) ?? false;
    if (_pointerIntercepted) return;

    final config = _effectiveConfig;
    if (config.toolType == WritingToolType.ruler) {
      final ruler = _currentRuler;
      _rulerCenter ??= ruler.center;
      if (ruler.isOnRotationHandle(event.localPosition)) {
        _rulerGesture = _RulerGesture.rotate;
        _rotationStartPointerAngle =
            (event.localPosition - ruler.center).direction;
        _rotationStartAngle = ruler.angle;
        return;
      }
      if (ruler.isOnDrawingEdge(event.localPosition)) {
        final edgeStart = ruler.projectToDrawingEdge(event.localPosition);
        _rulerGesture = _RulerGesture.draw;
        _activeStroke = _newStroke(
          edgeStart,
          config.copyWith(toolType: WritingToolType.pen),
          event.pressure,
        );
        setState(() {});
        return;
      }
      if (ruler.containsBody(event.localPosition)) {
        _rulerGesture = _RulerGesture.move;
        _lastRulerPointer = event.localPosition;
        return;
      }
      widget.onRulerDismissed?.call();
      _startStroke(
        event.localPosition,
        config.copyWith(toolType: WritingToolType.pen),
        event.pressure,
      );
      return;
    }

    if (!widget.isDrawingMode) {
      widget.onCanvasTapDown?.call(event.localPosition);
      return;
    }

    if (config.toolType == WritingToolType.eraser) {
      _currentDragErasedStrokes.clear();
      _handleEraserTouch(event.localPosition);
      return;
    }

    _startStroke(event.localPosition, config, event.pressure);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_pointerIntercepted) return;
    switch (_rulerGesture) {
      case _RulerGesture.move:
        final last = _lastRulerPointer;
        if (last == null) return;
        setState(() {
          _rulerCenter = _currentRuler.center + event.localPosition - last;
          _lastRulerPointer = event.localPosition;
        });
        return;
      case _RulerGesture.rotate:
        final current = _currentRuler;
        setState(() {
          _rulerAngle =
              _rotationStartAngle +
              (event.localPosition - current.center).direction -
              _rotationStartPointerAngle;
        });
        return;
      case _RulerGesture.draw:
        final snapped = _currentRuler.projectToDrawingEdge(event.localPosition);
        _appendActivePoint(snapped, event.pressure);
        return;
      case _RulerGesture.none:
        break;
    }
    if (_pointerIntercepted) return;
    if (!widget.isDrawingMode) {
      widget.onCanvasPointerMove?.call(event.localPosition);
      return;
    }

    final config = _effectiveConfig;

    if (config.toolType == WritingToolType.eraser) {
      _handleEraserTouch(event.localPosition);
      return;
    }

    if (_activeStroke == null) return;

    final newPoint = TouchPoint(
      position: Point2D(event.localPosition.dx, event.localPosition.dy),
      pressure: event.pressure > 0 ? event.pressure : 1.0,
      timestamp: DateTime.now(),
    );

    setState(() {
      _activeStroke!.points.add(newPoint);
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_pointerIntercepted) {
      _pointerIntercepted = false;
      return;
    }
    if (_rulerGesture != _RulerGesture.none) {
      if (_rulerGesture == _RulerGesture.draw) {
        _completeActiveStroke(
          _currentRuler.projectToDrawingEdge(event.localPosition),
          event.pressure,
        );
      }
      setState(() {
        _rulerGesture = _RulerGesture.none;
        _lastRulerPointer = null;
      });
      return;
    }
    if (!widget.isDrawingMode) {
      widget.onCanvasPointerUp?.call(event.localPosition);
      return;
    }

    final config = _effectiveConfig;

    if (config.toolType == WritingToolType.eraser) {
      if (_currentDragErasedStrokes.isNotEmpty) {
        widget.onActionRecorded?.call(
          EraseStrokesAction(List<Stroke>.from(_currentDragErasedStrokes)),
        );
        _currentDragErasedStrokes.clear();
      }
      setState(() {
        _eraserPosition = null;
      });
      return;
    }

    if (_activeStroke == null) return;

    _completeActiveStroke(event.localPosition, event.pressure);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_pointerIntercepted) {
      _pointerIntercepted = false;
      return;
    }
    if (_rulerGesture != _RulerGesture.none) {
      setState(() {
        _activeStroke = null;
        _rulerGesture = _RulerGesture.none;
        _lastRulerPointer = null;
      });
      return;
    }
    if (!widget.isDrawingMode) return;

    final config = _effectiveConfig;

    if (config.toolType == WritingToolType.eraser) {
      if (_currentDragErasedStrokes.isNotEmpty) {
        widget.onActionRecorded?.call(
          EraseStrokesAction(List<Stroke>.from(_currentDragErasedStrokes)),
        );
        _currentDragErasedStrokes.clear();
      }
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
      widget.onActionRecorded?.call(AddStrokeAction(completedStroke));
    }

    setState(() {
      _activeStroke = null;
    });
  }

  RulerGeometry get _currentRuler => RulerGeometry(
    center:
        _rulerCenter ?? Offset(_canvasSize.width / 2, _canvasSize.height / 2),
    angle: _rulerAngle,
  );

  TouchPoint _touchPoint(Offset position, double pressure) => TouchPoint(
    position: Point2D(position.dx, position.dy),
    pressure: pressure > 0 ? pressure : 1,
    timestamp: DateTime.now(),
  );

  Stroke _newStroke(Offset position, ToolConfig config, double pressure) {
    _strokeCounter++;
    return Stroke(
      id: '${DateTime.now().microsecondsSinceEpoch}_$_strokeCounter',
      points: [_touchPoint(position, pressure)],
      color: config.color,
      strokeWidth: config.strokeWidth,
      toolType: config.toolType,
      opacity: config.opacity,
      shapeType: config.toolType == WritingToolType.shape
          ? config.shapeType
          : null,
      filled: config.filled,
    );
  }

  void _startStroke(Offset position, ToolConfig config, double pressure) {
    setState(() => _activeStroke = _newStroke(position, config, pressure));
  }

  void _appendActivePoint(Offset position, double pressure) {
    final activeStroke = _activeStroke;
    if (activeStroke == null) return;
    setState(() => activeStroke.points.add(_touchPoint(position, pressure)));
  }

  void _completeActiveStroke(Offset position, double pressure) {
    final activeStroke = _activeStroke;
    if (activeStroke == null) return;
    final completedStroke = activeStroke.copyWith(
      points: [...activeStroke.points, _touchPoint(position, pressure)],
      isComplete: true,
    );
    _internalStrokes.add(completedStroke);
    setState(() => _activeStroke = null);
    widget.onStrokesChanged?.call(List<Stroke>.from(_internalStrokes));
    widget.onActionRecorded?.call(AddStrokeAction(completedStroke));
  }

  void _handleEraserTouch(Offset localPosition) {
    final radius = _effectiveConfig.eraserSize.radius;
    final updatedStrokes = _canvas.eraseAtPoint(
      _internalStrokes,
      Point2D(localPosition.dx, localPosition.dy),
      radius,
    );

    final removedStrokes = _internalStrokes
        .where((s) => !updatedStrokes.any((u) => u.id == s.id))
        .toList();

    if (removedStrokes.isNotEmpty) {
      _currentDragErasedStrokes.addAll(removedStrokes);
    }

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
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
        );
        final ruler = _effectiveConfig.toolType == WritingToolType.ruler
            ? _currentRuler
            : null;
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
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              if (widget.child != null) widget.child!,
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    key: const Key('stroke_canvas_paint'),
                    painter: StrokePainter(
                      strokes: _internalStrokes,
                      activeStroke: _activeStroke,
                      eraserPosition: _eraserPosition,
                      eraserRadius: radius,
                      ruler: ruler,
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
}
