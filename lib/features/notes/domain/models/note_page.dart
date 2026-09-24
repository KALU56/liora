import '../../../canvas/domain/models/stroke.dart';
import '../../../canvas/domain/models/writing_tool.dart';
import '../../../paper/domain/models/paper_template.dart';

/// The independently editable content of one page in a note.
///
/// Keeping strokes and the active tool configuration on the page (rather than
/// on the note) prevents edits on one page from leaking into another page.
class NotePage {
  final String id;
  final PaperTemplate paperTemplate;
  final List<Stroke> strokes;
  final ToolConfig toolConfig;

  NotePage({
    required this.id,
    this.paperTemplate = const PaperTemplate(),
    List<Stroke>? strokes,
    this.toolConfig = const ToolConfig(),
  }) : strokes = List.unmodifiable(strokes ?? const []);

  NotePage copyWith({
    String? id,
    PaperTemplate? paperTemplate,
    List<Stroke>? strokes,
    ToolConfig? toolConfig,
  }) {
    return NotePage(
      id: id ?? this.id,
      paperTemplate: paperTemplate ?? this.paperTemplate,
      strokes: strokes ?? this.strokes,
      toolConfig: toolConfig ?? this.toolConfig,
    );
  }
}
