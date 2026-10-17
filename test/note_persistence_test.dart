import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:notability_clone/features/canvas/domain/models/argb_color.dart';
import 'package:notability_clone/features/canvas/domain/models/point_2d.dart';
import 'package:notability_clone/features/canvas/domain/models/stroke.dart';
import 'package:notability_clone/features/canvas/domain/models/touch_point.dart';
import 'package:notability_clone/features/canvas/domain/models/writing_tool.dart';
import 'package:notability_clone/features/notes/data/repositories/note_repository.dart';
import 'package:notability_clone/features/notes/data/repositories/note_storage.dart';
import 'package:notability_clone/features/notes/data/repositories/sqlite_note_storage.dart';
import 'package:notability_clone/features/notes/data/database/note_database.dart';
import 'package:notability_clone/features/notes/data/note_attachment_storage.dart';
import 'package:notability_clone/features/notes/data/mappers/note_snapshot_codec.dart';
import 'package:notability_clone/features/notes/domain/models/note_page.dart';
import 'package:notability_clone/features/notes/domain/models/note_text_block.dart';
import 'package:notability_clone/features/paper/domain/models/paper_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryNoteStorage implements NoteStorage {
  final Map<String, (String, int)> values = {};
  bool failNextWrite = false;

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<List<String>> readNotes() async {
    final entries = values.values.toList()
      ..sort((first, second) => first.$2.compareTo(second.$2));
    return entries.map((entry) => entry.$1).toList();
  }

  @override
  Future<void> writeNote(String id, String value, int sortOrder) async {
    if (failNextWrite) {
      failNextWrite = false;
      throw StateError('Test write failure');
    }
    if (!values.containsKey(id)) {
      for (final entry in values.entries.toList()) {
        if (entry.value.$2 >= sortOrder) {
          values[entry.key] = (entry.value.$1, entry.value.$2 + 1);
        }
      }
    }
    values[id] = (value, sortOrder);
  }

  @override
  Future<void> deleteNote(String id) async => values.remove(id);
}

class _MemoryLegacySnapshotStorage implements LegacyNoteSnapshotStorage {
  _MemoryLegacySnapshotStorage(this.value);

