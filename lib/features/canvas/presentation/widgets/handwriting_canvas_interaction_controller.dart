import 'package:flutter/material.dart';

import '../../application/canvas_use_cases.dart';
import '../../domain/models/canvas_action.dart';
import '../../domain/models/point_2d.dart';
import '../../domain/models/stroke.dart';
import '../../domain/models/touch_point.dart';
import '../../domain/models/writing_tool.dart';
import 'handwriting_canvas_configuration.dart';
import 'ruler_geometry.dart';
import 'ruler_gesture_controller.dart';

/// Owns transient pointer, stroke, eraser, and ruler interaction state.
class HandwritingCanvasInteractionController {
  final CanvasUseCases _canvas;
  final VoidCallback onChanged;
  final List<Stroke> _currentDragErasedStrokes = [];
  late final RulerGestureController _rulerGestures;
  late List<Stroke> _strokes;
  HandwritingCanvasConfiguration configuration;
  Size _canvasSize = Size.zero;
  Stroke? _activeStroke;
  Offset? _eraserPosition;
  int _strokeCounter = 0;
  bool _pointerIntercepted = false;

  HandwritingCanvasInteractionController({
    required List<Stroke> strokes,
    required CanvasUseCases? canvasUseCases,
    required this.configuration,
    required this.onChanged,
  }) : _strokes = List<Stroke>.from(strokes),
       _canvas = canvasUseCases ?? CanvasUseCases() {
    _rulerGestures = RulerGestureController(
      onChanged: onChanged,
      onStrokeStart: _startStroke,
      onStrokeAppend: _appendActivePoint,
      onStrokeComplete: _completeActiveStroke,
      onStrokeCancel: _cancelActiveStroke,
      onRulerDismissed: () => configuration.onRulerDismissed?.call(),
    );
  }

  List<Stroke> get strokes => _strokes;
  Stroke? get activeStroke => _activeStroke;
  Offset? get eraserPosition => _eraserPosition;
  double get eraserRadius =>
      configuration.effectiveToolConfig.eraserSize.radius;
  ToolConfig get effectiveToolConfig => configuration.effectiveToolConfig;
  RulerGeometry? get ruler =>
      effectiveToolConfig.toolType == WritingToolType.ruler
      ? _rulerGestures.geometryFor(_canvasSize)
      : null;

  void updateConfiguration(HandwritingCanvasConfiguration newConfiguration) {
    configuration = newConfiguration;
  }

  void updateStrokes(List<Stroke> strokes) {
    _strokes = List<Stroke>.from(strokes);
  }

  void updateCanvasSize(Size size) {
    _canvasSize = size;
  }

  void onPointerDown(PointerDownEvent event) {
    _pointerIntercepted =
        configuration.onCanvasPointerDownIntercept?.call(event.localPosition) ??
        false;
    if (_pointerIntercepted) return;

    final config = effectiveToolConfig;
    if (config.toolType == WritingToolType.ruler) {
      if (!_rulerGestures.handlePointerDown(event, config, _canvasSize)) {
        _startStroke(
          event.localPosition,
          config.copyWith(toolType: WritingToolType.pen),
          event.pressure,
        );
      }
      return;
    }
    if (!configuration.isDrawingMode) {
      configuration.onCanvasTapDown?.call(event.localPosition);
      return;
    }
    if (config.toolType == WritingToolType.eraser) {
      _currentDragErasedStrokes.clear();
      _handleEraserTouch(event.localPosition);
      return;
    }
    _startStroke(event.localPosition, config, event.pressure);
  }

  void onPointerMove(PointerMoveEvent event) {
    if (_pointerIntercepted) return;
    if (_rulerGestures.handlePointerMove(event, _canvasSize)) return;
    if (!configuration.isDrawingMode) {
      configuration.onCanvasPointerMove?.call(event.localPosition);
      return;
    }
    final config = effectiveToolConfig;
    if (config.toolType == WritingToolType.eraser) {
      _handleEraserTouch(event.localPosition);
      return;
    }
    if (_activeStroke == null) return;
    _appendActivePoint(event.localPosition, event.pressure);
  }

