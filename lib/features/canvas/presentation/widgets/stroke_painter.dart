import 'package:flutter/material.dart';

import '../../domain/models/stroke.dart';
import '../../domain/models/writing_tool.dart';

/// CustomPainter that renders independent stroke objects with support for
/// Pen, Pencil, Highlighter, and Eraser visual styles.
class StrokePainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final Offset? eraserPosition;
  final double eraserRadius;

  const StrokePainter({
    required this.strokes,
    this.activeStroke,
    this.eraserPosition,
    this.eraserRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }

    if (eraserPosition != null) {
      _drawEraserIndicator(canvas, eraserPosition!, eraserRadius);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final path = stroke.toPath();

    switch (stroke.toolType) {
      case WritingToolType.pencil:
        _drawPencilStroke(canvas, path, stroke);
        break;

      case WritingToolType.highlighter:
        _drawHighlighterStroke(canvas, path, stroke);
        break;

      case WritingToolType.eraser:
        // Eraser strokes do not draw permanent lines
        break;

      case WritingToolType.pen:
      default:
        _drawPenStroke(canvas, path, stroke);
        break;
    }
  }

  void _drawPenStroke(Canvas canvas, Path path, Stroke stroke) {
    final paint = Paint()
      ..color = stroke.color.withOpacity(stroke.opacity.clamp(0.0, 1.0))
      ..strokeWidth = stroke.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  void _drawPencilStroke(Canvas canvas, Path path, Stroke stroke) {
    // Pencil textured stroke rendering with graphite opacity and dual pass
    final baseOpacity = (stroke.opacity * 0.75).clamp(0.0, 1.0);

    final mainPaint = Paint()
      ..color = stroke.color.withOpacity(baseOpacity)
      ..strokeWidth = stroke.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(path, mainPaint);

    // Subtle texture pass
    final texturePaint = Paint()
      ..color = stroke.color.withOpacity((baseOpacity * 0.3).clamp(0.0, 1.0))
      ..strokeWidth = stroke.strokeWidth * 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.save();
    canvas.translate(0.4, 0.4);
    canvas.drawPath(path, texturePaint);
    canvas.restore();
  }

  void _drawHighlighterStroke(Canvas canvas, Path path, Stroke stroke) {
    // Semi-transparent highlight rendering that preserves text readability
    final highlightOpacity = (stroke.opacity * 0.4).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = stroke.color.withOpacity(highlightOpacity)
      ..strokeWidth = stroke.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..blendMode = BlendMode.srcOver
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  void _drawEraserIndicator(Canvas canvas, Offset center, double radius) {
    final fillPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.activeStroke != activeStroke ||
        oldDelegate.eraserPosition != eraserPosition ||
        oldDelegate.eraserRadius != eraserRadius;
  }
}
