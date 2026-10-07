import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/dependencies/app_dependencies.dart';
import '../../canvas/application/canvas_use_cases.dart';
import '../../canvas/domain/models/argb_color.dart';
import '../../canvas/domain/models/writing_tool.dart';
import '../../canvas/presentation/widgets/handwriting_canvas_widget.dart';
import '../../notes/application/notes_use_cases.dart';
import '../../notes/domain/models/note_model.dart';
import '../../notes/domain/models/note_page.dart';
import '../../notes/domain/models/note_text_block.dart';
import '../../notes/domain/repositories/notes_repository.dart';
import '../../paper/application/paper_use_cases.dart';
import '../../paper/domain/models/paper_template.dart';
import '../../paper/presentation/widgets/paper_canvas_widget.dart';
import '../../paper/presentation/widgets/paper_customization_sheet.dart';

enum _EditorPopover { content, pen, expanded }

/// The note editor used for both a new note and an existing saved note.
/// Each page owns its canvas data, paper template, and tool configuration.
class NewNoteScreen extends StatefulWidget {
  final NotesRepository? repository;
  final NotesUseCases? useCases;

  const NewNoteScreen({super.key, this.repository, this.useCases});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TransformationController _transformationController =
      TransformationController();
  final Map<String, CanvasUseCases> _canvasByPage = {};

  late final NotesUseCases _notes;
  late final PaperUseCases _paper;
  NoteModel? _existingNote;
  late List<NotePage> _pages;
  int _currentPageIndex = 0;
  int _newPageCounter = 0;
  bool _isInitialized = false;
  bool _isPenMode = false;
  bool _isTextMode = false;
  bool _isRecording = false;
  bool _isListening = false;
  bool _voiceSessionRequested = false;
  bool _voiceRestartScheduled = false;
  bool _speechInitialized = false;
  _EditorPopover? _activePopover;
  int? _selectedTextIndex;
  int? _editingTextIndex;
  Offset? _inlineTextPosition;
  int? _draggingTextIndex;
  Offset? _lastTextPointerPosition;
  Offset _textDragDelta = Offset.zero;
  String _speechPrefix = '';
  String _voiceDraft = '';
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _imagePicker = ImagePicker();

  NotePage get _currentPage => _pages[_currentPageIndex];
  CanvasUseCases get _canvas =>
      _canvasByPage.putIfAbsent(_currentPage.id, CanvasUseCases.new);

