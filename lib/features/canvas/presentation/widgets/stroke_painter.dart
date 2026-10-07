import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/stroke.dart';
import '../../domain/models/writing_tool.dart';
import 'ruler_geometry.dart';
import 'stroke_path_builder.dart';

/// CustomPainter that renders independent stroke objects with support for
/// Pen, Pencil, Highlighter, and Eraser visual styles.
class StrokePainter extends CustomPainter {
  static const _pathBuilder = StrokePathBuilder();
  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final Offset? eraserPosition;
  final double eraserRadius;
  final RulerGeometry? ruler;
  final Color rulerColor;

  const StrokePainter({
    required this.strokes,
    this.activeStroke,
    this.eraserPosition,
    this.eraserRadius = 16.0,
    this.ruler,
    this.rulerColor = const Color(0xFF78856A),
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

    if (ruler != null) _drawRuler(canvas, ruler!);
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    if (stroke.shapeType != null && stroke.points.length > 1) {
      _drawShape(canvas, stroke);
      return;
    }

    final path = _pathBuilder.build(stroke);

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
        _drawPenStroke(canvas, path, stroke);
        break;
      case WritingToolType.shape:
      case WritingToolType.ruler:
        _drawPenStroke(canvas, path, stroke);
        break;
    }
  }

  void _drawShape(Canvas canvas, Stroke stroke) {
    final start = stroke.points.first.position;
    final end = stroke.points.last.position;
    var rect = Rect.fromPoints(Offset(start.x, start.y), Offset(end.x, end.y));
    final paint = Paint()
      ..color = Color(stroke.color.value).withValues(alpha: stroke.opacity)
      ..strokeWidth = stroke.strokeWidth
      ..style = stroke.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    switch (stroke.shapeType!) {
      case ShapeType.line:
        canvas.drawLine(Offset(start.x, start.y), Offset(end.x, end.y), paint);
      case ShapeType.rectangle:
        _drawRectShape(canvas, rect, paint, stroke.filled);
      case ShapeType.square:
        final side = math.min(rect.width, rect.height);
        rect = Rect.fromLTRB(
          rect.left,
          rect.top,
          rect.left + side,
          rect.top + side,
        );
        _drawRectShape(canvas, rect, paint, stroke.filled);
      case ShapeType.oval:
        _drawOvalShape(canvas, rect, paint, stroke.filled);
      case ShapeType.circle:
        final side = math.min(rect.width, rect.height);
        final circle = Rect.fromCenter(
          center: rect.center,
          width: side,
          height: side,
        );
        _drawOvalShape(canvas, circle, paint, stroke.filled);
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
        _drawClosedShape(canvas, path, paint, stroke.filled);
      case ShapeType.arrow:
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(Offset(start.x, start.y), Offset(end.x, end.y), paint);
        final direction = Offset(end.x - start.x, end.y - start.y);
        final angle = direction.direction;
        final wingLength = (stroke.strokeWidth * 4).clamp(10.0, 22.0);
        final wing1 = Offset(
          end.x - wingLength * math.cos(angle - 0.45),
          end.y - wingLength * math.sin(angle - 0.45),
        );
        final wing2 = Offset(
          end.x - wingLength * math.cos(angle + 0.45),
          end.y - wingLength * math.sin(angle + 0.45),
        );
        canvas.drawLine(Offset(end.x, end.y), wing1, paint);
        canvas.drawLine(Offset(end.x, end.y), wing2, paint);
    }
  }

  void _drawRectShape(Canvas canvas, Rect rect, Paint paint, bool filled) {
    if (filled) {
      canvas.drawRect(rect, paint);
      paint.style = PaintingStyle.stroke;
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  void _drawOvalShape(Canvas canvas, Rect rect, Paint paint, bool filled) {
    if (filled) {
      canvas.drawOval(rect, paint);
      paint.style = PaintingStyle.stroke;
      canvas.drawOval(rect, paint);
    } else {
      canvas.drawOval(rect, paint);
    }
  }

  void _drawClosedShape(Canvas canvas, Path path, Paint paint, bool filled) {
    if (filled) {
      canvas.drawPath(path, paint);
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawRuler(Canvas canvas, RulerGeometry ruler) {
    canvas.save();
    canvas.translate(ruler.center.dx, ruler.center.dy);
    canvas.rotate(ruler.angle);

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: ruler.length,
        height: ruler.thickness,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = rulerColor.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = rulerColor.withValues(alpha: 0.9)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    final tickPaint = Paint()
      ..color = rulerColor.withValues(alpha: 0.78)
      ..strokeWidth = 1;
    final left = -ruler.length / 2;
    final top = -ruler.thickness / 2;
    for (var mark = 0; mark <= ruler.length ~/ 10; mark++) {
      final x = left + mark * 10;
      final tickHeight = mark % 5 == 0 ? 12.0 : 6.0;
      canvas.drawLine(Offset(x, top), Offset(x, top + tickHeight), tickPaint);
    }
    canvas.drawLine(
      Offset(left, top),
      Offset(ruler.length / 2, top),
      Paint()
        ..color = rulerColor
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(ruler.length / 2, 0),
      Offset(ruler.length / 2 + 20, 0),
      tickPaint,
    );
    canvas.drawCircle(
      Offset(ruler.length / 2 + 20, 0),
      11,
      Paint()..color = rulerColor.withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      Offset(ruler.length / 2 + 20, 0),
      11,
      Paint()
        ..color = rulerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  void _drawPenStroke(Canvas canvas, Path path, Stroke stroke) {
    final paint = Paint()
      ..color = Color(stroke.color.value)
          .withValues(alpha: stroke.opacity.clamp(0.0, 1.0))
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
      ..color = Color(stroke.color.value).withValues(alpha: baseOpacity)
      ..strokeWidth = stroke.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(path, mainPaint);

    // Subtle texture pass
    final texturePaint = Paint()
      ..color = Color(stroke.color.value)
          .withValues(alpha: (baseOpacity * 0.3).clamp(0.0, 1.0))
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
      ..color = Color(stroke.color.value).withValues(alpha: highlightOpacity)
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
      ..color = Colors.grey.withValues(alpha: 0.2)
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
        oldDelegate.eraserRadius != eraserRadius ||
        oldDelegate.ruler != ruler ||
        oldDelegate.rulerColor != rulerColor;
  }
}
