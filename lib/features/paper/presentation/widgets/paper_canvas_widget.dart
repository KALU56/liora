import 'package:flutter/material.dart';

import '../../domain/models/paper_template.dart';
import 'paper_painter.dart';

/// Interactive Page Container widget that renders a single note page with a given [PaperTemplate].
/// Maintains page bounds, shadows, and paints background guidelines/dots attached to page coordinates.
class PaperCanvasWidget extends StatelessWidget {
  final PaperTemplate template;
  final Widget? child;
  final bool showShadow;

  const PaperCanvasWidget({
    super.key,
    required this.template,
    this.child,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final Size pageSize = template.pageSize;

    return Container(
      width: pageSize.width,
      height: pageSize.height,
      decoration: BoxDecoration(
        color: template.backgroundColor,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(31),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: CustomPaint(
          size: pageSize,
          painter: PaperPainter(template: template),
          child: child,
        ),
      ),
    );
  }
}
