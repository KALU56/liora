import '../domain/models/canvas_action.dart';
import '../domain/models/stroke.dart';
import '../domain/services/canvas_history_manager.dart';
import '../domain/services/eraser_service.dart';

/// Application operations for editing one canvas page.
class CanvasUseCases {
  CanvasUseCases({CanvasHistoryManager? history})
    : _history = history ?? CanvasHistoryManager();

  final CanvasHistoryManager _history;

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  void recordAction(CanvasAction action) => _history.recordAction(action);

  List<Stroke> undo(List<Stroke> strokes) => _history.undo(strokes);

  List<Stroke> redo(List<Stroke> strokes) => _history.redo(strokes);

  List<Stroke> clear(List<Stroke> strokes) {
    if (strokes.isEmpty) return strokes;
    recordAction(ClearCanvasAction(List<Stroke>.from(strokes)));
    return const [];
  }

  List<Stroke> eraseAtPoint(
    List<Stroke> strokes,
    dynamic eraserCenter,
    double eraserRadius,
  ) {
    return EraserService.eraseStrokesAtPoint(
      strokes,
      eraserCenter,
      eraserRadius,
    );
  }
}
