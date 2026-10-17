import 'dart:convert';

import '../../domain/models/note_model.dart';
import 'note_model_mapper.dart';

/// Encodes and decodes the persisted note snapshot at the data boundary.
class NoteSnapshotCodec {
  const NoteSnapshotCodec({this.mapper = const NoteModelMapper()});

  final NoteModelMapper mapper;

  String encode(List<NoteModel> notes) {
    return jsonEncode(notes.map(mapper.noteToMap).toList());
  }

  String encodeNote(NoteModel note) => jsonEncode(mapper.noteToMap(note));

  NoteModel decodeNote(String rawNote) {
    final decoded = jsonDecode(rawNote);
    if (decoded is! Map) throw const FormatException('Invalid note record');
    return mapper.noteFromMap(Map<String, dynamic>.from(decoded));
  }

  List<NoteModel> decode(String rawNotes) {
    final decoded = jsonDecode(rawNotes);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map((note) => mapper.noteFromMap(Map<String, dynamic>.from(note)))
        .toList();
  }
}
