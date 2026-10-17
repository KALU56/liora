/// Small storage boundary that makes persistence testable without platform code.
abstract class NoteStorage {
  Future<List<String>> readNotes();
  Future<void> writeNote(String id, String value, int sortOrder);
  Future<void> deleteNote(String id);
  Future<void> clear();
}
