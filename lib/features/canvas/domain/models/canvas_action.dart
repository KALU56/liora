import 'stroke.dart';

/// Abstract representation of a canvas modification command for Undo/Redo operations.
abstract class CanvasAction {
  List<Stroke> executeUndo(List<Stroke> currentStrokes);
  List<Stroke> executeRedo(List<Stroke> currentStrokes);
}

/// Command representing the addition of a new handwriting stroke.
class AddStrokeAction extends CanvasAction {
  final Stroke stroke;

  AddStrokeAction(this.stroke);

  @override
  List<Stroke> executeUndo(List<Stroke> currentStrokes) {
    return currentStrokes.where((s) => s.id != stroke.id).toList();
  }

  @override
  List<Stroke> executeRedo(List<Stroke> currentStrokes) {
    return [...currentStrokes, stroke];
  }
}

/// Command representing the deletion/erasing of strokes.
class EraseStrokesAction extends CanvasAction {
  final List<Stroke> erasedStrokes;

  EraseStrokesAction(this.erasedStrokes);

  @override
  List<Stroke> executeUndo(List<Stroke> currentStrokes) {
    return [...currentStrokes, ...erasedStrokes];
  }

  @override
  List<Stroke> executeRedo(List<Stroke> currentStrokes) {
    final erasedIds = erasedStrokes.map((s) => s.id).toSet();
    return currentStrokes.where((s) => !erasedIds.contains(s.id)).toList();
  }
}

/// Command representing clearing the entire canvas.
class ClearCanvasAction extends CanvasAction {
  final List<Stroke> clearedStrokes;

  ClearCanvasAction(this.clearedStrokes);

  @override
  List<Stroke> executeUndo(List<Stroke> currentStrokes) {
    return [...currentStrokes, ...clearedStrokes];
  }

  @override
  List<Stroke> executeRedo(List<Stroke> currentStrokes) {
    final clearedIds = clearedStrokes.map((s) => s.id).toSet();
    return currentStrokes.where((s) => !clearedIds.contains(s.id)).toList();
  }
}

/// Command representing a change to the appearance of one existing stroke.
class UpdateStrokeAction extends CanvasAction {
  final Stroke previousStroke;
  final Stroke updatedStroke;

  UpdateStrokeAction(this.previousStroke, this.updatedStroke);

  @override
  List<Stroke> executeUndo(List<Stroke> currentStrokes) =>
      _replaceStroke(currentStrokes, previousStroke);

  @override
  List<Stroke> executeRedo(List<Stroke> currentStrokes) =>
      _replaceStroke(currentStrokes, updatedStroke);

  List<Stroke> _replaceStroke(List<Stroke> currentStrokes, Stroke replacement) {
    final index = currentStrokes.indexWhere(
      (stroke) => stroke.id == replacement.id,
    );
    if (index < 0) return currentStrokes;
    final strokes = List<Stroke>.from(currentStrokes);
    strokes[index] = replacement;
    return strokes;
  }
}
