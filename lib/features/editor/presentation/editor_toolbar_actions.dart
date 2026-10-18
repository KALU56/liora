part of 'new_note_screen.dart';

extension _EditorToolbarActions on _NewNoteScreenState {
  Widget _buildFloatingToolbar() => EditorFloatingToolbar(
    toolConfig: _currentPage.toolConfig,
    isTextMode: _isTextMode,
    isListening: _isListening,
    isRecording: _isRecording,
    isPanMode: _isPanMode,
    isPenMode: _isPenMode,
    isPenSettingsOpen: _activePopover == EditorPopover.pen,
    isAddContentOpen: _activePopover == EditorPopover.content,
    onActivateTextMode: _activateTextMode,
    onToggleVoiceInput: _toggleVoiceInput,
    onShowAddContent: _showAddContentMenu,
    onToggleHandwriting: () {
      FocusManager.instance.primaryFocus?.unfocus();
      _updateEditorState(() {
        _isPenMode = !_isPenMode;
        _isPanMode = false;
        _isTextMode = false;
        _inlineTextPosition = null;
        _editingTextIndex = null;
        _activePopover = null;
      });
    },
    onTogglePan: () {
      FocusManager.instance.primaryFocus?.unfocus();
      _updateEditorState(() {
        _isPanMode = !_isPanMode;
        _isPenMode = false;
        _isTextMode = false;
        _inlineTextPosition = null;
        _editingTextIndex = null;
        _activePopover = null;
      });
    },
    onTogglePenSettings: () {
      FocusManager.instance.primaryFocus?.unfocus();
      _updateEditorState(() {
        _isTextMode = false;
        _isPenMode = true;
        _isPanMode = false;
        _inlineTextPosition = null;
        _editingTextIndex = null;
        _activePopover = _activePopover == EditorPopover.pen
            ? null
            : EditorPopover.pen;
      });
    },
    onSelectTool: _selectWritingTool,
    onSelectShapeType: (shape) => _replaceCurrentPage(
      _currentPage.copyWith(
        toolConfig: _currentPage.toolConfig.copyWith(shapeType: shape),
      ),
    ),
    onToggleShapeFill: () => _replaceCurrentPage(
      _currentPage.copyWith(
        toolConfig: _currentPage.toolConfig.copyWith(
          filled: !_currentPage.toolConfig.filled,
        ),
      ),
    ),
    onToggleRecording: _toggleRecording,
    onClearHandwriting: _clearCanvas,
    onEnterToolsMode: () {
      FocusManager.instance.primaryFocus?.unfocus();
      _updateEditorState(() {
        _isTextMode = false;
        _isPenMode = false;
        _isPanMode = false;
        _inlineTextPosition = null;
        _editingTextIndex = null;
        _activePopover = null;
      });
    },
  );
}
