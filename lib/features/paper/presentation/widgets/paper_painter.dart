import 'package:flutter/material.dart';

import '../../domain/models/paper_template.dart';

/// CustomPainter responsible for rendering page background colors,
/// ruled lines, grid cells, and dotted patterns tied to page coordinates.
class PaperPainter extends CustomPainter {
  final PaperTemplate template;

  const PaperPainter({required this.template});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill solid page background color
    final Paint bgPaint = Paint()
      ..color = template.backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Render background pattern overlay
    switch (template.pattern) {
      case PaperPattern.blank:
        // Plain background, no lines or dots rendered
        break;

      case PaperPattern.ruled:
        _drawRuledPattern(canvas, size);
        break;

      case PaperPattern.grid:
        _drawGridPattern(canvas, size);
        break;

      case PaperPattern.dotted:
        _drawDottedPattern(canvas, size);
        break;
    }
  }

  void _drawRuledPattern(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = template.effectivePatternColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw horizontal guidelines attached to page Y coordinates
    final double spacing = template.lineSpacing;
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Optional subtle left margin line for traditional notebook feel
    if (size.width > 100) {
      final Paint marginPaint = Paint()
        ..color = template.backgroundColor.computeLuminance() < 0.5
            ? const Color(0x33FF5252)
            : const Color(0x44FF5252)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      const double marginX = 48.0;
      canvas.drawLine(
        const Offset(marginX, 0),
        Offset(marginX, size.height),
        marginPaint,
      );
    }
  }

  void _drawGridPattern(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = template.effectivePatternColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final double grid = template.gridSize;

    // Draw horizontal lines fixed to page Y coordinates
    for (double y = grid; y < size.height; y += grid) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw vertical lines fixed to page X coordinates
    for (double x = grid; x < size.width; x += grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  void _drawDottedPattern(Canvas canvas, Size size) {
    final Paint dotPaint = Paint()
      ..color = template.effectivePatternColor
      ..style = PaintingStyle.fill;

    final double spacing = template.dotSpacing;
    final double radius = template.dotRadius;

    // Draw grid of evenly spaced dots attached to page (X, Y) coordinates
    for (double y = spacing; y < size.height; y += spacing) {
      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PaperPainter oldDelegate) {
    return oldDelegate.template != template;
  }
}
