import 'package:flutter/material.dart';

import '../../../canvas/domain/models/stroke.dart';
import '../../../../core/domain/value_objects/argb_color.dart';
import '../../../canvas/domain/models/touch_point.dart';
import '../../../canvas/domain/models/writing_tool.dart';
import '../../../canvas/domain/models/point_2d.dart';
import '../../../paper/domain/models/paper_template.dart';
import '../../domain/models/note_model.dart';
import '../../domain/models/note_page.dart';

/// Maps domain objects to the persisted data representation.
class NoteModelMapper {
  const NoteModelMapper();

  Map<String, dynamic> noteToMap(NoteModel note) {
    return {
      'id': note.id,
      'title': note.title,
      'pageCount': note.pageCount,
      'pages': note.pages.map(pageToMap).toList(),
      'modifiedDate': note.modifiedDate.toIso8601String(),
      'createdDate': note.createdDate.toIso8601String(),
      'thumbnailPath': note.thumbnailPath,
    };
  }

  NoteModel noteFromMap(Map<String, dynamic> map) {
    final rawPages = map['pages'];
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      pageCount: (map['pageCount'] as num?)?.toInt() ?? 1,
      pages: rawPages is List
          ? rawPages
                .whereType<Map>()
                .map((page) => pageFromMap(Map<String, dynamic>.from(page)))
                .toList()
          : const [],
      modifiedDate: DateTime.parse(map['modifiedDate'] as String),
      createdDate: DateTime.parse(map['createdDate'] as String),
      thumbnailPath: map['thumbnailPath'] as String?,
    );
  }

  Map<String, dynamic> pageToMap(NotePage page) {
    return {
      'id': page.id,
      'paperTemplate': paperToMap(page.paperTemplate),
      'strokes': page.strokes.map(strokeToMap).toList(),
      'toolConfig': toolToMap(page.toolConfig),
    };
  }

  NotePage pageFromMap(Map<String, dynamic> map) {
    final rawStrokes = map['strokes'];
    return NotePage(
      id: map['id'] as String? ?? 'page',
      paperTemplate: map['paperTemplate'] is Map
          ? paperFromMap(Map<String, dynamic>.from(map['paperTemplate'] as Map))
          : const PaperTemplate(),
      strokes: rawStrokes is List
          ? rawStrokes
                .whereType<Map>()
                .map(
                  (stroke) => strokeFromMap(Map<String, dynamic>.from(stroke)),
                )
                .toList()
          : const [],
      toolConfig: map['toolConfig'] is Map
          ? toolFromMap(Map<String, dynamic>.from(map['toolConfig'] as Map))
          : const ToolConfig(),
    );
  }

  Map<String, dynamic> strokeToMap(Stroke stroke) {
    return {
      'id': stroke.id,
      'points': stroke.points.map(pointToMap).toList(),
      'color': stroke.color.value,
      'strokeWidth': stroke.strokeWidth,
      'toolType': stroke.toolType.name,
      'opacity': stroke.opacity,
      'isComplete': stroke.isComplete,
    };
  }

  Stroke strokeFromMap(Map<String, dynamic> map) {
    final rawPoints = map['points'];
    return Stroke(
      id: map['id'] as String? ?? '',
      points: rawPoints is List
          ? rawPoints
                .whereType<Map>()
                .map((point) => pointFromMap(Map<String, dynamic>.from(point)))
                .toList()
          : const [],
      color: ArgbColor((map['color'] as num?)?.toInt() ?? 0xFF000000),
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      toolType: WritingToolType.values.firstWhere(
        (type) => type.name == map['toolType'],
        orElse: () => WritingToolType.pen,
      ),
      opacity: (map['opacity'] as num?)?.toDouble() ?? 1.0,
      isComplete: map['isComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> pointToMap(TouchPoint point) {
    return {
      'dx': point.position.x,
      'dy': point.position.y,
      'pressure': point.pressure,
      'timestamp': point.timestamp.toIso8601String(),
    };
  }

  TouchPoint pointFromMap(Map<String, dynamic> map) {
    return TouchPoint(
      position: Point2D(
        (map['dx'] as num?)?.toDouble() ?? 0.0,
        (map['dy'] as num?)?.toDouble() ?? 0.0,
      ),
      pressure: (map['pressure'] as num?)?.toDouble() ?? 1.0,
      timestamp: map['timestamp'] is String
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toolToMap(ToolConfig tool) {
    return {
      'toolType': tool.toolType.name,
      'color': tool.color.value,
      'strokeWidth': tool.strokeWidth,
      'opacity': tool.opacity,
      'eraserSize': tool.eraserSize.name,
    };
  }

  ToolConfig toolFromMap(Map<String, dynamic> map) {
    return ToolConfig(
      toolType: WritingToolType.values.firstWhere(
        (type) => type.name == map['toolType'],
        orElse: () => WritingToolType.pen,
      ),
      color: ArgbColor((map['color'] as num?)?.toInt() ?? 0xFF000000),
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      opacity: (map['opacity'] as num?)?.toDouble() ?? 1.0,
      eraserSize: EraserSize.values.firstWhere(
        (size) => size.name == map['eraserSize'],
        orElse: () => EraserSize.small,
      ),
    );
  }

  Map<String, dynamic> paperToMap(PaperTemplate paper) {
    return {
      'pattern': paper.pattern.name,
      'backgroundColor': paper.backgroundColor.value,
      'orientation': paper.orientation.name,
      'lineSpacing': paper.lineSpacing,
      'gridSize': paper.gridSize,
      'dotSpacing': paper.dotSpacing,
      'dotRadius': paper.dotRadius,
      'lineColor': paper.lineColor?.value,
      'baseWidth': paper.baseWidth,
      'baseHeight': paper.baseHeight,
    };
  }

  PaperTemplate paperFromMap(Map<String, dynamic> map) {
    return PaperTemplate(
      pattern: PaperPattern.values.firstWhere(
        (pattern) => pattern.name == map['pattern'],
        orElse: () => PaperPattern.blank,
      ),
      backgroundColor: ArgbColor(
        (map['backgroundColor'] as num?)?.toInt() ?? 0xFFFFFFFF,
      ),
      orientation: PageOrientation.values.firstWhere(
        (orientation) => orientation.name == map['orientation'],
        orElse: () => PageOrientation.portrait,
      ),
      lineSpacing: (map['lineSpacing'] as num?)?.toDouble() ?? 32.0,
      gridSize: (map['gridSize'] as num?)?.toDouble() ?? 32.0,
      dotSpacing: (map['dotSpacing'] as num?)?.toDouble() ?? 32.0,
      dotRadius: (map['dotRadius'] as num?)?.toDouble() ?? 1.5,
      lineColor: map['lineColor'] == null
          ? null
          : ArgbColor((map['lineColor'] as num?)?.toInt() ?? 0x33000000),
      baseWidth: (map['baseWidth'] as num?)?.toDouble() ?? 612.0,
      baseHeight: (map['baseHeight'] as num?)?.toDouble() ?? 792.0,
    );
  }
}

class ColorValue {
  const ColorValue._();

  static Color fromArgb(Object? value) {
    return Color((value as num?)?.toInt() ?? Colors.black.toARGB32());
  }
}
