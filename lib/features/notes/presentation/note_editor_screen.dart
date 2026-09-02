import 'package:flutter/material.dart';

import '../../canvas/domain/models/stroke.dart';
import '../../canvas/presentation/widgets/handwriting_canvas_widget.dart';
import '../../paper/domain/models/paper_template.dart';
import '../../paper/presentation/widgets/paper_canvas_widget.dart';
import '../../paper/presentation/widgets/paper_customization_sheet.dart';

/// Screen representing the notebook canvas editor.
/// Supports InteractiveViewer panning/zooming, real-time Paper Template customization,
/// and smooth handwriting stroke drawing.
class NoteEditorScreen extends StatefulWidget {
  final String title;
  final PaperTemplate initialTemplate;
  final List<Stroke>? initialStrokes;

  const NoteEditorScreen({
    super.key,
    this.title = 'Untitled Note',
    this.initialTemplate = const PaperTemplate(),
    this.initialStrokes,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late PaperTemplate _paperTemplate;
  final TransformationController _transformationController =
      TransformationController();
  List<Stroke> _strokes = [];
  bool _isPenMode = true;
  final Color _penColor = Colors.black;
  final double _penWidth = 3.0;

  @override
  void initState() {
    super.initState();
    _paperTemplate = widget.initialTemplate;
    if (widget.initialStrokes != null) {
      _strokes = List.from(widget.initialStrokes!);
    }
  }

  @override
  void dispose() {
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
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
      });
    }
  }

  void _clearCanvas() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        title: Text(widget.title, key: const Key('editor_title')),
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
            tooltip: 'Undo Stroke',
            onPressed: _strokes.isEmpty ? null : _undoStroke,
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
        ],
      ),
      body: Stack(
        children: [
          // Pan and Zoom Canvas Viewport
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
                      currentColor: _penColor,
                      currentStrokeWidth: _penWidth,
                      onStrokesChanged: (newStrokes) {
                        setState(() {
                          _strokes = newStrokes;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating Viewport Control Overlay (Zoom In, Zoom Out, Reset Zoom)
          Positioned(
            right: 16.0,
            bottom: 24.0,
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
    );
  }
}
