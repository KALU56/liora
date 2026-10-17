part of 'new_note_screen.dart';

extension _EditorAttachmentActions on _NewNoteScreenState {
  Future<void> _addImage() async {
    try {
      final path = await _attachmentStorage.pickImageAndKeep();
      if (path == null || !mounted) return;
      _replaceCurrentPage(
        _currentPage.copyWith(attachments: [..._currentPage.attachments, path]),
      );
    } catch (_) {
      _showMediaError();
    }
  }

  Future<void> _addFile() async {
    try {
      final path = await _attachmentStorage.pickFileAndKeep();
      if (path == null || !mounted) return;
      _replaceCurrentPage(
        _currentPage.copyWith(attachments: [..._currentPage.attachments, path]),
      );
    } catch (_) {
      _showMediaError();
    }
  }

  void _showMediaError({
    String message = 'Could not add that file. Please try again.',
  }) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isListening) {
        await _media.stopSpeech();
        _isListening = false;
      }
      if (_isRecording) {
        final path = await _media.stopRecording();
        if (path != null && mounted) {
          final kept = await _attachmentStorage.keepFile(path);
          _replaceCurrentPage(
            _currentPage.copyWith(
              attachments: [..._currentPage.attachments, kept],
            ),
          );
        }
        if (mounted) _updateEditorState(() => _isRecording = false);
        return;
      }
      if (!await _media.startRecording()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is needed to record audio.'),
            ),
          );
        }
        return;
      }
      if (mounted) _updateEditorState(() => _isRecording = true);
    } catch (_) {
      if (mounted) {
        _updateEditorState(() => _isRecording = false);
        _showMediaError(message: 'Audio recording is unavailable.');
      }
    }
  }
}
