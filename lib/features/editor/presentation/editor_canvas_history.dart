part of 'new_note_screen.dart';

extension _EditorCanvasHistory on _NewNoteScreenState {
  void _undoStroke() {
    if (_canvas.canUndo) {
      _replaceCurrentPage(
        _currentPage.copyWith(strokes: _canvas.undo(_currentPage.strokes)),
      );
    }
  }

  void _redoStroke() {
    if (_canvas.canRedo) {
      _replaceCurrentPage(
        _currentPage.copyWith(strokes: _canvas.redo(_currentPage.strokes)),
      );
    }
  }

  void _clearCanvas() {
    if (_currentPage.strokes.isNotEmpty) {
      _replaceCurrentPage(
        _currentPage.copyWith(strokes: _canvas.clear(_currentPage.strokes)),
      );
    }
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _pages.length) return;
    _updateEditorState(() {
      _currentPageIndex = index;
      _selectedTextIndex = null;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _addPage() {
    final newPage = _newPage(template: _currentPage.paperTemplate);
    _updateEditorState(() {
      _pages = [..._pages, newPage];
      _currentPageIndex = _pages.length - 1;
      _transformationController.value = Matrix4.identity();
    });
    _autosaveNote();
  }
}
