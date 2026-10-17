import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/dependencies/app_dependencies.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../canvas/application/canvas_use_cases.dart';
import '../../canvas/domain/models/canvas_action.dart';
import '../../canvas/domain/models/argb_color.dart';
import '../../canvas/domain/models/stroke.dart';
import '../../canvas/domain/models/writing_tool.dart';
import '../../canvas/presentation/widgets/handwriting_canvas_widget.dart';
import '../data/editor_media_service.dart';
import 'editor_session_state.dart';
import 'widgets/editor_content_menu.dart';
import '../../notes/application/notes_use_cases.dart';
import '../../notes/data/note_attachment_storage.dart';
import '../../notes/domain/models/note_model.dart';
import '../../notes/domain/models/note_page.dart';
import '../../notes/domain/models/note_text_block.dart';
import '../../notes/domain/repositories/notes_repository.dart';
import '../../paper/application/paper_use_cases.dart';
import '../../paper/domain/models/paper_template.dart';
import '../../paper/presentation/widgets/paper_canvas_widget.dart';
import '../../paper/presentation/widgets/paper_customization_sheet.dart';

part 'editor_selection_controls.dart';

part 'editor_canvas_interactions.dart';
part 'editor_voice_actions.dart';
part 'editor_popover_actions.dart';
part 'editor_tool_actions.dart';
part 'editor_attachment_preview.dart';
part 'editor_canvas_history.dart';
part 'editor_page_navigation.dart';
part 'editor_attachment_actions.dart';
part 'editor_text_interactions.dart';
part 'editor_toolbar_actions.dart';
part 'editor_app_bar.dart';
part 'editor_workspace.dart';

/// The note editor used for both a new note and an existing saved note.
/// Each page owns its canvas data, paper template, and tool configuration.
class NewNoteScreen extends StatefulWidget {
  final NotesRepository? repository;
  final NotesUseCases? useCases;
  final NoteAttachmentStorage? attachmentStorage;
  final EditorMediaService? mediaService;

  const NewNoteScreen({
    super.key,
    this.repository,
    this.useCases,
    this.attachmentStorage,
    this.mediaService,
  });

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final EditorSessionState _session = EditorSessionState();
  final TextEditingController _titleController = TextEditingController();
  final TransformationController _transformationController =
      TransformationController();
  final Map<String, CanvasUseCases> _canvasByPage = {};

  late final NotesUseCases _notes;
  late final PaperUseCases _paper;
  NoteModel? _existingNote;
  final TextEditingController _textController = TextEditingController();
  late final NoteAttachmentStorage _attachmentStorage;
  late final EditorMediaService _media;

  List<NotePage> get _pages => _session.pages;
  set _pages(List<NotePage> pages) => _session.pages = pages;
  int get _currentPageIndex => _session.currentPageIndex;
  set _currentPageIndex(int index) => _session.currentPageIndex = index;
  int get _newPageCounter => _session.newPageCounter;
  set _newPageCounter(int value) => _session.newPageCounter = value;
  bool get _isInitialized => _session.isInitialized;
  set _isInitialized(bool value) => _session.isInitialized = value;
  bool get _isPenMode => _session.isPenMode;
  set _isPenMode(bool value) => _session.isPenMode = value;
  bool get _isTextMode => _session.isTextMode;
  set _isTextMode(bool value) => _session.isTextMode = value;
  bool get _isPanMode => _session.isPanMode;
  set _isPanMode(bool value) => _session.isPanMode = value;
  bool get _isRecording => _session.isRecording;
  set _isRecording(bool value) => _session.isRecording = value;
  bool get _isListening => _session.isListening;
  set _isListening(bool value) => _session.isListening = value;
  bool get _voiceSessionRequested => _session.voiceSessionRequested;
  set _voiceSessionRequested(bool value) =>
      _session.voiceSessionRequested = value;
  bool get _voiceRestartScheduled => _session.voiceRestartScheduled;
  set _voiceRestartScheduled(bool value) =>
      _session.voiceRestartScheduled = value;
  bool get _speechInitialized => _session.speechInitialized;
  set _speechInitialized(bool value) => _session.speechInitialized = value;
  EditorPopover? get _activePopover => _session.activePopover;
  set _activePopover(EditorPopover? value) => _session.activePopover = value;
  int? get _selectedTextIndex => _session.selectedTextIndex;
  set _selectedTextIndex(int? value) => _session.selectedTextIndex = value;
  String? get _selectedStrokeId => _session.selectedStrokeId;
  set _selectedStrokeId(String? value) => _session.selectedStrokeId = value;
  int? get _editingTextIndex => _session.editingTextIndex;
  set _editingTextIndex(int? value) => _session.editingTextIndex = value;
  Offset? get _inlineTextPosition => _session.inlineTextPosition;
  set _inlineTextPosition(Offset? value) => _session.inlineTextPosition = value;
  int? get _draggingTextIndex => _session.draggingTextIndex;
  set _draggingTextIndex(int? value) => _session.draggingTextIndex = value;
  Offset? get _lastTextPointerPosition => _session.lastTextPointerPosition;
  set _lastTextPointerPosition(Offset? value) =>
      _session.lastTextPointerPosition = value;
  Offset get _textDragDelta => _session.textDragDelta;
  set _textDragDelta(Offset value) => _session.textDragDelta = value;
  String get _speechPrefix => _session.speechPrefix;
  set _speechPrefix(String value) => _session.speechPrefix = value;
  String get _voiceDraft => _session.voiceDraft;
  set _voiceDraft(String value) => _session.voiceDraft = value;

