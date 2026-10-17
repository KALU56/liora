part of 'new_note_screen.dart';

extension _EditorSelectionControls on _NewNoteScreenState {
  void _updateSelectedTextBlock(NoteTextBlock Function(NoteTextBlock) update) {
    final index = _selectedTextIndex;
    if (index == null || index >= _currentPage.textBlocks.length) return;
    final blocks = List<NoteTextBlock>.from(_currentPage.textBlocks);
    blocks[index] = update(blocks[index]);
    _replaceCurrentPage(_currentPage.copyWith(textBlocks: blocks));
  }

  Widget _buildTextPopover() {
    final index = _selectedTextIndex;
    if (index == null || index >= _currentPage.textBlocks.length) {
      return const SizedBox.shrink();
    }
    final block = _currentPage.textBlocks[index];
    final textColors = <int>[
      0xFF202124,
      0xFF2196F3,
      0xFFF44336,
      0xFF4CAF50,
      0xFF8E44AD,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Text style',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: 'Close text controls',
              onPressed: () => _updateEditorState(() => _activePopover = null),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Size'),
            Expanded(
              child: Slider(
                key: const Key('text_size_slider'),
                value: block.fontSize.clamp(12, 48),
                min: 12,
                max: 48,
                onChanged: (value) => _updateSelectedTextBlock(
                  (item) => item.copyWith(fontSize: value),
                ),
              ),
            ),
            DropdownButton<String>(
              key: const Key('text_font_selector'),
              value:
                  const [
                    'Roboto',
                    'serif',
                    'monospace',
                  ].contains(block.fontFamily)
                  ? block.fontFamily
                  : 'Roboto',
              items: const ['Roboto', 'serif', 'monospace']
                  .map(
                    (font) => DropdownMenuItem(value: font, child: Text(font)),
                  )
                  .toList(),
              onChanged: (font) {
                if (font != null) {
                  _updateSelectedTextBlock(
                    (item) => item.copyWith(fontFamily: font),
                  );
                }
              },
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              key: const Key('text_bold_button'),
              tooltip: 'Bold',
              isSelected: block.bold,
              onPressed: () => _updateSelectedTextBlock(
                (item) => item.copyWith(bold: !item.bold),
              ),
              icon: const Icon(Icons.format_bold),
            ),
            IconButton(
              key: const Key('text_italic_button'),
              tooltip: 'Italic',
              isSelected: block.italic,
              onPressed: () => _updateSelectedTextBlock(
                (item) => item.copyWith(italic: !item.italic),
              ),
              icon: const Icon(Icons.format_italic),
            ),
            ...textColors.map(
              (value) => IconButton(
                key: Key('text_color_$value'),
                tooltip: 'Text color',
                onPressed: () => _updateSelectedTextBlock(
                  (item) => item.copyWith(colorValue: value),
                ),
                icon: Icon(Icons.circle, color: Color(value), size: 22),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateSelectedStroke(Stroke Function(Stroke) update) {
    final selectedId = _selectedStrokeId;
    if (selectedId == null) return;
    final strokes = List<Stroke>.from(_currentPage.strokes);
    final index = strokes.indexWhere((stroke) => stroke.id == selectedId);
    if (index < 0) return;
    final previousStroke = strokes[index];
    final updatedStroke = update(previousStroke);
    _canvas.recordAction(UpdateStrokeAction(previousStroke, updatedStroke));
    strokes[index] = updatedStroke;
    _replaceCurrentPage(_currentPage.copyWith(strokes: strokes));
  }

  Widget _buildStrokePopover() {
    final selectedId = _selectedStrokeId;
    final index = _currentPage.strokes.indexWhere(
      (stroke) => stroke.id == selectedId,
    );
    if (index < 0) return const SizedBox.shrink();
    final stroke = _currentPage.strokes[index];
    const colors = <int>[
      0xFF202124,
      0xFF2196F3,
      0xFFF44336,
      0xFF4CAF50,
      0xFFFFEB3B,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stroke.shapeType?.name ?? 'Stroke style',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: 'Close stroke controls',
              onPressed: () => _updateEditorState(() => _activePopover = null),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Wrap(
          spacing: 4,
          children: colors
              .map(
                (value) => IconButton(
                  key: Key('stroke_color_$value'),
                  tooltip: 'Stroke color',
                  onPressed: () => _updateSelectedStroke(
                    (item) => item.copyWith(color: ArgbColor(value)),
                  ),
                  icon: Icon(Icons.circle, color: Color(value)),
                ),
              )
              .toList(),
        ),
        Row(
          children: [
            const Text('Width'),
            Expanded(
              child: Slider(
                key: const Key('selected_stroke_width_slider'),
                value: stroke.strokeWidth.clamp(1, 32),
                min: 1,
                max: 32,
                onChanged: (value) => _updateSelectedStroke(
                  (item) => item.copyWith(strokeWidth: value),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Opacity'),
            Expanded(
              child: Slider(
                key: const Key('selected_stroke_opacity_slider'),
                value: stroke.opacity.clamp(.1, 1),
                min: .1,
                max: 1,
                onChanged: (value) => _updateSelectedStroke(
                  (item) => item.copyWith(opacity: value),
                ),
              ),
            ),
          ],
        ),
        if (stroke.shapeType != null &&
            stroke.shapeType != ShapeType.line &&
            stroke.shapeType != ShapeType.arrow)
          CheckboxListTile(
            key: const Key('selected_shape_fill_toggle'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Fill shape'),
            value: stroke.filled,
            onChanged: (filled) => _updateSelectedStroke(
              (item) => item.copyWith(filled: filled ?? false),
            ),
          ),
      ],
    );
  }
}
