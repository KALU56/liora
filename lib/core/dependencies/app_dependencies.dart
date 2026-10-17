import 'package:flutter/material.dart';

import '../theme/accent_color_storage.dart';
import '../theme/accent_palette.dart';
import '../../features/notes/application/notes_use_cases.dart';
import '../../features/notes/data/database/note_database.dart';
import '../../features/notes/data/note_attachment_storage.dart';
import '../../features/notes/data/repositories/note_repository.dart';
import '../../features/notes/data/repositories/note_storage.dart';
import '../../features/notes/data/repositories/sqlite_note_storage.dart';
import '../../features/paper/application/paper_use_cases.dart';

/// Composition root for concrete application dependencies.
class AppDependencies {
  factory AppDependencies({
    NoteRepository? noteRepository,
    NoteStorage? noteStorage,
    NoteDatabase? noteDatabase,
    NoteAttachmentStorage? noteAttachmentStorage,
    AccentColorStorage? accentColorStorage,
  }) {
    final database = noteDatabase ?? NoteDatabase();
    return AppDependencies._(
      noteDatabase: database,
      noteRepository:
          noteRepository ??
          NoteRepository(
            storage: noteStorage ?? SqliteNoteStorage(database: database),
          ),
      noteAttachmentStorage:
          noteAttachmentStorage ?? NoteAttachmentStorage(database: database),
      accentColorStorage:
          accentColorStorage ?? SharedPreferencesAccentColorStorage(),
      usesProvidedRepository: noteRepository != null,
      usesProvidedAccentStorage: accentColorStorage != null,
    );
  }

  AppDependencies._({
    required this.noteDatabase,
    required this.noteRepository,
    required this.noteAttachmentStorage,
    required this.accentColorStorage,
    required this._usesProvidedRepository,
    required this._usesProvidedAccentStorage,
  });

  final NoteDatabase noteDatabase;
  final NoteRepository noteRepository;
  final NoteAttachmentStorage noteAttachmentStorage;
  final AccentColorStorage accentColorStorage;
  final bool _usesProvidedRepository;
  final bool _usesProvidedAccentStorage;

  Color cachedAccentColor = AccentPalette.defaultColor;

  late final NotesUseCases notes = NotesUseCases(noteRepository);
  final PaperUseCases paper = const PaperUseCases();

  Future<void> initialize() async {
    if (!_usesProvidedRepository) {
      await noteRepository.initialize();
    }
    if (!_usesProvidedAccentStorage) {
      final savedAccent = await accentColorStorage.loadAccentColor();
      if (savedAccent != null) {
        cachedAccentColor = savedAccent;
      }
    }
  }
}

final AppDependencies appDependencies = AppDependencies(
  noteDatabase: appNoteDatabase,
  noteRepository: appNoteRepository,
);
