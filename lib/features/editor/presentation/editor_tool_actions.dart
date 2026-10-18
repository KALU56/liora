part of 'new_note_screen.dart';

extension _EditorToolActions on _NewNoteScreenState {
  void _selectWritingTool(WritingToolType type) {
    final current = _currentPage.toolConfig;
    final updated = switch (type) {
      WritingToolType.pen =>
        current.toolType == type ? current : ToolConfig.defaultPen,
      WritingToolType.pencil =>
        current.toolType == type ? current : ToolConfig.defaultPencil,
      WritingToolType.highlighter =>
        current.toolType == type ? current : ToolConfig.defaultHighlighter,
      WritingToolType.eraser => current.copyWith(toolType: type),
      WritingToolType.shape => current.copyWith(toolType: type),
      WritingToolType.ruler => current.copyWith(toolType: type),
    };
    _replaceCurrentPage(_currentPage.copyWith(toolConfig: updated));
    _updateEditorState(() {
      _isPenMode = true;
      _activePopover = null;
    });
  }

  void _selectPenColor(int colorValue) {
    _replaceCurrentPage(
      _currentPage.copyWith(
        toolConfig: _currentPage.toolConfig.copyWith(
          color: ArgbColor(colorValue),
        ),
      ),
    );
    _updateEditorState(() => _activePopover = null);
  }

  void _dismissRuler() {
    _replaceCurrentPage(
      _currentPage.copyWith(
        toolConfig: _currentPage.toolConfig.copyWith(
          toolType: WritingToolType.pen,
        ),
      ),
    );
    _updateEditorState(() => _isPenMode = true);
  }
}
