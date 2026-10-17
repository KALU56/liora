import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'note_database.g.dart';

class StoredNotes extends Table {
  TextColumn get id => text()();
  TextColumn get value => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StoredAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get mimeType => text()();
  BlobColumn get bytes => blob()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [StoredNotes, StoredAttachments])
class NoteDatabase extends _$NoteDatabase {
  NoteDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'papernote',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(storedAttachments);
    },
  );
}
