import '../../domain/models/note_model.dart';

class NoteRepository {
  final List<NoteModel> _notes = [];
  int _idCounter = 0;

  List<NoteModel> get notes => List.unmodifiable(_notes);

  NoteModel createNote({String? title}) {
    final now = DateTime.now();
    _idCounter++;
    final defaultTitle = (title == null || title.trim().isEmpty)
        ? 'Untitled Note'
        : title.trim();

    final newNote = NoteModel(
      id: '${now.microsecondsSinceEpoch}_$_idCounter',
      title: defaultTitle,
      pageCount: 1,
      modifiedDate: now,
      createdDate: now,
    );

    _notes.insert(0, newNote);
    return newNote;
  }

  bool updateNote(NoteModel updatedNote) {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote.copyWith(modifiedDate: DateTime.now());
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
      return true;
    }
    return false;
  }

  bool deleteNote(String id) {
    final initialLength = _notes.length;
    _notes.removeWhere((note) => note.id == id);
    return _notes.length < initialLength;
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
  }
}
