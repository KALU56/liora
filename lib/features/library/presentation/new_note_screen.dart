import 'package:flutter/material.dart';

import '../../../../core/dependencies/app_dependencies.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../canvas/application/canvas_use_cases.dart';
import '../../canvas/domain/models/writing_tool.dart';
import '../../canvas/presentation/widgets/handwriting_canvas_widget.dart';
import '../../canvas/presentation/widgets/writing_tools_toolbar.dart';
import '../../notes/application/notes_use_cases.dart';
import '../../notes/domain/models/note_model.dart';
import '../../notes/domain/models/note_page.dart';
import '../../notes/domain/repositories/notes_repository.dart';
import '../../paper/application/paper_use_cases.dart';
import '../../paper/domain/models/paper_template.dart';
import '../../paper/presentation/widgets/paper_canvas_widget.dart';
import '../../paper/presentation/widgets/paper_customization_sheet.dart';

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
  bool _isPenMode = true;

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _transformationController.dispose();
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
    _autosaveExistingNote();
  }

  void _autosaveExistingNote() {
    final existingNote = _existingNote;
    if (existingNote == null) return;

    final title = _titleController.text.trim();
    final updated = existingNote.copyWith(
      title: title.isEmpty ? 'Untitled Note' : title,
      pages: _pages,
    );
    if (_notes.updateNote(updated)) {
      _existingNote = _notes.getNoteById(updated.id) ?? updated;
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

  void _toggleToolMode() {
    setState(() {
      _isPenMode = !_isPenMode;
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
    _autosaveExistingNote();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final noteTitle = title.isEmpty ? 'Untitled Note' : title;
    _autosaveExistingNote();
    Navigator.of(context).pop({
      'id': _existingNote?.id,
      'title': noteTitle,
      'pages': List<NotePage>.from(_pages),
      'date': 'Today',
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingNote != null;
    final displayTitle = _titleController.text.isEmpty
        ? (isEditing ? 'Untitled Note' : 'Create New Note')
        : _titleController.text;
    final page = _currentPage;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayTitle, key: const Key('editor_title')),
        actions: [
          IconButton(
            key: const Key('tool_mode_button'),
            icon: Icon(_isPenMode ? Icons.edit : Icons.pan_tool),
            tooltip: _isPenMode ? 'Switch to Pan Mode' : 'Switch to Pen Mode',
            onPressed: _toggleToolMode,
          ),
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
            key: const Key('clear_canvas_button'),
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear Canvas',
            onPressed: page.strokes.isEmpty ? null : _clearCanvas,
          ),
          IconButton(
            key: const Key('paper_settings_button'),
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Paper Settings',
            onPressed: _openPaperCustomization,
          ),
          IconButton(
            key: const Key('save_editor_button'),
            icon: const Icon(Icons.check),
            onPressed: _submit,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              key: const Key('editor_title_input'),
              controller: _titleController,
              labelText: 'Note Title',
              hintText: 'e.g. Biology Lecture 1',
              autofocus: !isEditing,
              onChanged: (_) {
                setState(() {});
                _autosaveExistingNote();
              },
            ),
            AppSpacing.gapMd,
            Row(
              children: [
                IconButton(
                  key: const Key('previous_page_button'),
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous Page',
                  onPressed: _currentPageIndex == 0
                      ? null
                      : () => _goToPage(_currentPageIndex - 1),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Page ${_currentPageIndex + 1} of ${_pages.length}',
                      key: const Key('page_counter'),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('next_page_button'),
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next Page',
                  onPressed: _currentPageIndex == _pages.length - 1
                      ? null
                      : () => _goToPage(_currentPageIndex + 1),
                ),
                IconButton(
                  key: const Key('add_page_button'),
                  icon: const Icon(Icons.note_add_outlined),
                  tooltip: 'Add Page',
                  onPressed: _addPage,
                ),
              ],
            ),
            if (_isPenMode)
              WritingToolsToolbar(
                activeConfig: page.toolConfig,
                onConfigChanged: (newConfig) {
                  _replaceCurrentPage(page.copyWith(toolConfig: newConfig));
                },
              ),
            AppSpacing.gapSm,
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: InteractiveViewer(
                          key: const Key('note_interactive_viewer'),
                          transformationController: _transformationController,
                          panEnabled: !_isPenMode,
                          scaleEnabled: true,
                          constrained: true,
                          minScale: 0.2,
                          maxScale: 5.0,
                          boundaryMargin: const EdgeInsets.all(800),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: PaperCanvasWidget(
                                key: const Key('paper_canvas'),
                                template: page.paperTemplate,
                                child: HandwritingCanvasWidget(
                                  key: const Key('handwriting_canvas'),
                                  strokes: page.strokes,
                                  isDrawingMode: _isPenMode,
                                  toolConfig: page.toolConfig,
                                  canvasUseCases: _canvas,
                                  onStrokesChanged: (newStrokes) {
                                    _replaceCurrentPage(
                                      _currentPage.copyWith(
                                        strokes: newStrokes,
                                      ),
                                    );
                                  },
                                  onActionRecorded: _canvas.recordAction,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  key: const Key('zoom_out_button'),
                                  icon: const Icon(Icons.zoom_out),
                                  tooltip: 'Zoom Out',
                                  onPressed: _zoomOut,
                                ),
                                IconButton(
                                  key: const Key('reset_zoom_button'),
                                  icon: const Icon(Icons.center_focus_strong),
                                  tooltip: 'Reset Zoom',
                                  onPressed: _resetZoom,
                                ),
                                IconButton(
                                  key: const Key('zoom_in_button'),
                                  icon: const Icon(Icons.zoom_in),
                                  tooltip: 'Zoom In',
                                  onPressed: _zoomIn,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppSpacing.gapMd,
            AppButton(
              key: const Key('submit_create_note_button'),
              label: isEditing ? 'Save Changes' : 'Create Note',
              isFullWidth: true,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
