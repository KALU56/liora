import 'dart:async';

import '../../../canvas/domain/models/writing_tool.dart';
import '../database/note_database.dart';
import '../mappers/note_snapshot_codec.dart';
import '../../domain/models/note_model.dart';
import '../../domain/models/note_page.dart';
import '../../domain/repositories/notes_repository.dart';
import 'sqlite_note_storage.dart';
import 'note_storage.dart';

/// In-memory note collection with a serialized, device-backed snapshot.
///
/// Mutations remain synchronous for the UI, while their snapshots are written
/// in order in the background. This means a later edit cannot be overwritten
/// by an earlier, slower storage write.
class NoteRepository implements NotesRepository {
  NoteRepository({NoteStorage? storage})
    : _storage = storage ?? SqliteNoteStorage();

  final NoteStorage _storage;
  final NoteSnapshotCodec _codec = const NoteSnapshotCodec();
  final List<NoteModel> _notes = [];
  final Map<String, (String, int)> _pendingNoteWrites = {};
  final Set<String> _pendingDeletes = {};
  Future<void> _writeQueue = Future.value();
  int _idCounter = 0;
  bool _isInitialized = false;

  @override
  List<NoteModel> get notes =>
      List.unmodifiable(_notes.where((note) => !note.isTrashed));
  @override
  List<NoteModel> get trashedNotes =>
      List.unmodifiable(_notes.where((note) => note.isTrashed));
  bool get isInitialized => _isInitialized;

  /// Restores the latest valid snapshot once during application start-up.
  /// A malformed or old snapshot is ignored rather than preventing launch.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final savedNotes = await _storage.readNotes();
      _notes.clear();
      for (final value in savedNotes) {
        try {
          _notes.add(_codec.decodeNote(value));
        } on FormatException {
          continue;
        }
      }
    } finally {
      _isInitialized = true;
    }
  }

  @override
  NoteModel createNote({String? title, List<NotePage>? pages}) {
    final now = DateTime.now();
    _idCounter++;
    final defaultTitle = (title == null || title.trim().isEmpty)
        ? 'Untitled Note'
        : title.trim();
    final id = '${now.microsecondsSinceEpoch}_$_idCounter';
    final notePages =
        pages ??
        [NotePage(id: '${id}_page_1', toolConfig: ToolConfig.defaultPen)];

    final newNote = NoteModel(
      id: id,
      title: defaultTitle,
      pages: notePages,
      modifiedDate: now,
      createdDate: now,
    );

    _notes.insert(0, newNote);
    _schedulePersistence(newNote, 0);
    return newNote;
  }

  @override
  bool updateNote(NoteModel updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      final updated = updatedNote.copyWith(modifiedDate: DateTime.now());
      _notes[index] = updated;
      _schedulePersistence(updated, index);
      return true;
    }
    return false;
  }

  @override
  bool renameNote(String id, String newTitle) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final cleanTitle = newTitle.trim().isEmpty
          ? 'Untitled Note'
          : newTitle.trim();
      _notes[index] = _notes[index].copyWith(
        title: cleanTitle,
        modifiedDate: DateTime.now(),
      );
      _schedulePersistence(_notes[index], index);
      return true;
    }
    return false;
  }

  @override
  bool deleteNote(String id) {
    final index = _notes.indexWhere((note) => note.id == id && !note.isTrashed);
    if (index < 0) return false;
    final trashedNote = _notes[index].copyWith(isTrashed: true);
    _notes[index] = trashedNote;
    _schedulePersistence(trashedNote, index);
    return true;
  }

  @override
  bool restoreNote(String id) {
    final index = _notes.indexWhere((note) => note.id == id && note.isTrashed);
    if (index < 0) return false;
    final restoredNote = _notes[index].copyWith(isTrashed: false);
    _notes[index] = restoredNote;
    _schedulePersistence(restoredNote, index);
    return true;
  }

  @override
  bool permanentlyDeleteNote(String id) {
    final index = _notes.indexWhere((note) => note.id == id && note.isTrashed);
    if (index < 0) return false;
    _notes.removeAt(index);
    _scheduleDelete(id);
    return true;
  }

  @override
  List<NoteModel> searchNotes(String query) {
    final activeNotes = _notes.where((note) => !note.isTrashed);
    if (query.trim().isEmpty) return List.unmodifiable(activeNotes);
    final cleanQuery = query.trim().toLowerCase();
    return activeNotes
        .where((note) => _matchesSearch(note, cleanQuery))
        .toList();
  }

  bool _matchesSearch(NoteModel note, String query) {
    if (note.title.toLowerCase().contains(query)) return true;
    return note.pages.any(
      (page) =>
          page.textBlocks.any(
            (block) => block.text.toLowerCase().contains(query),
          ) ||
          page.attachments.any((path) => path.toLowerCase().contains(query)),
    );
  }

  @override
  NoteModel? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearAll() {
    _notes.clear();
    _pendingNoteWrites.clear();
    _pendingDeletes.clear();
    _writeQueue = _writeQueue.catchError((_) {}).then((_) async {
      await _storage.clear();
    });
  }

  /// Allows lifecycle handlers and tests to wait until all queued writes finish.
  @override
  Future<void> flush() => _writeQueue;

  Future<void> clearPersistedData() async {
    _notes.clear();
    await _writeQueue;
    await _storage.clear();
  }

  void _schedulePersistence(NoteModel note, int sortOrder) {
    _pendingDeletes.remove(note.id);
    _pendingNoteWrites[note.id] = (_codec.encodeNote(note), sortOrder);
    _queuePendingWrites();
  }

  void _scheduleDelete(String id) {
    _pendingNoteWrites.remove(id);
    _pendingDeletes.add(id);
    _queuePendingWrites();
  }

  void _queuePendingWrites() {
    _writeQueue = _writeQueue.catchError((_) {}).then((_) async {
      for (final id in _pendingDeletes.toList()) {
        await _storage.deleteNote(id);
        _pendingDeletes.remove(id);
      }
      for (final entry in _pendingNoteWrites.entries.toList()) {
        await _storage.writeNote(entry.key, entry.value.$1, entry.value.$2);
        if (_pendingNoteWrites[entry.key] == entry.value) {
          _pendingNoteWrites.remove(entry.key);
        }
      }
    });
  }
}

/// The repository shared by app routes. It is restored before [runApp] in main.
final NoteDatabase appNoteDatabase = NoteDatabase();
final NoteRepository appNoteRepository = NoteRepository(
  storage: SqliteNoteStorage(database: appNoteDatabase),
);