  NotePage get _currentPage => _pages[_currentPageIndex];
  CanvasUseCases get _canvas =>
      _canvasByPage.putIfAbsent(_currentPage.id, CanvasUseCases.new);

  void _updateEditorState(VoidCallback update) => setState(update);

  @override
  void initState() {
    super.initState();
    _notes =
        widget.useCases ??
        (widget.repository == null
            ? appDependencies.notes
            : NotesUseCases(widget.repository!));
    _paper = appDependencies.paper;
    _attachmentStorage =
        widget.attachmentStorage ?? appDependencies.noteAttachmentStorage;
    _media = widget.mediaService ?? EditorMediaService();
    _pages = [_newPage()];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is NoteModel) {
      _existingNote = args;
      _titleController.text = args.title;
      if (args.pages.isNotEmpty) {
        _pages = List<NotePage>.from(args.pages);
      }
    } else if (args is Map<String, dynamic>) {
      _titleController.text = args['title'] as String? ?? '';
    }
    _isInitialized = true;
    _ensureNoteExists();
    _autosaveNote();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _transformationController.dispose();
    unawaited(_media.dispose());
    super.dispose();
  }

  NotePage _newPage({PaperTemplate? template}) {
    _newPageCounter++;
    return NotePage(
      id: 'page_${DateTime.now().microsecondsSinceEpoch}_$_newPageCounter',
      paperTemplate: template ?? const PaperTemplate(),
      toolConfig: ToolConfig.defaultPen,
    );
  }

  void _replaceCurrentPage(NotePage page) {
    setState(() {
      _pages = List<NotePage>.from(_pages)..[_currentPageIndex] = page;
    });
    _autosaveNote();
  }

  void _ensureNoteExists() {
    if (_existingNote != null) return;
    _existingNote = _notes.createNote(
      title: _titleController.text,
      pages: _pages,
    );
  }

  void _autosaveNote() {
    _ensureNoteExists();
    final existingNote = _existingNote!;

    final title = _titleController.text.trim();
    final updated = existingNote.copyWith(
      title: title.isEmpty ? 'Untitled Note' : title,
      pages: _pages,
    );
    if (_notes.updateNote(updated)) {
      _existingNote = _notes.getNoteById(updated.id) ?? updated;
    }
  }

  Future<void> _editTitle() async {
    final originalTitle = _titleController.text;
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Note title'),
        content: TextField(
          controller: _titleController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Untitled Note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _titleController.text),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (title != null && mounted) {
      _titleController.text = title.trim().isEmpty
          ? 'Untitled Note'
          : title.trim();
      _autosaveNote();
      setState(() {});
    } else {
      _titleController.text = originalTitle;
    }
  }

  void _openPopover(EditorPopover popover) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isTextMode = false;
      _isPenMode = false;
      _isPanMode = false;
      _inlineTextPosition = null;
      _editingTextIndex = null;
      if (popover == EditorPopover.content) _isPenMode = false;
      _activePopover = _activePopover == popover ? null : popover;
    });
  }

  void _activateTextMode() {
    if (_isTextMode) {
      setState(() {
        _isTextMode = false;
        _inlineTextPosition = null;
        _editingTextIndex = null;
      });
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }
    setState(() {
      _isTextMode = true;
      _isPenMode = false;
      _isPanMode = false;
      _inlineTextPosition = null;
      _editingTextIndex = null;
      _activePopover = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = _titleController.text.trim().isEmpty
        ? 'Untitled Note'
        : _titleController.text.trim();
    return Theme(
      data: Theme.of(context),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: _buildEditorAppBar(displayTitle),
          extendBodyBehindAppBar: false,
          body: _buildEditorWorkspace(),
        ),
      ),
    );
  }
}
