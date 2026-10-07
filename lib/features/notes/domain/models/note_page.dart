import '../../../canvas/domain/models/stroke.dart';
import '../../../canvas/domain/models/writing_tool.dart';
import '../../../paper/domain/models/paper_template.dart';
import 'note_text_block.dart';

/// The independently editable content of one page in a note.
///
/// Keeping strokes and the active tool configuration on the page (rather than
/// on the note) prevents edits on one page from leaking into another page.
class NotePage {
  final String id;
  final PaperTemplate paperTemplate;
  final List<Stroke> strokes;
  final ToolConfig toolConfig;
  final List<NoteTextBlock> textBlocks;
  final List<String> attachments;

  List<String> get textItems => textBlocks.map((block) => block.text).toList();

  NotePage({
    required this.id,
    this.paperTemplate = const PaperTemplate(),
    List<Stroke>? strokes,
    this.toolConfig = const ToolConfig(),
    List<String>? textItems,
    List<NoteTextBlock>? textBlocks,
    List<String>? attachments,
  }) : strokes = List.unmodifiable(strokes ?? const []),
       textBlocks = List.unmodifiable(
         textBlocks ??
             (textItems ?? const []).asMap().entries.map(
               (entry) => NoteTextBlock(
                 text: entry.value,
                 x: 24,
                 y: 24 + entry.key * 38,
               ),
             ),
       ),
       attachments = List.unmodifiable(attachments ?? const []);

  NotePage copyWith({
    String? id,
    PaperTemplate? paperTemplate,
    List<Stroke>? strokes,
    ToolConfig? toolConfig,
    List<String>? textItems,
    List<NoteTextBlock>? textBlocks,
    List<String>? attachments,
  }) {
    return NotePage(
      id: id ?? this.id,
      paperTemplate: paperTemplate ?? this.paperTemplate,
      strokes: strokes ?? this.strokes,
      toolConfig: toolConfig ?? this.toolConfig,
      textBlocks:
          textBlocks ??
          (textItems == null
              ? this.textBlocks
              : textItems
                    .asMap()
                    .entries
                    .map(
                      (entry) => NoteTextBlock(
                        text: entry.value,
                        x: 24,
                        y: 24 + entry.key * 38,
                      ),
                    )
                    .toList()),
      attachments: attachments ?? this.attachments,
    );
  }
}