  @override
  void initState() {
    super.initState();
    _notes =
        widget.useCases ??
        (widget.repository == null
            ? appDependencies.notes
            : NotesUseCases(widget.repository!));
    _paper = appDependencies.paper;
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
    _recorder.dispose();
    _audioPlayer.dispose();
    _speech.cancel();
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

  void _openPopover(_EditorPopover popover) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isTextMode = false;
      _isPenMode = false;
      _inlineTextPosition = null;
      _editingTextIndex = null;
      if (popover == _EditorPopover.content) _isPenMode = false;
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
      _inlineTextPosition = null;
      _editingTextIndex = null;
      _activePopover = null;
    });
  }

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
    setState(() {
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
      _textController.text = selectedBlock?.text ?? '';
    });
  }

  void _moveTextBlock(int index, Offset delta) {
    if (index < 0 || index >= _currentPage.textBlocks.length) return;
    final blocks = List<NoteTextBlock>.from(_currentPage.textBlocks);
    final block = blocks[index];
    final pageSize = _currentPage.paperTemplate.pageSize;
    blocks[index] = block.copyWith(
      x: (block.x + delta.dx).clamp(0, pageSize.width - 32).toDouble(),
      y: (block.y + delta.dy).clamp(0, pageSize.height - 32).toDouble(),
    );
    _replaceCurrentPage(_currentPage.copyWith(textBlocks: blocks));
  }

  void _handleCanvasPointerDown(Offset position) {
    if (_isTextMode) {
      _beginCanvasTextInput(position);
      return;
    }
    _draggingTextIndex = null;
    for (var index = _currentPage.textBlocks.length - 1; index >= 0; index--) {
      final block = _currentPage.textBlocks[index];
      final availableWidth =
          _currentPage.paperTemplate.pageSize.width - block.x;
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
        _draggingTextIndex = index;
        break;
      }
    }
    _lastTextPointerPosition = position;
    _textDragDelta = Offset.zero;
  }

  void _handleCanvasPointerMove(Offset position) {
    if (_draggingTextIndex == null || _lastTextPointerPosition == null) return;
    _textDragDelta += position - _lastTextPointerPosition!;
    _lastTextPointerPosition = position;
  }

  void _handleCanvasPointerUp() {
    final index = _draggingTextIndex;
    if (index != null && _textDragDelta.distance > 2) {
      _moveTextBlock(index, _textDragDelta);
    }
    _draggingTextIndex = null;
    _lastTextPointerPosition = null;
    _textDragDelta = Offset.zero;
  }

  void _updateCanvasText(String value) {
    if (value.isEmpty && _editingTextIndex == null) return;
    final blocks = List<NoteTextBlock>.from(_currentPage.textBlocks);
    final index = _editingTextIndex;
    if (index != null && index < blocks.length) {
      blocks[index] = blocks[index].copyWith(text: value);
    } else {
      final position = _inlineTextPosition ?? const Offset(24, 24);
      blocks.add(NoteTextBlock(text: value, x: position.dx, y: position.dy));
      _editingTextIndex = blocks.length - 1;
      _selectedTextIndex = _editingTextIndex;
    }
    _replaceCurrentPage(_currentPage.copyWith(textBlocks: blocks));
  }

  Future<void> _toggleVoiceInput() async {
    if (_voiceSessionRequested) {
      _voiceSessionRequested = false;
      await _speech.stop();
      if (mounted) {
        setState(() {
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
    setState(() {
      _isListening = true;
      _isTextMode = false;
      _isPenMode = false;
      _inlineTextPosition = null;
      _editingTextIndex = null;
      _activePopover = null;
    });
    try {
      if (!_speechInitialized) {
        _speechInitialized = await _speech.initialize(
          onStatus: (status) {
            if (status == 'listening') {
              _voiceRestartScheduled = false;
              if (mounted) setState(() => _isListening = true);
            } else if (status == 'notListening' || status == 'done') {
              if (!_voiceSessionRequested) {
                if (mounted) setState(() => _isListening = false);
              } else {
                _scheduleVoiceRestart();
              }
            }
          },
          onError: (_) {
            _voiceSessionRequested = false;
            if (mounted) {
              setState(() => _isListening = false);
              _showMediaError(message: 'Voice input is unavailable.');
            }
          },
        );
      }
      if (!_speechInitialized) {
        _voiceSessionRequested = false;
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
        setState(() => _isListening = true);
      }
    } catch (_) {
      _voiceSessionRequested = false;
      if (mounted) {
        setState(() => _isListening = false);
        _showMediaError(message: 'Voice input could not start.');
      }
    }
  }

  Future<void> _listenSpeechSegment() => _speech.listen(
    onResult: (result) =>
        _onVoiceResult(result.recognizedWords, finalResult: result.finalResult),
    listenOptions: stt.SpeechListenOptions(
      partialResults: true,
      pauseFor: Duration(seconds: 30),
      listenFor: Duration(minutes: 5),
      listenMode: stt.ListenMode.dictation,
    ),
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
          setState(() => _isListening = false);
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

  Future<String> _keepFile(String path) async {
    final directory = await getApplicationDocumentsDirectory();
    final source = File(path);
    final name =
        '${DateTime.now().microsecondsSinceEpoch}_${source.uri.pathSegments.last}';
    return (await source.copy('${directory.path}/$name')).path;
  }

  Future<void> _addImage() async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null || !mounted) return;
      final path = await _keepFile(file.path);
      _replaceCurrentPage(
        _currentPage.copyWith(attachments: [..._currentPage.attachments, path]),
      );
    } catch (_) {
      _showMediaError();
    }
  }

  Future<void> _addFile() async {
    try {
      final files = await FilePicker.pickFiles();
      final path = files.isEmpty ? null : files.first.path;
      if (path == null || !mounted) return;
      final savedPath = await _keepFile(path);
      _replaceCurrentPage(
        _currentPage.copyWith(
          attachments: [..._currentPage.attachments, savedPath],
        ),
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
        await _speech.stop();
        _isListening = false;
      }
      if (_isRecording) {
        final path = await _recorder.stop();
        if (path != null && mounted) {
          final kept = await _keepFile(path);
          _replaceCurrentPage(
            _currentPage.copyWith(
              attachments: [..._currentPage.attachments, kept],
            ),
          );
        }
        if (mounted) setState(() => _isRecording = false);
        return;
      }
      if (!await _recorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is needed to record audio.'),
            ),
          );
        }
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/audio_${DateTime.now().microsecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      if (mounted) setState(() => _isRecording = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio recording is unavailable.')),
        );
      }
    }
  }

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
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone()
      ..multiply(Matrix4.diagonal3Values(1.25, 1.25, 1.25));
    setState(() {
      _transformationController.value = matrix;
    });
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone()
      ..multiply(Matrix4.diagonal3Values(0.8, 0.8, 0.8));
    setState(() {
      _transformationController.value = matrix;
    });
  }

  void _undoStroke() {
    if (_canvas.canUndo) {
      _replaceCurrentPage(
        _currentPage.copyWith(strokes: _canvas.undo(_currentPage.strokes)),
      );
    }
  }

  void _redoStroke() {
    if (_canvas.canRedo) {
      _replaceCurrentPage(
        _currentPage.copyWith(strokes: _canvas.redo(_currentPage.strokes)),
      );
    }
  }

  void _clearCanvas() {
    if (_currentPage.strokes.isNotEmpty) {
      _replaceCurrentPage(
        _currentPage.copyWith(strokes: _canvas.clear(_currentPage.strokes)),
      );
    }
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() {
      _currentPageIndex = index;
      _selectedTextIndex = null;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _addPage() {
    final newPage = _newPage(template: _currentPage.paperTemplate);
    setState(() {
      _pages = [..._pages, newPage];
      _currentPageIndex = _pages.length - 1;
      _transformationController.value = Matrix4.identity();
    });
    _autosaveNote();
  }

  Future<void> _leaveEditor() async {
    _autosaveNote();
    await _notes.flush();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _showMoreMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.zoom_in),
              title: const Text('Zoom in'),
              onTap: () {
                Navigator.pop(context);
                _zoomIn();
              },
            ),
            ListTile(
              leading: const Icon(Icons.zoom_out),
              title: const Text('Zoom out'),
              onTap: () {
                Navigator.pop(context);
                _zoomOut();
              },
            ),
            ListTile(
              leading: const Icon(Icons.center_focus_strong),
              title: const Text('Reset zoom'),
              onTap: () {
                Navigator.pop(context);
                _resetZoom();
              },
            ),
            ListTile(
              leading: const Icon(Icons.layers_outlined),
              title: const Text('Paper settings'),
              onTap: () {
                Navigator.pop(context);
                _openPaperCustomization();
              },
            ),
            ListTile(
              leading: const Icon(Icons.chevron_left),
              title: const Text('Previous page'),
              onTap: () {
                Navigator.pop(context);
                _goToPage(_currentPageIndex - 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chevron_right),
              title: const Text('Next page'),
              onTap: () {
                Navigator.pop(context);
                _goToPage(_currentPageIndex + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContentMenu() {
    _openPopover(_EditorPopover.content);
  }

  Future<void> _addLink() async {
    var enteredUrl = '';
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a link'),
        content: TextField(
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'https://example.com'),
          onChanged: (value) => enteredUrl = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, enteredUrl),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (value == null || !mounted) return;
    final normalized = value.trim().startsWith('http')
        ? value.trim()
        : 'https://${value.trim()}';
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasAuthority) {
      _showMediaError(message: 'Enter a valid web link.');
      return;
    }
    _replaceCurrentPage(
      _currentPage.copyWith(
        attachments: [..._currentPage.attachments, 'url:$normalized'],
      ),
    );
    setState(() => _activePopover = null);
  }

  Widget _attachmentPreview(String path) {
    if (path.startsWith('url:')) {
      final url = path.substring(4);
      return ListTile(
        leading: const Icon(Icons.link),
        title: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () async {
          try {
            if (!await launchUrl(Uri.parse(url))) {
              _showMediaError(message: 'Could not open this link.');
            }
          } catch (_) {
            _showMediaError(message: 'Could not open this link.');
          }
        },
      );
    }
    final file = File(path);
    final name = file.uri.pathSegments.isEmpty
        ? path
        : file.uri.pathSegments.last;
    if (name.toLowerCase().endsWith('.png') ||
        name.toLowerCase().endsWith('.jpg') ||
        name.toLowerCase().endsWith('.jpeg') ||
        name.toLowerCase().endsWith('.webp')) {
      return Image.file(
        file,
        height: 180,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(name),
      );
    }
    final isAudio =
        name.toLowerCase().endsWith('.m4a') ||
        name.toLowerCase().endsWith('.mp3') ||
        name.toLowerCase().endsWith('.wav') ||
        name.toLowerCase().endsWith('.aac');
    return ListTile(
      leading: Icon(
        isAudio ? Icons.audio_file : Icons.insert_drive_file_outlined,
      ),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: isAudio
          ? IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Play audio',
              onPressed: () async {
                try {
                  await _audioPlayer.play(DeviceFileSource(path));
                } catch (_) {
                  _showMediaError();
                }
              },
            )
          : null,
    );
  }

  Widget _toolButton({
    required Key key,
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
    bool active = false,
    String? label,
  }) => Tooltip(
    message: tooltip,
    child: InkWell(
      key: key,
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary.withValues(alpha: .12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: label == null
              ? Icon(
                  icon,
                  size: 22,
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    ),
  );

  Widget _buildFloatingToolbar() {
    final activeTool = _activePopover;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _toolButton(
              key: const Key('text_tool_button'),
              tooltip: _isTextMode ? 'Finish typing' : 'Type on canvas',
              icon: Icons.text_fields,
              label: 'Tt',
              active: _isTextMode,
              onPressed: _activateTextMode,
            ),
            _toolButton(
              key: const Key('voice_input_button'),
              tooltip: _isListening ? 'Stop voice input' : 'Voice input',
              icon: _isListening ? Icons.mic : Icons.mic_none,
              active: _voiceSessionRequested,
              onPressed: _toggleVoiceInput,
            ),
            _toolButton(
              key: const Key('add_content_button'),
              tooltip: 'Add content',
              icon: Icons.add,
              active: activeTool == _EditorPopover.content,
              onPressed: _showAddContentMenu,
            ),
            _toolButton(
              key: const Key('handwriting_tool_button'),
              tooltip: 'Handwriting / drawing',
              icon: Icons.gesture,
              active: _isPenMode,
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() {
                  _isPenMode = !_isPenMode;
                  _isTextMode = false;
                  _inlineTextPosition = null;
                  _editingTextIndex = null;
                  _activePopover = null;
                });
              },
            ),
            _toolButton(
              key: const Key('pen_tool_button'),
              tooltip: 'Pen settings',
              icon: Icons.edit_outlined,
              active: activeTool == _EditorPopover.pen,
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() {
                  _isTextMode = false;
                  _isPenMode = true;
                  _inlineTextPosition = null;
                  _editingTextIndex = null;
                  _activePopover = _activePopover == _EditorPopover.pen
                      ? null
                      : _EditorPopover.pen;
                });
              },
            ),
            _toolButton(
              key: const Key('expand_tools_button'),
              tooltip: 'More tools',
              icon: Icons.arrow_forward,
              active: activeTool == _EditorPopover.expanded,
              onPressed: () => _openPopover(_EditorPopover.expanded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePopover() {
    final popover = _activePopover;
    if (popover == null) return const SizedBox.shrink();
    final surface = switch (popover) {
      _EditorPopover.content => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Add photo'),
            onTap: _addImage,
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('Add file'),
            onTap: _addFile,
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Add link'),
            onTap: _addLink,
          ),
        ],
      ),
      _EditorPopover.pen => _buildPenPopover(),
      _EditorPopover.expanded => _buildExpandedPopover(),
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
    final tools = <(WritingToolType, IconData, String)>[
      (WritingToolType.pen, Icons.edit, 'tool_pen'),
      (WritingToolType.pencil, Icons.create_outlined, 'tool_pencil'),
      (WritingToolType.highlighter, Icons.highlight, 'tool_highlighter'),
      (WritingToolType.eraser, Icons.auto_fix_normal, 'tool_eraser'),
      (WritingToolType.shape, Icons.crop_16_9_outlined, 'tool_shape'),
    ];
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
              onPressed: () => setState(() => _activePopover = null),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tools
              .map(
                (item) => IconButton(
                  key: Key(item.$3),
                  tooltip: item.$1.name,
                  icon: Icon(item.$2),
                  color: config.toolType == item.$1
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  onPressed: () => _selectWritingTool(item.$1),
                ),
              )
              .toList(),
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
        if (config.toolType == WritingToolType.shape)
          DropdownButton<ShapeType>(
            key: const Key('shape_type_selector'),
            value: config.shapeType,
            items: ShapeType.values
                .map(
                  (shape) =>
                      DropdownMenuItem(value: shape, child: Text(shape.name)),
                )
                .toList(),
            onChanged: (shape) {
              if (shape != null) update(config.copyWith(shapeType: shape));
            },
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
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              key: const Key('preset_fine_pen'),
              tooltip: 'Fine pen',
              icon: const Icon(Icons.line_weight),
              onPressed: () => _selectPenPreset(
                ToolConfig.defaultPen.copyWith(strokeWidth: 1.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpandedPopover() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: const Icon(Icons.edit),
        title: const Text('Pen'),
        onTap: () => _selectWritingTool(WritingToolType.pen),
      ),
      ListTile(
        leading: const Icon(Icons.create_outlined),
        title: const Text('Pencil'),
        onTap: () => _selectWritingTool(WritingToolType.pencil),
      ),
      ListTile(
        leading: const Icon(Icons.highlight),
        title: const Text('Highlighter'),
        onTap: () => _selectWritingTool(WritingToolType.highlighter),
      ),
      ListTile(
        leading: const Icon(Icons.auto_fix_normal),
        title: const Text('Eraser'),
        onTap: () => _selectWritingTool(WritingToolType.eraser),
      ),
      ListTile(
        leading: const Icon(Icons.crop_16_9_outlined),
        title: const Text('Shapes'),
        onTap: () => _selectWritingTool(WritingToolType.shape),
      ),
      ListTile(
        leading: Icon(_isRecording ? Icons.stop : Icons.mic),
        title: Text(_isRecording ? 'Stop audio recording' : 'Record audio'),
        onTap: _toggleRecording,
      ),
      ListTile(
        key: const Key('clear_canvas_button'),
        leading: const Icon(Icons.delete_sweep_outlined),
        title: const Text('Clear handwriting'),
        onTap: () {
          _clearCanvas();
          setState(() => _activePopover = null);
        },
      ),
    ],
  );

  void _selectWritingTool(WritingToolType type) {
    final current = _currentPage.toolConfig;
    final updated = switch (type) {
      WritingToolType.pen =>
        current.toolType == type ? current : ToolConfig.defaultPen,
      WritingToolType.pencil =>
        current.toolType == type ? current : ToolConfig.defaultPencil,
      WritingToolType.highlighter =>
        current.toolType == type ? current : ToolConfig.defaultHighlighter,
      WritingToolType.eraser => current.copyWith(toolType: type),
      WritingToolType.shape => current.copyWith(toolType: type),
    };
    _replaceCurrentPage(_currentPage.copyWith(toolConfig: updated));
    setState(() {
      _isPenMode = true;
      _activePopover = null;
    });
  }

  void _selectPenColor(int colorValue) {
    _replaceCurrentPage(
      _currentPage.copyWith(
        toolConfig: _currentPage.toolConfig.copyWith(
          color: ArgbColor(colorValue),
        ),
      ),
    );
    setState(() => _activePopover = null);
  }

  void _selectPenPreset(ToolConfig config) {
    _replaceCurrentPage(_currentPage.copyWith(toolConfig: config));
    setState(() => _activePopover = null);
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = _titleController.text.trim().isEmpty
        ? 'Untitled Note'
        : _titleController.text.trim();
    final page = _currentPage;
    return Theme(
      data: Theme.of(context),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
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
                tooltip: 'Undo Action',
                onPressed: _canvas.canUndo ? _undoStroke : null,
              ),
              IconButton(
                key: const Key('redo_stroke_button'),
                icon: const Icon(Icons.redo),
                tooltip: 'Redo Action',
                onPressed: _canvas.canRedo ? _redoStroke : null,
              ),
              IconButton(
                key: const Key('add_page_button'),
                icon: const Icon(Icons.add),
                onPressed: _addPage,
                tooltip: 'Add Page',
              ),
              IconButton(
                key: const Key('editor_more_button'),
                icon: const Icon(Icons.more_vert),
                tooltip: 'More actions',
                onPressed: _showMoreMenu,
              ),
            ],
          ),
          extendBodyBehindAppBar: false,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      key: const Key('note_interactive_viewer'),
                      transformationController: _transformationController,
                      panEnabled: false,
                      scaleEnabled: true,
                      constrained: true,
                      minScale: .2,
                      maxScale: 5,
                      child: PaperCanvasWidget(
                        key: const Key('paper_canvas'),
                        canvasSize: Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                        template: page.paperTemplate,
                        showShadow: false,
                        child: HandwritingCanvasWidget(
                          key: const Key('handwriting_canvas'),
                          strokes: page.strokes,
                          isDrawingMode: _isPenMode,
                          toolConfig: page.toolConfig,
                          canvasUseCases: _canvas,
                          onStrokesChanged: (newStrokes) => _replaceCurrentPage(
                            _currentPage.copyWith(strokes: newStrokes),
                          ),
                          onCanvasTapDown: !_isPenMode
                              ? _handleCanvasPointerDown
                              : null,
                          onCanvasPointerMove: !_isPenMode
                              ? _handleCanvasPointerMove
                              : null,
                          onCanvasPointerUp: !_isPenMode
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
                                  .where(
                                    (entry) => entry.key != _editingTextIndex,
                                  )
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
          ),
        ),
      ),
    );
  }
}
