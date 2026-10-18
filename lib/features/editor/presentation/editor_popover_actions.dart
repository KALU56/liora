part of 'new_note_screen.dart';

extension _EditorPopoverActions on _NewNoteScreenState {
  Widget _buildActivePopover() {
    final popover = _activePopover;
    if (popover == null) return const SizedBox.shrink();
    final surface = switch (popover) {
      EditorPopover.content => EditorContentMenu(
        onAddPhoto: _addImage,
        onAddFile: _addFile,
        onAddLink: _addLink,
      ),
      EditorPopover.pen => _buildPenPopover(),
      EditorPopover.text => _buildTextPopover(),
      EditorPopover.stroke => _buildStrokePopover(),
    };
    return Material(
      key: ValueKey('active_editor_popover_${popover.name}'),
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 330),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: surface,
        ),
      ),
    );
  }

  Widget _buildPenPopover() {
    final config = _currentPage.toolConfig;
    final colors = <(int, String)>[
      (0xFF202124, 'color_picker_black'),
      (0xFF2196F3, 'color_picker_blue'),
      (0xFFF44336, 'color_picker_red'),
      (0xFF4CAF50, 'color_picker_green'),
      (0xFFFFEB3B, 'color_picker_yellow'),
    ];
    void update(ToolConfig next) =>
        _replaceCurrentPage(_currentPage.copyWith(toolConfig: next));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pen settings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              onPressed: () => _updateEditorState(() => _activePopover = null),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        if (config.toolType == WritingToolType.eraser)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                key: const Key('eraser_size_small'),
                label: const Text('Small'),
                selected: config.eraserSize == EraserSize.small,
                onSelected: (_) =>
                    update(config.copyWith(eraserSize: EraserSize.small)),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                key: const Key('eraser_size_large'),
                label: const Text('Large'),
                selected: config.eraserSize == EraserSize.large,
                onSelected: (_) =>
                    update(config.copyWith(eraserSize: EraserSize.large)),
              ),
            ],
          ),
        if (config.toolType != WritingToolType.eraser) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: colors
                .map(
                  (item) => InkWell(
                    key: Key(item.$2),
                    onTap: () => _selectPenColor(item.$1),
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Color(item.$1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: config.color.value == item.$1
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: config.color.value == item.$1 ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          Row(
            children: [
              const Text('Width'),
              Expanded(
                child: Slider(
                  key: const Key('thickness_slider'),
                  value: config.strokeWidth.clamp(1, 32),
                  min: 1,
                  max: 32,
                  onChanged: (value) =>
                      update(config.copyWith(strokeWidth: value)),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Opacity'),
              Expanded(
                child: Slider(
                  key: const Key('opacity_slider'),
                  value: config.opacity.clamp(.1, 1),
                  min: .1,
                  max: 1,
                  onChanged: (value) => update(config.copyWith(opacity: value)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
