import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../canvas/domain/models/canvas_action.dart';
import '../../canvas/domain/models/stroke.dart';
import '../../canvas/domain/models/writing_tool.dart';
import '../../canvas/domain/services/canvas_history_manager.dart';
import '../../canvas/presentation/widgets/handwriting_canvas_widget.dart';
import '../../canvas/presentation/widgets/writing_tools_toolbar.dart';
import '../../notes/domain/models/note_model.dart';
import '../../paper/domain/models/paper_template.dart';
import '../../paper/presentation/widgets/paper_canvas_widget.dart';
import '../../paper/presentation/widgets/paper_customization_sheet.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({super.key});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  NoteModel? _existingNote;
  bool _isInitialized = false;

  PaperTemplate _paperTemplate = const PaperTemplate();
  final TransformationController _transformationController =
      TransformationController();
  final CanvasHistoryManager _historyManager = CanvasHistoryManager();
  List<Stroke> _strokes = [];
  bool _isPenMode = true;
  ToolConfig _toolConfig = ToolConfig.defaultPen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is NoteModel) {
        _existingNote = args;
        _titleController.text = args.title;
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _openPaperCustomization() async {
    final updatedTemplate = await PaperCustomizationSheet.show(
      context,
      initialTemplate: _paperTemplate,
      onLiveUpdate: (newTemplate) {
        setState(() {
          _paperTemplate = newTemplate;
        });
      },
    );

    if (updatedTemplate != null && mounted) {
      setState(() {
        _paperTemplate = updatedTemplate;
      });
    }
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  void _zoomIn() {
    final Matrix4 matrix = _transformationController.value.clone();
    matrix.multiply(Matrix4.diagonal3Values(1.25, 1.25, 1.25));
    setState(() {
      _transformationController.value = matrix;
    });
  }

  void _zoomOut() {
    final Matrix4 matrix = _transformationController.value.clone();
    matrix.multiply(Matrix4.diagonal3Values(0.8, 0.8, 0.8));
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
    if (_historyManager.canUndo) {
      setState(() {
        _strokes = _historyManager.undo(_strokes);
      });
    }
  }

  void _redoStroke() {
    if (_historyManager.canRedo) {
      setState(() {
        _strokes = _historyManager.redo(_strokes);
      });
    }
  }

  void _clearCanvas() {
    if (_strokes.isNotEmpty) {
      _historyManager.recordAction(ClearCanvasAction(List.from(_strokes)));
      setState(() {
        _strokes.clear();
      });
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final noteTitle = title.isEmpty ? 'Untitled Note' : title;
    Navigator.of(context)
        .pop({'id': _existingNote?.id, 'title': noteTitle, 'date': 'Today'});
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingNote != null;
    final displayTitle = _titleController.text.isEmpty
        ? (isEditing ? 'Untitled Note' : 'Create New Note')
        : _titleController.text;

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
            onPressed: _historyManager.canUndo ? _undoStroke : null,
          ),
          IconButton(
            key: const Key('redo_stroke_button'),
            icon: const Icon(Icons.redo),
            tooltip: 'Redo Action',
            onPressed: _historyManager.canRedo ? _redoStroke : null,
          ),
          IconButton(
            key: const Key('clear_canvas_button'),
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear Canvas',
            onPressed: _strokes.isEmpty ? null : _clearCanvas,
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
              onChanged: (val) {
                setState(() {});
              },
            ),
            AppSpacing.gapMd,
            if (_isPenMode)
              WritingToolsToolbar(
                activeConfig: _toolConfig,
                onConfigChanged: (newConfig) {
                  setState(() {
                    _toolConfig = newConfig;
                  });
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
                      // Pan & Zoom Viewport
                      Positioned.fill(
                        child: InteractiveViewer(
                          key: const Key('note_interactive_viewer'),
                          transformationController: _transformationController,
                          panEnabled: !_isPenMode,
                          scaleEnabled: true,
                          constrained: false,
                          minScale: 0.2,
                          maxScale: 5.0,
                          boundaryMargin: const EdgeInsets.all(800),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: PaperCanvasWidget(
                                key: const Key('paper_canvas'),
                                template: _paperTemplate,
                                child: HandwritingCanvasWidget(
                                  key: const Key('handwriting_canvas'),
                                  strokes: _strokes,
                                  isDrawingMode: _isPenMode,
                                  toolConfig: _toolConfig,
                                  onStrokesChanged: (newStrokes) {
                                    setState(() {
                                      _strokes = newStrokes;
                                    });
                                  },
                                  onActionRecorded: (action) {
                                    setState(() {
                                      _historyManager.recordAction(action);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Zoom Control Overlay
                      Positioned(
                        right: 12.0,
                        bottom: 12.0,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 4.0,
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
