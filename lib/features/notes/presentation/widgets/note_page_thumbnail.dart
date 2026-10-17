import 'package:flutter/material.dart';

import '../../domain/models/note_page.dart';
import '../../../canvas/presentation/widgets/stroke_painter.dart';
import '../../../paper/presentation/widgets/paper_painter.dart';

/// Paints a scaled preview of the first note page in the library grid.
class NotePageThumbnail extends StatelessWidget {
  final NotePage page;

  const NotePageThumbnail({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: page.paperTemplate.width,
            height: page.paperTemplate.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: PaperPainter(template: page.paperTemplate),
                ),
                CustomPaint(painter: StrokePainter(strokes: page.strokes)),
                for (final block in page.textBlocks)
                  Positioned(
                    left: block.x,
                    top: block.y,
                    child: Text(
                      block.text,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: block.fontFamily,
                        fontSize: block.fontSize,
                        color: Color(block.colorValue),
                        fontWeight: block.bold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontStyle: block.italic
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
