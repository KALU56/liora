part of 'new_note_screen.dart';

extension _EditorWorkspace on _NewNoteScreenState {
  Widget _buildEditorWorkspace() {
    final page = _currentPage;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                key: const Key('note_interactive_viewer'),
                transformationController: _transformationController,
                panEnabled: _isPanMode,
                scaleEnabled: true,
                constrained: true,
                minScale: .2,
                maxScale: 5,
                child: PaperCanvasWidget(
                  key: const Key('paper_canvas'),
                  canvasSize: Size(constraints.maxWidth, constraints.maxHeight),
                  template: page.paperTemplate,
                  showShadow: false,
                  child: HandwritingCanvasWidget(
                    key: const Key('handwriting_canvas'),
                    strokes: page.strokes,
                    isDrawingMode: _isPenMode && !_isPanMode,
                    toolConfig: page.toolConfig,
                    canvasUseCases: _canvas,
                    onStrokesChanged: (newStrokes) => _replaceCurrentPage(
                      _currentPage.copyWith(strokes: newStrokes),
                    ),
                    onCanvasTapDown: !_isPenMode && !_isPanMode
                        ? _handleCanvasPointerDown
                        : null,
                    onCanvasPointerDownIntercept: _isPanMode
                        ? null
                        : _interceptCanvasPointerDown,
                    onRulerDismissed: _dismissRuler,
                    onCanvasPointerMove: !_isPenMode && !_isPanMode
                        ? _handleCanvasPointerMove
                        : null,
                    onCanvasPointerUp: !_isPenMode && !_isPanMode
                        ? (_) => _handleCanvasPointerUp()
                        : null,
                    onActionRecorded: _canvas.recordAction,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: page.attachments
                                .map(
                                  (path) => Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: _attachmentPreview(path),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        ...page.textBlocks
                            .asMap()
                            .entries
                            .where((entry) => entry.key != _editingTextIndex)
                            .map((entry) {
                              final block = entry.value;
                              return Positioned(
                                left: block.x,
                                top: block.y,
                                child: Text(
                                  block.text,
                                  textAlign: block.alignment,
                                  style: TextStyle(
                                    fontFamily: block.fontFamily,
                                    fontSize: block.fontSize,
                                    fontWeight: block.bold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontStyle: block.italic
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    color: Color(block.colorValue),
                                  ),
                                ),
                              );
                            }),
                        if (_isTextMode &&
                            _inlineTextPosition != null &&
                            !_isListening)
                          Positioned(
                            left: _inlineTextPosition!.dx,
                            top: _inlineTextPosition!.dy,
                            right: 12,
                            child: TextField(
                              key: const Key('canvas_inline_text_field'),
                              controller: _textController,
                              autofocus: true,
                              minLines: 1,
                              maxLines: null,
                              textAlignVertical: TextAlignVertical.top,
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: const InputDecoration.collapsed(
                                hintText: 'Write on your page…',
                              ),
                              onChanged: _updateCanvasText,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: 0,
              bottom: AppSpacing.xxl * 2,
              width: AppSpacing.pageControlRailWidth,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: AppSpacing.pageControlRailMaxHeight,
                  ),
                  child: Material(
                    key: const Key('page_control_rail'),
                    color: Theme.of(context).colorScheme.surface,
                    elevation: AppSpacing.floatingControlElevation,
                    shadowColor: Theme.of(context).colorScheme.shadow
                        .withValues(
                          alpha: AppSpacing.floatingControlShadowAlpha,
                        ),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.floatingControlCornerRadius,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(
                        AppSpacing.floatingControlPadding,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.floatingControlCornerRadius,
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              key: const Key('zoom_in_button'),
                              tooltip: 'Zoom in',
                              constraints: const BoxConstraints.tightFor(
                                width: AppSpacing.touchTarget,
                                height: AppSpacing.touchTarget,
                              ),
                              onPressed: _zoomIn,
                              icon: const Icon(Icons.zoom_in),
                            ),
                            IconButton(
                              key: const Key('zoom_out_button'),
                              tooltip: 'Zoom out',
                              constraints: const BoxConstraints.tightFor(
                                width: AppSpacing.touchTarget,
                                height: AppSpacing.touchTarget,
                              ),
                              onPressed: _zoomOut,
                              icon: const Icon(Icons.zoom_out),
                            ),
                            IconButton(
                              key: const Key('reset_zoom_button'),
                              tooltip: 'Reset zoom',
                              constraints: const BoxConstraints.tightFor(
                                width: AppSpacing.touchTarget,
                                height: AppSpacing.touchTarget,
                              ),
                              onPressed: _resetZoom,
                              icon: const Icon(Icons.center_focus_strong),
                            ),
                            IconButton(
                              key: const Key('paper_settings_button'),
                              tooltip: 'Paper settings',
                              constraints: const BoxConstraints.tightFor(
                                width: AppSpacing.touchTarget,
                                height: AppSpacing.touchTarget,
                              ),
                              onPressed: _openPaperCustomization,
                              icon: const AppIcon(AppIcons.paper),
                            ),
                            IconButton(
                              key: const Key('previous_page_button'),
                              tooltip: 'Previous page',
                              constraints: const BoxConstraints.tightFor(
                                width: AppSpacing.touchTarget,
                                height: AppSpacing.touchTarget,
                              ),
                              onPressed: _currentPageIndex > 0
                                  ? () => _goToPage(_currentPageIndex - 1)
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            IconButton(
                              key: const Key('next_page_button'),
                              tooltip: 'Next page',
                              constraints: const BoxConstraints.tightFor(
                                width: AppSpacing.touchTarget,
                                height: AppSpacing.touchTarget,
                              ),
                              onPressed: _currentPageIndex < _pages.length - 1
                                  ? () => _goToPage(_currentPageIndex + 1)
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface
                        .withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      'Page ${_currentPageIndex + 1} of ${_pages.length}',
                      key: const Key('page_counter'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
            if (_activePopover != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 82,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _buildActivePopover(),
                ),
              ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: _buildFloatingToolbar(),
            ),
          ],
        ),
      ),
    );
  }
}
