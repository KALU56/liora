import 'dart:async';

import '../../../canvas/domain/models/writing_tool.dart';
import '../mappers/note_snapshot_codec.dart';
import '../../domain/models/note_model.dart';
import '../../domain/models/note_page.dart';
import '../../domain/repositories/notes_repository.dart';
import 'note_storage.dart';

/// In-memory note collection with a serialized, device-backed snapshot.
///
/// Mutations remain synchronous for the UI, while their snapshots are written
/// in order in the background. This means a later edit cannot be overwritten
/// by an earlier, slower storage write.
class NoteRepository implements NotesRepository {
  NoteRepository({NoteStorage? storage})
    : _storage = storage ?? SharedPreferencesNoteStorage();

  final NoteStorage _storage;
  final NoteSnapshotCodec _codec = const NoteSnapshotCodec();
  final List<NoteModel> _notes = [];
  Future<void> _writeQueue = Future.value();
  int _idCounter = 0;
  bool _isInitialized = false;

  List<NoteModel> get notes => List.unmodifiable(_notes);
  bool get isInitialized => _isInitialized;

  /// Restores the latest valid snapshot once during application start-up.
  /// A malformed or old snapshot is ignored rather than preventing launch.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final rawNotes = await _storage.read();
      if (rawNotes != null && rawNotes.isNotEmpty) {
        _notes
          ..clear()
          ..addAll(_codec.decode(rawNotes));
      }
    } on FormatException {
      // Leave the current collection intact if an interrupted write is corrupt.
    } finally {
      _isInitialized = true;
    }
  }

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
    _schedulePersistence();
    return newNote;
  }

  bool updateNote(NoteModel updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote.copyWith(modifiedDate: DateTime.now());
      _schedulePersistence();
      return true;
    }
    return false;
  }

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
      _schedulePersistence();
      return true;
    }
    return false;
  }

  bool deleteNote(String id) {
    final initialLength = _notes.length;
    _notes.removeWhere((note) => note.id == id);
    final didDelete = _notes.length < initialLength;
    if (didDelete) _schedulePersistence();
    return didDelete;
  }

  List<NoteModel> searchNotes(String query) {
    if (query.trim().isEmpty) return List.unmodifiable(_notes);
    final cleanQuery = query.trim().toLowerCase();
    return _notes
        .where((note) => note.title.toLowerCase().contains(cleanQuery))
        .toList();
  }

  NoteModel? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearAll() {
    _notes.clear();
    _schedulePersistence();
  }

  /// Allows lifecycle handlers and tests to wait until all queued writes finish.
  Future<void> flush() => _writeQueue;

  Future<void> clearPersistedData() async {
    _notes.clear();
    await _writeQueue;
    await _storage.clear();
  }

  void _schedulePersistence() {
    final snapshot = _codec.encode(_notes);
    _writeQueue = _writeQueue
        .catchError((_) {
          // A future mutation should still be able to recover from a failed write.
        })
        .then((_) => _storage.write(snapshot));
  }
}

/// The repository shared by app routes. It is restored before [runApp] in main.
final NoteRepository appNoteRepository = NoteRepository();