  String? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<String?> read() async => value;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('a later save recovers after storage reports a write failure', () async {
    final storage = _MemoryNoteStorage()..failNextWrite = true;
    final repository = NoteRepository(storage: storage);
    repository.createNote(title: 'First write fails');
    await expectLater(repository.flush(), throwsA(isA<StateError>()));

    repository.createNote(title: 'Recovered write');
    await repository.flush();
    final restored = NoteRepository(storage: storage);
    await restored.initialize();

    expect(restored.notes.map((note) => note.title), [
      'Recovered write',
      'First write fails',
    ]);
  });

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
          textItems: const ['Lecture notes'],
          textBlocks: const [
            NoteTextBlock(
              text: 'Lecture notes',
              fontFamily: 'serif',
              fontSize: 24,
              bold: true,
              italic: true,
              alignment: TextAlign.center,
              colorValue: 0xFF486581,
              x: 80,
              y: 120,
            ),
          ],
          attachments: const ['/documents/audio-note.m4a'],
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
            color: ArgbColor(0xFFF44336),
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
      expect(restored.pages.first.textItems, ['Lecture notes']);
      expect(restored.pages.first.textBlocks.single.fontFamily, 'serif');
      expect(restored.pages.first.textBlocks.single.fontSize, 24);
      expect(restored.pages.first.textBlocks.single.bold, isTrue);
      expect(restored.pages.first.textBlocks.single.italic, isTrue);
      expect(
        restored.pages.first.textBlocks.single.alignment,
        TextAlign.center,
      );
      expect(restored.pages.first.textBlocks.single.colorValue, 0xFF486581);
      expect(restored.pages.first.textBlocks.single.x, 80);
      expect(restored.pages.first.textBlocks.single.y, 120);
      expect(restored.pages.first.attachments, ['/documents/audio-note.m4a']);
    },
  );

  test(
    'SQLite migrates the existing snapshot and persists separate notes',
    () async {
      final originalRepository = NoteRepository(storage: _MemoryNoteStorage());
      originalRepository.createNote(
        title: 'Restart note',
        pages: [
          NotePage(
            id: 'p1',
            textItems: ['Saved item'],
            attachments: ['/path/to/file.pdf'],
          ),
        ],
      );
      final legacyStorage = _MemoryLegacySnapshotStorage(
        const NoteSnapshotCodec().encode(originalRepository.notes),
      );
      final storage = SqliteNoteStorage(
        database: NoteDatabase(NativeDatabase.memory()),
        legacyStorage: legacyStorage,
      );
      addTearDown(storage.close);

      final repository = NoteRepository(storage: storage);
      await repository.initialize();
      expect(repository.notes.single.title, 'Restart note');
      expect(legacyStorage.value, isNull);

      repository.createNote(title: 'Newer note');
      await repository.flush();
      final restoredRepository = NoteRepository(storage: storage);
      await restoredRepository.initialize();

      expect(restoredRepository.notes.map((note) => note.title), [
        'Newer note',
        'Restart note',
      ]);
      expect(restoredRepository.notes.last.pages.first.textItems, [
        'Saved item',
      ]);
      expect(restoredRepository.notes.last.pages.first.attachments, [
        '/path/to/file.pdf',
      ]);
    },
  );

  test('legacy attachment files migrate into SQLite blobs', () async {
    final directory = await Directory.systemTemp.createTemp('papernote-file-');
    final legacyFile = await File('${directory.path}/photo.png')
        .writeAsBytes([4, 5, 6]);
    final database = NoteDatabase(NativeDatabase.memory());
    final attachments = NoteAttachmentStorage(database: database);
    final note = NoteRepository(storage: _MemoryNoteStorage()).createNote(
      title: 'Legacy attachment',
      pages: [
        NotePage(id: 'legacy-page', attachments: [legacyFile.path]),
      ],
    );
    final storage = SqliteNoteStorage(
      database: database,
      attachmentStorage: attachments,
      legacyStorage: _MemoryLegacySnapshotStorage(
        const NoteSnapshotCodec().encode([note]),
      ),
    );
    addTearDown(() async {
      await storage.close();
      await directory.delete(recursive: true);
    });

    final saved = await storage.readNotes();
    final migrated = const NoteSnapshotCodec().decodeNote(saved.single);
    final reference = migrated.pages.single.attachments.single;

    expect(reference, startsWith('attachment:'));
    expect((await attachments.load(reference))?.bytes, [4, 5, 6]);
    expect(await legacyFile.exists(), isTrue);
  });

  test(
    'existing SQLite notes migrate legacy attachment paths on load',
    () async {
      final directory = await Directory.systemTemp.createTemp('papernote-row-');
      final legacyFile = await File('${directory.path}/existing.pdf')
          .writeAsBytes([7, 8]);
      final database = NoteDatabase(NativeDatabase.memory());
      final attachments = NoteAttachmentStorage(database: database);
      final note = NoteRepository(storage: _MemoryNoteStorage()).createNote(
        title: 'SQLite legacy attachment',
        pages: [
          NotePage(id: 'existing-page', attachments: [legacyFile.path]),
        ],
      );
      await database
          .into(database.storedNotes)
          .insert(
            StoredNotesCompanion.insert(
              id: note.id,
              value: const NoteSnapshotCodec().encodeNote(note),
              sortOrder: 0,
            ),
          );
      final storage = SqliteNoteStorage(
        database: database,
        attachmentStorage: attachments,
        legacyStorage: _MemoryLegacySnapshotStorage(null),
      );
      addTearDown(() async {
        await storage.close();
        await directory.delete(recursive: true);
      });

      final saved = await storage.readNotes();
      final migrated = const NoteSnapshotCodec().decodeNote(saved.single);
      final reference = migrated.pages.single.attachments.single;

      expect(reference, startsWith('attachment:'));
      expect((await attachments.load(reference))?.bytes, [7, 8]);
    },
  );

  test('trashed notes survive SQLite restart and can be restored', () async {
    final directory = await Directory.systemTemp.createTemp('papernote-db-');
    final databaseFile = File('${directory.path}/notes.sqlite');
    final storage = SqliteNoteStorage(
      database: NoteDatabase(NativeDatabase(databaseFile)),
    );
    final repository = NoteRepository(storage: storage);
    final note = repository.createNote(title: 'Recoverable note');
    repository.deleteNote(note.id);
    await repository.flush();
    await storage.close();

    final restartedStorage = SqliteNoteStorage(
      database: NoteDatabase(NativeDatabase(databaseFile)),
    );
    addTearDown(() async {
      await restartedStorage.close();
      await directory.delete(recursive: true);
    });
    final restoredRepository = NoteRepository(storage: restartedStorage);
    await restoredRepository.initialize();

    expect(restoredRepository.notes, isEmpty);
    expect(restoredRepository.trashedNotes.single.id, note.id);
    expect(restoredRepository.restoreNote(note.id), isTrue);
    await restoredRepository.flush();
    expect(restoredRepository.notes.single.title, 'Recoverable note');
  });
}
