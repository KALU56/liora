import 'package:flutter/material.dart';

import '../../domain/models/writing_tool.dart';
import 'ruler_geometry.dart';

typedef RulerStrokeStart = void Function(
  Offset position,
  ToolConfig config,
  double pressure,
);
typedef RulerStrokePoint = void Function(Offset position, double pressure);

/// Tracks ruler move, rotate, and edge-drawing gestures for the canvas.
class RulerGestureController {
  final VoidCallback onChanged;
  final RulerStrokeStart onStrokeStart;
  final RulerStrokePoint onStrokeAppend;
  final RulerStrokePoint onStrokeComplete;
  final VoidCallback onStrokeCancel;
  final VoidCallback? onRulerDismissed;

  Offset? _center;
  double _angle = 0;
  _RulerGesture _gesture = _RulerGesture.none;
  Offset? _lastPointer;
  double _rotationStartPointerAngle = 0;
  double _rotationStartAngle = 0;

  RulerGestureController({
    required this.onChanged,
    required this.onStrokeStart,
    required this.onStrokeAppend,
    required this.onStrokeComplete,
    required this.onStrokeCancel,
    this.onRulerDismissed,
  });

  bool get hasActiveGesture => _gesture != _RulerGesture.none;

  RulerGeometry geometryFor(Size canvasSize) => RulerGeometry(
    center: _center ?? Offset(canvasSize.width / 2, canvasSize.height / 2),
    angle: _angle,
  );

  bool handlePointerDown(
    PointerDownEvent event,
    ToolConfig config,
    Size canvasSize,
  ) {
    final ruler = geometryFor(canvasSize);
    _center ??= ruler.center;
    if (ruler.isOnRotationHandle(event.localPosition)) {
      _gesture = _RulerGesture.rotate;
      _rotationStartPointerAngle =
          (event.localPosition - ruler.center).direction;
      _rotationStartAngle = ruler.angle;
      return true;
    }
    if (ruler.isOnDrawingEdge(event.localPosition)) {
      final edgeStart = ruler.projectToDrawingEdge(event.localPosition);
      _gesture = _RulerGesture.draw;
      onStrokeStart(
        edgeStart,
        config.copyWith(toolType: WritingToolType.pen),
        event.pressure,
      );
      return true;
    }
    if (ruler.containsBody(event.localPosition)) {
      _gesture = _RulerGesture.move;
      _lastPointer = event.localPosition;
      return true;
    }
    onRulerDismissed?.call();
    return false;
  }

  bool handlePointerMove(PointerMoveEvent event, Size canvasSize) {
    switch (_gesture) {
      case _RulerGesture.move:
        final lastPointer = _lastPointer;
        if (lastPointer == null) return true;
        _center =
            geometryFor(canvasSize).center + event.localPosition - lastPointer;
        _lastPointer = event.localPosition;
        onChanged();
        return true;
      case _RulerGesture.rotate:
        final ruler = geometryFor(canvasSize);
        _angle =
            _rotationStartAngle +
            (event.localPosition - ruler.center).direction -
            _rotationStartPointerAngle;
        onChanged();
        return true;
      case _RulerGesture.draw:
        onStrokeAppend(
          geometryFor(canvasSize).projectToDrawingEdge(event.localPosition),
          event.pressure,
        );
        return true;
      case _RulerGesture.none:
        return false;
    }
  }

  bool handlePointerUp(PointerUpEvent event, Size canvasSize) {
    if (!hasActiveGesture) return false;
    if (_gesture == _RulerGesture.draw) {
      onStrokeComplete(
        geometryFor(canvasSize).projectToDrawingEdge(event.localPosition),
        event.pressure,
      );
    }
    _resetGesture();
    onChanged();
    return true;
  }

  bool handlePointerCancel() {
    if (!hasActiveGesture) return false;
    onStrokeCancel();
    _resetGesture();
    onChanged();
    return true;
  }

  void _resetGesture() {
    _gesture = _RulerGesture.none;
    _lastPointer = null;
  }
}

enum _RulerGesture { none, move, rotate, draw }
