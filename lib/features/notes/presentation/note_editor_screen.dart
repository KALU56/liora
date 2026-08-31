import 'package:flutter/material.dart';

import '../../paper/domain/models/paper_template.dart';
import '../../paper/presentation/widgets/paper_canvas_widget.dart';
import '../../paper/presentation/widgets/paper_customization_sheet.dart';

/// Screen representing the notebook canvas editor.
/// Supports InteractiveViewer panning/zooming and real-time Paper Template customization.
class NoteEditorScreen extends StatefulWidget {
  final String title;
  final PaperTemplate initialTemplate;

  const NoteEditorScreen({
    super.key,
    this.title = 'Untitled Note',
    this.initialTemplate = const PaperTemplate(),
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late PaperTemplate _paperTemplate;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _paperTemplate = widget.initialTemplate;
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
    matrix.multiply(Matrix4.diagonal3Values(1.25, 1.25, 1.0));
    setState(() {
      _transformationController.value = matrix;
    });
  }

  void _zoomOut() {
    final Matrix4 matrix = _transformationController.value.clone();
    matrix.multiply(Matrix4.diagonal3Values(0.8, 0.8, 1.0));
    setState(() {
      _transformationController.value = matrix;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        title: Text(widget.title, key: const Key('editor_title')),
        actions: [
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
              minScale: 0.2,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(800),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: PaperCanvasWidget(
                    key: const Key('paper_canvas'),
                    template: _paperTemplate,
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
