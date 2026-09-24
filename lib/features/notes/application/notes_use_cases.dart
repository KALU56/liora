import '../domain/models/note_model.dart';
import '../domain/models/note_page.dart';
import '../domain/repositories/notes_repository.dart';

class NotesUseCases {
  const NotesUseCases(this.repository);

  final NotesRepository repository;

  List<NoteModel> get notes => repository.notes;

  NoteModel createNote({String? title, List<NotePage>? pages}) {
    return repository.createNote(title: title, pages: pages);
  }

  bool updateNote(NoteModel note) {
    return repository.updateNote(note);
  }

  bool renameNote(String id, String title) {
    return repository.renameNote(id, title);
  }

  bool deleteNote(String id) {
    return repository.deleteNote(id);
  }

  List<NoteModel> searchNotes(String query) {
    return repository.searchNotes(query);
  }

  NoteModel? getNoteById(String id) {
    return repository.getNoteById(id);
  }
}
