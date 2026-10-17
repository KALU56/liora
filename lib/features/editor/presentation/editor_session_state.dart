import 'dart:ui';

import 'package:notability_clone/features/notes/domain/models/note_page.dart';

enum EditorPopover { content, pen, expanded, text, stroke }

/// Holds the editor session's shared page, mode, selection, and voice state.
class EditorSessionState {
  List<NotePage> pages = [];
  int currentPageIndex = 0;
  int newPageCounter = 0;
  bool isInitialized = false;
  bool isPenMode = false;
  bool isTextMode = false;
  bool isPanMode = false;
  bool isRecording = false;
  bool isListening = false;
  bool voiceSessionRequested = false;
  bool voiceRestartScheduled = false;
  bool speechInitialized = false;
  EditorPopover? activePopover;
  int? selectedTextIndex;
  String? selectedStrokeId;
  int? editingTextIndex;
  Offset? inlineTextPosition;
  int? draggingTextIndex;
  Offset? lastTextPointerPosition;
  Offset textDragDelta = Offset.zero;
  String speechPrefix = '';
  String voiceDraft = '';
}
