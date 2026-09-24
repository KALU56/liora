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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paperTemplate': paperTemplate.toJson(),
      'strokes': strokes.map((stroke) => stroke.toMap()).toList(),
      'toolConfig': toolConfig.toMap(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory NotePage.fromMap(Map<String, dynamic> map) {
    final rawStrokes = map['strokes'];
    return NotePage(
      id: map['id'] as String? ?? 'page',
      paperTemplate: map['paperTemplate'] is Map
          ? PaperTemplate.fromJson(
              Map<String, dynamic>.from(map['paperTemplate'] as Map),
            )
          : const PaperTemplate(),
      strokes: rawStrokes is List
          ? rawStrokes
                .whereType<Map>()
                .map(
                  (stroke) => Stroke.fromMap(Map<String, dynamic>.from(stroke)),
                )
                .toList()
          : const [],
      toolConfig: map['toolConfig'] is Map
          ? ToolConfig.fromMap(
              Map<String, dynamic>.from(map['toolConfig'] as Map),
            )
          : const ToolConfig(),
    );
  }

  factory NotePage.fromJson(Map<String, dynamic> json) =>
      NotePage.fromMap(json);
}
