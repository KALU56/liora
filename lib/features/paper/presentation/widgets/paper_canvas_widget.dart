import 'package:flutter/material.dart';

import '../../domain/models/paper_template.dart';
import 'paper_painter.dart';

/// Interactive Page Container widget that renders a single note page with a given [PaperTemplate].
/// Maintains page bounds, shadows, and paints background guidelines/dots attached to page coordinates.
class PaperCanvasWidget extends StatelessWidget {
  final PaperTemplate template;
  final Widget? child;
  final bool showShadow;
  final Size? canvasSize;

  const PaperCanvasWidget({
    super.key,
    required this.template,
    this.child,
    this.showShadow = true,
    this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    final Size pageSize = canvasSize ?? Size(template.width, template.height);

    return Container(
      width: pageSize.width,
      height: pageSize.height,
      decoration: BoxDecoration(
        color: Color(template.backgroundColor.value),
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
        borderRadius: BorderRadius.zero,
        child: CustomPaint(
          size: Size(pageSize.width, pageSize.height),
          painter: PaperPainter(template: template),
          child: child,
        ),
      ),
    );
  }
}
