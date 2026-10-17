import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../note_attachment_storage.dart';
import '../../domain/models/note_model.dart';
import '../mappers/note_snapshot_codec.dart';
import '../database/note_database.dart';
import 'note_storage.dart';

/// Reads the old snapshot until it has been safely copied to the database.
abstract class LegacyNoteSnapshotStorage {
  Future<String?> read();
  Future<void> clear();
}

class SharedPreferencesLegacyNoteSnapshotStorage
    implements LegacyNoteSnapshotStorage {
  static const _storageKey = 'papernote.notes.v1';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  @override
  Future<String?> read() async => (await _preferences).getString(_storageKey);

  @override
  Future<void> clear() async {
    await (await _preferences).remove(_storageKey);
  }
}

/// Stores each note separately and migrates the old snapshot after a safe copy.
class SqliteNoteStorage implements NoteStorage {
  SqliteNoteStorage({
    NoteDatabase? database,
    LegacyNoteSnapshotStorage? legacyStorage,
    NoteAttachmentStorage? attachmentStorage,
    this._codec = const NoteSnapshotCodec(),
  }) : _database = database ?? NoteDatabase(),
       _legacyStorage =
           legacyStorage ?? SharedPreferencesLegacyNoteSnapshotStorage() {
    _attachmentStorage =
        attachmentStorage ?? NoteAttachmentStorage(database: _database);
  }

  final NoteDatabase _database;
  final LegacyNoteSnapshotStorage _legacyStorage;
  final NoteSnapshotCodec _codec;
  late final NoteAttachmentStorage _attachmentStorage;

  @override
  Future<List<String>> readNotes() async {
    final rows = await (_database.select(
      _database.storedNotes,
    )..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get();
    if (rows.isNotEmpty) {
      final migratedNotes = <String>[];
      for (final row in rows) {
        try {
          final note = await _attachmentStorage.migrateLegacyReferences(
            _codec.decodeNote(row.value),
          );
          final encoded = _codec.encodeNote(note);
          if (encoded != row.value) {
            await (_database.update(_database.storedNotes)
                  ..where((stored) => stored.id.equals(row.id)))
                .write(StoredNotesCompanion(value: Value(encoded)));
          }
          migratedNotes.add(encoded);
        } on FormatException {
          migratedNotes.add(row.value);
        }
      }
      await _legacyStorage.clear();
      return migratedNotes;
    }

    final legacySnapshot = await _legacyStorage.read();
    if (legacySnapshot == null || legacySnapshot.isEmpty) return const [];

    late final List<NoteModel> notes;
    try {
      notes = _codec.decode(legacySnapshot);
    } on FormatException {
      return const [];
    }

    final migratedNotes = <NoteModel>[];
    await _database.transaction(() async {
      for (var index = 0; index < notes.length; index++) {
        final note = await _attachmentStorage.migrateLegacyReferences(
          notes[index],
        );
        migratedNotes.add(note);
        await _database
            .into(_database.storedNotes)
            .insert(
              StoredNotesCompanion.insert(
                id: note.id,
                value: _codec.encodeNote(note),
                sortOrder: index,
              ),
            );
      }
    });
    await _legacyStorage.clear();
    return migratedNotes.map(_codec.encodeNote).toList();
  }

  @override
  Future<void> writeNote(String id, String value, int sortOrder) async {
    await _database.transaction(() async {
      final existing = await (_database.select(
        _database.storedNotes,
      )..where((row) => row.id.equals(id))).getSingleOrNull();
      if (existing == null) {
        await (_database.update(
          _database.storedNotes,
        )..where((row) => row.sortOrder.isBiggerOrEqualValue(sortOrder))).write(
          StoredNotesCompanion.custom(sortOrder: Variable(sortOrder + 1)),
        );
      }
      await _database
          .into(_database.storedNotes)
          .insertOnConflictUpdate(
            StoredNotesCompanion.insert(
              id: id,
              value: value,
              sortOrder: sortOrder,
            ),
          );
    });
  }

  @override
  Future<void> deleteNote(String id) async {
    await (_database.delete(
      _database.storedNotes,
    )..where((row) => row.id.equals(id))).go();
  }

  @override
  Future<void> clear() async {
    await _database.delete(_database.storedNotes).go();
    await _legacyStorage.clear();
  }

  Future<void> close() => _database.close();
}
