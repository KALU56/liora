import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/library/presentation/new_note_screen.dart';
import 'package:notability_clone/features/notes/data/repositories/note_repository.dart';
import 'package:notability_clone/features/notes/data/repositories/note_storage.dart';
import 'package:notability_clone/features/notes/domain/models/note_page.dart';
import 'package:notability_clone/features/notes/presentation/widgets/note_card.dart';
import 'package:notability_clone/features/notes/presentation/widgets/note_page_thumbnail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryNoteStorage implements NoteStorage {
  final Map<String, (String, int)> _values = {};

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<List<String>> readNotes() async =>
      _values.values.map((entry) => entry.$1).toList();

  @override
  Future<void> writeNote(String id, String value, int sortOrder) async {
    _values[id] = (value, sortOrder);
  }

  @override
  Future<void> deleteNote(String id) async => _values.remove(id);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('pan mode enables page dragging without drawing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewNoteScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pan_tool_button')));
    await tester.pumpAndSettle();

    final viewer = tester.widget<InteractiveViewer>(
      find.byKey(const Key('note_interactive_viewer')),
    );
    expect(viewer.panEnabled, isTrue);
    expect(find.byTooltip('Finish panning'), findsOneWidget);
  });

  testWidgets('grid note card paints the first page preview', (tester) async {
    final repository = NoteRepository(storage: _MemoryNoteStorage());
    final note = repository.createNote(
      title: 'Preview',
      pages: [NotePage(id: 'preview-page')],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteCard(
            note: note,
            isGrid: true,
            onTap: () {},
            onRename: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.byType(NotePageThumbnail), findsOneWidget);
  });
}
