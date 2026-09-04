import '../models/canvas_action.dart';
import '../models/stroke.dart';

/// State manager for managing multi-step Undo and Redo operations with action stack branching.
class CanvasHistoryManager {
  final List<CanvasAction> _undoStack = [];
  final List<CanvasAction> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  List<CanvasAction> get undoStack => List.unmodifiable(_undoStack);
  List<CanvasAction> get redoStack => List.unmodifiable(_redoStack);

  /// Records a new action into the undo stack and invalidates the redo stack (action stack branching).
  void recordAction(CanvasAction action) {
    _undoStack.add(action);
    _redoStack.clear();
  }

  /// Undoes the most recent canvas action and pushes it onto the redo stack.
  List<Stroke> undo(List<Stroke> currentStrokes) {
    if (!canUndo) return currentStrokes;
    final action = _undoStack.removeLast();
    _redoStack.add(action);
    return action.executeUndo(currentStrokes);
  }

  /// Redoes the most recently undone action and pushes it back onto the undo stack.
  List<Stroke> redo(List<Stroke> currentStrokes) {
    if (!canRedo) return currentStrokes;
    final action = _redoStack.removeLast();
    _undoStack.add(action);
    return action.executeRedo(currentStrokes);
  }

  /// Clears both undo and redo stacks.
  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
