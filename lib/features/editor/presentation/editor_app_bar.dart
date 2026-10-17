part of 'new_note_screen.dart';

extension _EditorAppBar on _NewNoteScreenState {
  PreferredSizeWidget _buildEditorAppBar(String displayTitle) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: _leaveEditor,
      ),
      title: TextButton(
        key: const Key('editor_title'),
        onPressed: _editTitle,
        child: Text(
          displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      actions: [
        IconButton(
          key: const Key('undo_stroke_button'),
          icon: const Icon(Icons.undo),
          tooltip: 'Undo drawing action',
          onPressed: _canvas.canUndo ? _undoStroke : null,
        ),
        IconButton(
          key: const Key('redo_stroke_button'),
          icon: const Icon(Icons.redo),
          tooltip: 'Redo drawing action',
          onPressed: _canvas.canRedo ? _redoStroke : null,
        ),
        IconButton(
          key: const Key('add_page_button'),
          icon: const Icon(Icons.add),
          onPressed: _addPage,
          tooltip: 'Add Page',
        ),
      ],
    );
  }
}
