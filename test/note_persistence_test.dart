import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/canvas/domain/models/argb_color.dart';
import 'package:notability_clone/features/canvas/domain/models/point_2d.dart';
import 'package:notability_clone/features/canvas/domain/models/stroke.dart';
import 'package:notability_clone/features/canvas/domain/models/touch_point.dart';
import 'package:notability_clone/features/canvas/domain/models/writing_tool.dart';
import 'package:notability_clone/features/notes/data/repositories/note_repository.dart';
import 'package:notability_clone/features/notes/data/repositories/note_storage.dart';
import 'package:notability_clone/features/notes/domain/models/note_page.dart';
import 'package:notability_clone/features/paper/domain/models/paper_template.dart';

class _MemoryNoteStorage implements NoteStorage {
  String? value;

  @override
  Future<void> clear() async {
    value = null;
  }

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String newValue) async {
    value = newValue;
  }
}

void main() {
  test(
    'restores every page, stroke property, and active tool configuration',
    () async {
      final storage = _MemoryNoteStorage();
      final repository = NoteRepository(storage: storage);
      final timestamp = DateTime.utc(2026, 9, 9, 10, 30);
      final firstStroke = Stroke(
        id: 'first-stroke',
        color: const ArgbColor(0xAA3366FF),
        strokeWidth: 7.25,
        toolType: WritingToolType.highlighter,
        opacity: 0.35,
        isComplete: true,
        points: [
          TouchPoint(
            position: const Point2D(12.5, 24.75),
            pressure: 0.6,
            timestamp: timestamp,
          ),
        ],
      );
      final pages = [
        NotePage(
          id: 'page-1',
          paperTemplate: const PaperTemplate(pattern: PaperPattern.ruled),
          strokes: [firstStroke],
          toolConfig: const ToolConfig(
            toolType: WritingToolType.highlighter,
            color: ArgbColor(0xAA3366FF),
            strokeWidth: 7.25,
            opacity: 0.35,
          ),
        ),
        NotePage(
          id: 'page-2',
          strokes: [
            Stroke(
              id: 'second-stroke',
              color: const ArgbColor(0xFFF44336),
              strokeWidth: 2,
              toolType: WritingToolType.pencil,
              opacity: 0.8,
              isComplete: true,
              points: [
                TouchPoint(
                  position: const Point2D(100, 200),
                  timestamp: timestamp,
                ),
              ],
            ),
          ],
          toolConfig: const ToolConfig(
            toolType: WritingToolType.pencil,
            color: const ArgbColor(0xFFF44336),
            strokeWidth: 2,
            opacity: 0.8,
          ),
        ),
      ];

      final saved = repository.createNote(
        title: 'Persistent note',
        pages: pages,
      );
      await repository.flush();

      final restoredRepository = NoteRepository(storage: storage);
      await restoredRepository.initialize();
      final restored = restoredRepository.getNoteById(saved.id)!;
      final restoredStroke = restored.pages.first.strokes.single;

      expect(restored.pageCount, 2);
      expect(restored.pages.map((page) => page.id), ['page-1', 'page-2']);
      expect(restored.pages[1].strokes.single.id, 'second-stroke');
      expect(restoredStroke.color.value, const Color(0xAA3366FF).toARGB32());
      expect(restoredStroke.strokeWidth, 7.25);
      expect(restoredStroke.opacity, 0.35);
      expect(restoredStroke.toolType, WritingToolType.highlighter);
      expect(restoredStroke.points.single.position, const Point2D(12.5, 24.75));
      expect(restoredStroke.points.single.pressure, 0.6);
      expect(restoredStroke.points.single.timestamp, timestamp);
      expect(
        restored.pages.first.toolConfig.toolType,
        WritingToolType.highlighter,
      );
      expect(restored.pages.first.toolConfig.strokeWidth, 7.25);
      expect(restored.pages.first.toolConfig.opacity, 0.35);
    },
  );
}
