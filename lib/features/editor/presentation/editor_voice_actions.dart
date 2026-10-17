part of 'new_note_screen.dart';

extension _EditorVoiceActions on _NewNoteScreenState {
  Future<void> _toggleVoiceInput() async {
    if (_voiceSessionRequested) {
      _voiceSessionRequested = false;
      await _media.stopSpeech();
      if (mounted) {
        _updateEditorState(() {
          _isListening = false;
          _voiceRestartScheduled = false;
        });
      }
      return;
    }
    _voiceSessionRequested = true;
    _voiceRestartScheduled = false;
    _voiceDraft = '';
    FocusManager.instance.primaryFocus?.unfocus();
    _updateEditorState(() {
      _isListening = true;
      _isTextMode = false;
      _isPenMode = false;
      _inlineTextPosition = null;
      _editingTextIndex = null;
      _activePopover = null;
    });
    try {
      if (!_speechInitialized) {
        _speechInitialized = await _media.initializeSpeech(
          onStatus: (status) {
            if (status == 'listening') {
              _voiceRestartScheduled = false;
              if (mounted) _updateEditorState(() => _isListening = true);
            } else if (status == 'notListening' || status == 'done') {
              if (!_voiceSessionRequested) {
                if (mounted) _updateEditorState(() => _isListening = false);
              } else {
                _scheduleVoiceRestart();
              }
            }
          },
          onError: (_) {
            _voiceSessionRequested = false;
            if (mounted) {
              _updateEditorState(() => _isListening = false);
              _showMediaError(message: 'Voice input is unavailable.');
            }
          },
        );
      }
      if (!_speechInitialized) {
        _voiceSessionRequested = false;
        if (mounted) _updateEditorState(() => _isListening = false);
        _showMediaError(message: 'Speech recognition is not available.');
        return;
      }
      if (_selectedTextIndex == null ||
          _selectedTextIndex! >= _currentPage.textBlocks.length) {
        final blocks = [
          ..._currentPage.textBlocks,
          const NoteTextBlock(text: ''),
        ];
        _selectedTextIndex = blocks.length - 1;
        _replaceCurrentPage(_currentPage.copyWith(textBlocks: blocks));
      }
      _speechPrefix = _currentPage.textBlocks[_selectedTextIndex!].text;
      await _listenSpeechSegment();
      if (mounted && _voiceSessionRequested) {
        _updateEditorState(() => _isListening = true);
      }
    } catch (_) {
      _voiceSessionRequested = false;
      if (mounted) {
        _updateEditorState(() => _isListening = false);
        _showMediaError(message: 'Voice input could not start.');
      }
    }
  }

  Future<void> _listenSpeechSegment() => _media.listenSpeech(
    onResult: (words, isFinal) => _onVoiceResult(words, finalResult: isFinal),
  );

  void _scheduleVoiceRestart() {
    if (_voiceRestartScheduled) return;
    _voiceRestartScheduled = true;
    Future<void>.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted || !_voiceSessionRequested) return;
      try {
        await _listenSpeechSegment();
      } catch (_) {
        _voiceRestartScheduled = false;
        _voiceSessionRequested = false;
        if (mounted) {
          _updateEditorState(() => _isListening = false);
          _showMediaError(message: 'Voice input could not resume.');
        }
      }
    });
  }

  void _onVoiceResult(String recognizedWords, {required bool finalResult}) {
    if (!mounted || _selectedTextIndex == null) return;
    final words = recognizedWords.trim();
    if (finalResult && words.isNotEmpty) {
      _voiceDraft = [
        _voiceDraft,
        words,
      ].where((part) => part.trim().isNotEmpty).join(' ');
    }
    final displayText = [
      _speechPrefix,
      _voiceDraft,
      if (!finalResult) words,
    ].where((part) => part.trim().isNotEmpty).join(' ');
    final index = _selectedTextIndex!;
    final blocks = List<NoteTextBlock>.from(_currentPage.textBlocks);
    if (index >= blocks.length) return;
    blocks[index] = blocks[index].copyWith(text: displayText);
    _replaceCurrentPage(_currentPage.copyWith(textBlocks: blocks));
  }
}
