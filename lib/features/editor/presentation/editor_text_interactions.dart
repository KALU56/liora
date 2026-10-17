part of 'new_note_screen.dart';

extension _EditorTextInteractions on _NewNoteScreenState {
  void _beginCanvasTextInput(Offset position) {
    if (!_isTextMode) return;
    final currentPosition = _inlineTextPosition;
    if (currentPosition != null &&
        position.dx >= currentPosition.dx &&
        position.dy >= currentPosition.dy &&
        position.dx <= currentPosition.dx + 220 &&
        position.dy <= currentPosition.dy + 120) {
      return;
    }
    final pageSize = _currentPage.paperTemplate.pageSize;
    int? hitIndex;
    for (var index = _currentPage.textBlocks.length - 1; index >= 0; index--) {
      final block = _currentPage.textBlocks[index];
      final availableWidth = pageSize.width - block.x;
      final estimatedWidth = (block.text.length * block.fontSize * .65)
          .clamp(1, 350)
          .toDouble();
      final width = estimatedWidth < availableWidth
          ? estimatedWidth
          : availableWidth;
      final height = block.fontSize * 2.2;
      if (Rect.fromLTWH(block.x, block.y, width, height).contains(position)) {
        hitIndex = index;
        break;
      }
    }
    _updateEditorState(() {
      final selectedBlock = hitIndex == null
          ? null
          : _currentPage.textBlocks[hitIndex];
      _inlineTextPosition = selectedBlock != null
          ? Offset(selectedBlock.x, selectedBlock.y)
          : Offset(
              position.dx.clamp(12, pageSize.width - 180).toDouble(),
              position.dy.clamp(12, pageSize.height - 120).toDouble(),
            );
      _editingTextIndex = hitIndex;
      _selectedTextIndex = hitIndex;
      _textController.text = selectedBlock?.text ?? '';
    });
  }

  int? _hitTestTextBlock(Offset position) {
    final pageSize = _currentPage.paperTemplate.pageSize;
    for (var index = _currentPage.textBlocks.length - 1; index >= 0; index--) {
      final block = _currentPage.textBlocks[index];
      final availableWidth = pageSize.width - block.x;
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
        return index;
      }
    }
    return null;
  }

  bool _interceptCanvasPointerDown(Offset position) {
    if (_currentPage.toolConfig.toolType == WritingToolType.eraser) {
      return false;
    }
    if (_isPenMode) {
      final textIndex = _hitTestTextBlock(position);
      if (textIndex != null) {
        _updateEditorState(() {
          _isTextMode = true;
          _isPenMode = false;
          _selectedTextIndex = textIndex;
          _selectedStrokeId = null;
          _activePopover = EditorPopover.text;
        });
        _beginCanvasTextInput(position);
        return true;
      }
    }
    final stroke = _hitTestStroke(position);
    if (stroke == null) return false;
    _updateEditorState(() {
      _selectedStrokeId = stroke.id;
      _selectedTextIndex = null;
      _activePopover = EditorPopover.stroke;
    });
    return true;
  }

  Stroke? _hitTestStroke(Offset position) {
    for (final stroke in _currentPage.strokes.reversed) {
      if (stroke.points.isEmpty) continue;
      final tolerance = math.max(14.0, stroke.strokeWidth + 8);
      if (stroke.shapeType != null && stroke.points.length > 1) {
        final first = stroke.points.first.position;
        final last = stroke.points.last.position;
        if (Rect.fromPoints(
          Offset(first.x, first.y),
          Offset(last.x, last.y),
        ).inflate(tolerance).contains(position)) {
          return stroke;
        }
        continue;
      }
      if (stroke.points.length == 1) {
        final point = stroke.points.single.position;
        if ((position - Offset(point.x, point.y)).distance <= tolerance) {
          return stroke;
        }
        continue;
      }
      for (var index = 1; index < stroke.points.length; index++) {
        final previous = stroke.points[index - 1].position;
        final current = stroke.points[index].position;
        final start = Offset(previous.x, previous.y);
        final end = Offset(current.x, current.y);
        final segment = end - start;
        final denominator = segment.distanceSquared;
        final ratio = denominator == 0
            ? 0.0
            : ((position - start).dx * segment.dx +
                      (position - start).dy * segment.dy) /
                  denominator;
        final projected = start + segment * ratio.clamp(0.0, 1.0);
        if ((position - projected).distance <= tolerance) return stroke;
      }
    }
    return null;
  }
}
