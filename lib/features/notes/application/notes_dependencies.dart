import '../data/repositories/note_repository.dart';
import 'notes_use_cases.dart';

final NotesUseCases appNotesUseCases = NotesUseCases(appNoteRepository);

Future<void> initializeNotes() => appNoteRepository.initialize();
