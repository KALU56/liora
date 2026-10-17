part of 'new_note_screen.dart';

extension _EditorCanvasInteractions on _NewNoteScreenState {
  void _moveTextBlock(int index, Offset delta) {
    if (index < 0 || index >= _currentPage.textBlocks.length) return;
    final blocks = List<NoteTextBlock>.from(_currentPage.textBlocks);
    final block = blocks[index];
    final pageSize = _currentPage.paperTemplate.pageSize;
    blocks[index] = block.copyWith(
      x: (block.x + delta.dx).clamp(0, pageSize.width - 32).toDouble(),
      y: (block.y + delta.dy).clamp(0, pageSize.height - 32).toDouble(),
    );
    _replaceCurrentPage(_currentPage.copyWith(textBlocks: blocks));
  }

  void _handleCanvasPointerDown(Offset position) {
    if (_isTextMode) {
      _beginCanvasTextInput(position);
      return;
    }
    _draggingTextIndex = null;
    for (var index = _currentPage.textBlocks.length - 1; index >= 0; index--) {
      final block = _currentPage.textBlocks[index];
      final availableWidth =
          _currentPage.paperTemplate.pageSize.width - block.x;
      final estimatedWidth = (block.text.length * block.fontSize * .65)
          .clamp(1, 350)
          .toDouble();
      final width = estimatedWidth < availableWidth
          ? estimatedWidth
          : availableWidth;
      if (Rect.fromLTWH(
        block.x,
        block.y,
        width,
        block.fontSize * 2.2,
      ).contains(position)) {
        _draggingTextIndex = index;
        break;
      }
    }
    _lastTextPointerPosition = position;
    _textDragDelta = Offset.zero;
  }

  void _handleCanvasPointerMove(Offset position) {
    if (_draggingTextIndex == null || _lastTextPointerPosition == null) return;
    _textDragDelta += position - _lastTextPointerPosition!;
    _lastTextPointerPosition = position;
  }

  void _handleCanvasPointerUp() {
    final index = _draggingTextIndex;
    if (index != null && _textDragDelta.distance > 2) {
      _moveTextBlock(index, _textDragDelta);
    } else if (index != null) {
      final block = _currentPage.textBlocks[index];
      _updateEditorState(() {
        _isTextMode = true;
        _isPenMode = false;
        _selectedTextIndex = index;
        _activePopover = EditorPopover.text;
      });
      _beginCanvasTextInput(Offset(block.x, block.y));
    }
    _draggingTextIndex = null;
    _lastTextPointerPosition = null;
    _textDragDelta = Offset.zero;
  }

  void _updateCanvasText(String value) {
    if (value.isEmpty && _editingTextIndex == null) return;
    final blocks = List<NoteTextBlock>.from(_currentPage.textBlocks);
    final index = _editingTextIndex;
    if (index != null && index < blocks.length) {
      blocks[index] = blocks[index].copyWith(text: value);
    } else {
      final position = _inlineTextPosition ?? const Offset(24, 24);
      blocks.add(NoteTextBlock(text: value, x: position.dx, y: position.dy));
      _editingTextIndex = blocks.length - 1;
      _selectedTextIndex = _editingTextIndex;
    }
    _replaceCurrentPage(_currentPage.copyWith(textBlocks: blocks));
  }
}
