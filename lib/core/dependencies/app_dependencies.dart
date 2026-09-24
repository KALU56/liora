import '../../features/notes/application/notes_use_cases.dart';
import '../../features/notes/data/repositories/note_repository.dart';
import '../../features/paper/application/paper_use_cases.dart';

/// Composition root for concrete application dependencies.
class AppDependencies {
  AppDependencies({NoteRepository? noteRepository})
    : noteRepository = noteRepository ?? NoteRepository(),
      _usesProvidedRepository = noteRepository != null;

  final NoteRepository noteRepository;
  final bool _usesProvidedRepository;

  late final NotesUseCases notes = NotesUseCases(noteRepository);
  final PaperUseCases paper = const PaperUseCases();

  Future<void> initialize() async {
    if (!_usesProvidedRepository) {
      await noteRepository.initialize();
    }
  }
}

final AppDependencies appDependencies = AppDependencies(
  noteRepository: appNoteRepository,
);
