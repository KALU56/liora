import '../models/note_model.dart';
import '../models/note_page.dart';

abstract interface class NotesRepository {
  List<NoteModel> get notes;

  NoteModel createNote({String? title, List<NotePage>? pages});

  bool updateNote(NoteModel note);

  bool renameNote(String id, String newTitle);

  bool deleteNote(String id);

  List<NoteModel> searchNotes(String query);

  NoteModel? getNoteById(String id);
}