  void onPointerUp(PointerUpEvent event) {
    if (_pointerIntercepted) {
      _pointerIntercepted = false;
      return;
    }
    if (_rulerGestures.handlePointerUp(event, _canvasSize)) return;
    if (!configuration.isDrawingMode) {
      configuration.onCanvasPointerUp?.call(event.localPosition);
      return;
    }
    if (effectiveToolConfig.toolType == WritingToolType.eraser) {
      _recordErasedStrokes();
      _eraserPosition = null;
      onChanged();
      return;
    }
    _completeActiveStroke(event.localPosition, event.pressure);
  }

  void onPointerCancel(PointerCancelEvent event) {
    if (_pointerIntercepted) {
      _pointerIntercepted = false;
      return;
    }
    if (_rulerGestures.handlePointerCancel()) return;
    if (!configuration.isDrawingMode) return;
    if (effectiveToolConfig.toolType == WritingToolType.eraser) {
      _recordErasedStrokes();
      _eraserPosition = null;
      onChanged();
      return;
    }
    final activeStroke = _activeStroke;
    if (activeStroke == null) return;
    if (activeStroke.points.isNotEmpty) {
      final completedStroke = activeStroke.copyWith(isComplete: true);
      _strokes.add(completedStroke);
      configuration.onStrokesChanged?.call(List<Stroke>.from(_strokes));
      configuration.onActionRecorded?.call(AddStrokeAction(completedStroke));
    }
    _activeStroke = null;
    onChanged();
  }

  void _startStroke(Offset position, ToolConfig config, double pressure) {
    _strokeCounter++;
    final point = _touchPoint(position, pressure);
    _activeStroke = Stroke(
      id: '${DateTime.now().microsecondsSinceEpoch}_$_strokeCounter',
      points: [point],
      color: config.color,
      strokeWidth: config.strokeWidth,
      toolType: config.toolType,
      opacity: config.opacity,
      shapeType: config.toolType == WritingToolType.shape
          ? config.shapeType
          : null,
      filled: config.filled,
    );
    onChanged();
  }

  void _appendActivePoint(Offset position, double pressure) {
    _activeStroke?.points.add(_touchPoint(position, pressure));
    onChanged();
  }

  void _completeActiveStroke(Offset position, double pressure) {
    final activeStroke = _activeStroke;
    if (activeStroke == null) return;
    final completedStroke = activeStroke.copyWith(
      points: [...activeStroke.points, _touchPoint(position, pressure)],
      isComplete: true,
    );
    _strokes.add(completedStroke);
    _activeStroke = null;
    onChanged();
    configuration.onStrokesChanged?.call(List<Stroke>.from(_strokes));
    configuration.onActionRecorded?.call(AddStrokeAction(completedStroke));
  }

  void _cancelActiveStroke() {
    _activeStroke = null;
    onChanged();
  }

  TouchPoint _touchPoint(Offset position, double pressure) => TouchPoint(
    position: Point2D(position.dx, position.dy),
    pressure: pressure > 0 ? pressure : 1,
    timestamp: DateTime.now(),
  );

  void _handleEraserTouch(Offset position) {
    final updatedStrokes = _canvas.eraseAtPoint(
      _strokes,
      Point2D(position.dx, position.dy),
      effectiveToolConfig.eraserSize.radius,
    );
    final removedStrokes = _strokes
        .where((stroke) => !updatedStrokes.any((item) => item.id == stroke.id))
        .toList();
    if (removedStrokes.isNotEmpty) {
      _currentDragErasedStrokes.addAll(removedStrokes);
    }
    final strokesWereRemoved = updatedStrokes.length != _strokes.length;
    _strokes = updatedStrokes;
    _eraserPosition = position;
    onChanged();
    if (strokesWereRemoved) {
      configuration.onStrokesChanged?.call(List<Stroke>.from(_strokes));
    }
  }

  void _recordErasedStrokes() {
    if (_currentDragErasedStrokes.isEmpty) return;
    configuration.onActionRecorded?.call(
      EraseStrokesAction(List<Stroke>.from(_currentDragErasedStrokes)),
    );
    _currentDragErasedStrokes.clear();
  }
}
