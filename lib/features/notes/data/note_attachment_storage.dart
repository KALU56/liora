import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database/note_database.dart';
import '../domain/models/note_model.dart';
import '../domain/models/note_page.dart';

class StoredAttachment {
  const StoredAttachment({
    required this.name,
    required this.mimeType,
    required this.bytes,
  });
  final String name;
  final String mimeType;
  final Uint8List bytes;
}

/// Stores attachment bytes alongside notes so database backups include them.
class NoteAttachmentStorage {
  NoteAttachmentStorage({ImagePicker? imagePicker, NoteDatabase? database})
    : _imagePicker = imagePicker ?? ImagePicker(),
      _database = database ?? NoteDatabase();

  static const _urlPrefix = 'url:';
  static const _attachmentPrefix = 'attachment:';
  final ImagePicker _imagePicker;
  final NoteDatabase _database;
  final Map<String, String> _migratedLegacyReferences = {};

  Future<String?> pickImageAndKeep() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return _store(
      image.name,
      image.mimeType ?? 'application/octet-stream',
      await image.readAsBytes(),
    );
  }

  Future<String?> pickFileAndKeep() async {
    final selection = await FilePicker.pickFiles();
    final file = selection.firstOrNull;
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return _store(file.name, 'application/octet-stream', bytes);
  }

  Future<String> keepFile(String sourcePath) async {
    final file = File(sourcePath);
    final bytes = await file.readAsBytes();
    return _store(
      file.uri.pathSegments.last,
      'application/octet-stream',
      bytes,
    );
  }

  /// Copies readable legacy paths into SQLite while retaining unavailable paths.
  Future<NoteModel> migrateLegacyReferences(NoteModel note) async {
    if (kIsWeb) return note;
    var changed = false;
    final pages = <NotePage>[];
    for (final page in note.pages) {
      final references = <String>[];
      for (final reference in page.attachments) {
        if (reference.startsWith(_urlPrefix) ||
            reference.startsWith(_attachmentPrefix)) {
          references.add(reference);
          continue;
        }
        final migratedReference = _migratedLegacyReferences[reference];
        if (migratedReference != null) {
          references.add(migratedReference);
          changed = true;
          continue;
        }
        try {
          final file = File(reference);
          if (!await file.exists()) {
            references.add(reference);
            continue;
          }
          final storedReference = await _store(
            file.uri.pathSegments.last,
            _mimeTypeFor(file.path),
            await file.readAsBytes(),
          );
          _migratedLegacyReferences[reference] = storedReference;
          references.add(storedReference);
          changed = true;
        } on FileSystemException {
          references.add(reference);
        }
      }
      pages.add(page.copyWith(attachments: references));
    }
    return changed ? note.copyWith(pages: pages) : note;
  }

  String _mimeTypeFor(String path) {
    final extension = path.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'm4a' => 'audio/mp4',
      'mp3' => 'audio/mpeg',
      'wav' => 'audio/wav',
      'aac' => 'audio/aac',
      'pdf' => 'application/pdf',
      _ => 'application/octet-stream',
    };
  }

  Future<String> _store(String name, String mimeType, Uint8List bytes) async {
    final id =
        '${DateTime.now().microsecondsSinceEpoch}_${name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
    await _database
        .into(_database.storedAttachments)
        .insert(
          StoredAttachmentsCompanion.insert(
            id: id,
            name: name,
            mimeType: mimeType,
            bytes: bytes,
          ),
        );
    return '$_attachmentPrefix$id';
  }

  Future<StoredAttachment?> load(String reference) async {
    if (!reference.startsWith(_attachmentPrefix)) return null;
    final id = reference.substring(_attachmentPrefix.length);
    final row = await (_database.select(
      _database.storedAttachments,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return StoredAttachment(
      name: row.name,
      mimeType: row.mimeType,
      bytes: row.bytes,
    );
  }

  Future<bool> openFile(String reference) async {
    if (!reference.startsWith(_attachmentPrefix)) {
      return launchUrl(Uri.file(reference));
    }
    final attachment = await load(reference);
    if (attachment == null || kIsWeb) return false;
    final directory = await getTemporaryDirectory();
    final safeName = attachment.name.replaceAll(RegExp(r'[/\\]'), '_');
    final file = File('${directory.path}/$safeName');
    await file.writeAsBytes(attachment.bytes, flush: true);
    return launchUrl(Uri.file(file.path));
  }

  Future<bool> openLink(String url) => launchUrl(Uri.parse(url));

  Future<void> deleteUnusedFiles(
    NoteModel deletedNote,
    Iterable<NoteModel> remainingNotes,
  ) async {
    final referenced = remainingNotes
        .expand((note) => note.pages)
        .expand((page) => page.attachments)
        .toSet();
    final candidates = deletedNote.pages
        .expand((page) => page.attachments)
        .where((ref) => !ref.startsWith(_urlPrefix))
        .toSet()
        .difference(referenced);
    for (final reference in candidates) {
      if (reference.startsWith(_attachmentPrefix)) {
        final id = reference.substring(_attachmentPrefix.length);
        await (_database.delete(
          _database.storedAttachments,
        )..where((row) => row.id.equals(id))).go();
      } else if (!kIsWeb) {
        final file = File(reference);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }
}
