import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:notability_clone/features/notes/data/database/note_database.dart';
import 'package:notability_clone/features/notes/data/note_attachment_storage.dart';
import 'package:notability_clone/features/notes/domain/models/note_model.dart';
import 'package:notability_clone/features/notes/domain/models/note_page.dart';

void main() {
  test(
    'stored attachment bytes load and are removed with the last note',
    () async {
      final database = NoteDatabase(NativeDatabase.memory());
      final storage = NoteAttachmentStorage(database: database);
      await database
          .into(database.storedAttachments)
          .insert(
            StoredAttachmentsCompanion.insert(
              id: 'blob-1',
              name: 'photo.png',
              mimeType: 'image/png',
              bytes: Uint8List.fromList([1, 2, 3]),
            ),
          );
      const reference = 'attachment:blob-1';

      final loaded = await storage.load(reference);
      expect(loaded?.name, 'photo.png');
      expect(loaded?.bytes, [1, 2, 3]);

      await storage.deleteUnusedFiles(_note('deleted', [reference]), []);
      expect(await storage.load(reference), isNull);
      await database.close();
    },
  );

  test(
    'permanent deletion removes only unreferenced local attachments',
    () async {
      final database = NoteDatabase(NativeDatabase.memory());
      final directory = await Directory.systemTemp.createTemp('papernote-');
      final removable = await File('${directory.path}/old.pdf').create();
      final retained = await File('${directory.path}/shared.png').create();
      final deletedNote = _note('deleted', [
        removable.path,
        retained.path,
        'url:https://example.com',
      ]);
      final remainingNote = _note('remaining', [retained.path]);

      await NoteAttachmentStorage(database: database)
          .deleteUnusedFiles(deletedNote, [remainingNote]);

      expect(await removable.exists(), isFalse);
      expect(await retained.exists(), isTrue);
      await directory.delete(recursive: true);
      await database.close();
    },
  );
}

NoteModel _note(String id, List<String> attachments) {
  final now = DateTime(2026);
  return NoteModel(
    id: id,
    title: id,
    createdDate: now,
    modifiedDate: now,
    pages: [NotePage(id: '${id}_page', attachments: attachments)],
  );
}
