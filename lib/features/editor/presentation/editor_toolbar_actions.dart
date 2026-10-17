part of 'new_note_screen.dart';

extension _EditorToolbarActions on _NewNoteScreenState {
  Widget _toolButton({
    required Key key,
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
    bool active = false,
    String? label,
  }) => Tooltip(
    message: tooltip,
    child: InkWell(
      key: key,
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary.withValues(alpha: .12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: label == null
              ? Icon(
                  icon,
                  size: 22,
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    ),
  );

  Widget _buildFloatingToolbar() {
    final activeTool = _activePopover;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: AppSpacing.floatingControlElevation,
      shadowColor: Theme.of(context).colorScheme.shadow
          .withValues(alpha: AppSpacing.floatingControlShadowAlpha),
      borderRadius: BorderRadius.circular(
        AppSpacing.floatingControlCornerRadius,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.floatingControlPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppSpacing.floatingControlCornerRadius,
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _toolButton(
                key: const Key('text_tool_button'),
                tooltip: _isTextMode ? 'Finish typing' : 'Type on canvas',
                icon: Icons.text_fields,
                label: 'Tt',
                active: _isTextMode,
                onPressed: _activateTextMode,
              ),
              _toolButton(
                key: const Key('voice_input_button'),
                tooltip: _isListening ? 'Stop voice input' : 'Voice input',
                icon: _isListening ? Icons.mic : Icons.mic_none,
                active: _voiceSessionRequested,
                onPressed: _toggleVoiceInput,
              ),
              _toolButton(
                key: const Key('add_content_button'),
                tooltip: 'Add content',
                icon: Icons.add,
                active: activeTool == EditorPopover.content,
                onPressed: _showAddContentMenu,
              ),
              _toolButton(
                key: const Key('handwriting_tool_button'),
                tooltip: 'Handwriting / drawing',
                icon: Icons.gesture,
                active: _isPenMode,
                onPressed: () {
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
              ),
              _toolButton(
                key: const Key('pan_tool_button'),
                tooltip: _isPanMode ? 'Finish panning' : 'Pan page',
                icon: Icons.pan_tool_alt,
                active: _isPanMode,
                onPressed: () {
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
              ),
              _toolButton(
                key: const Key('pen_tool_button'),
                tooltip: 'Pen settings',
                icon: Icons.edit_outlined,
                active: activeTool == EditorPopover.pen,
                onPressed: () {
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
              ),
              _toolButton(
                key: const Key('expand_tools_button'),
                tooltip: 'More tools',
                icon: Icons.arrow_forward,
                active: activeTool == EditorPopover.expanded,
                onPressed: () => _openPopover(EditorPopover.expanded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
