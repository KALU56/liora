part of 'new_note_screen.dart';

extension _EditorPageNavigation on _NewNoteScreenState {
  Future<void> _openPaperCustomization() async {
    final updatedTemplate = await PaperCustomizationSheet.show(
      context,
      initialTemplate: _currentPage.paperTemplate,
      onLiveUpdate: (newTemplate) {
        _replaceCurrentPage(
          _currentPage.copyWith(
            paperTemplate: _paper.updateTemplate(
              _currentPage.paperTemplate,
              newTemplate,
            ),
          ),
        );
      },
    );

    if (updatedTemplate != null && mounted) {
      _replaceCurrentPage(
        _currentPage.copyWith(paperTemplate: updatedTemplate),
      );
    }
  }

  void _resetZoom() {
    _updateEditorState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone()
      ..multiply(Matrix4.diagonal3Values(1.25, 1.25, 1.25));
    _updateEditorState(() {
      _transformationController.value = matrix;
    });
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone()
      ..multiply(Matrix4.diagonal3Values(0.8, 0.8, 0.8));
    _updateEditorState(() {
      _transformationController.value = matrix;
    });
  }
}
