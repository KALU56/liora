import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/library/presentation/home_screen.dart';
import 'package:notability_clone/features/notes/data/repositories/note_repository.dart';
import 'package:notability_clone/features/notes/domain/models/note_model.dart';

void main() {
  late NoteRepository repository;

  setUp(() {
    repository = NoteRepository();
  });

  group('Issue #2 — Note Management & Title Search QA Gate', () {
    testWidgets('Test 5 — Rename Note: Renaming updates title in Library and Editor', (WidgetTester tester) async {
      final note = repository.createNote(title: 'Original Title');

      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(repository: repository),
        routes: {
          '/editor': (context) => Scaffold(
                appBar: AppBar(title: Text(note.title)),
                body: const Text('Editor Workspace'),
              ),
        },
      ));
      await tester.pumpAndSettle();

      expect(find.text('Original Title'), findsOneWidget);

      // Open popup menu on the note card
      await tester.tap(find.byKey(Key('note_menu_${note.id}')));
      await tester.pumpAndSettle();

      // Tap rename
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      // Enter new title
      await tester.enterText(find.byKey(const Key('rename_note_input')), 'Renamed Biology Note');
      await tester.pumpAndSettle();

      // Confirm rename
      await tester.tap(find.byKey(const Key('confirm_rename_button')));
      await tester.pumpAndSettle();

      // Verify title is updated in Library
      expect(find.text('Original Title'), findsNothing);
      expect(find.text('Renamed Biology Note'), findsOneWidget);
      expect(repository.getNoteById(note.id)?.title, equals('Renamed Biology Note'));
    });

    testWidgets('Test 6 — Open Correct Note: Tapping a note opens its corresponding content', (WidgetTester tester) async {
      repository.createNote(title: 'Math Notes');
      repository.createNote(title: 'Physics Notes');

      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(repository: repository),
        routes: {
          '/editor': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final noteTitle = (args is NoteModel) ? args.title : 'Editor';
            return Scaffold(
              appBar: AppBar(title: Text(noteTitle)),
              body: Text('Content for $noteTitle'),
            );
          },
        },
      ));
      await tester.pumpAndSettle();

      expect(find.text('Math Notes'), findsOneWidget);
      expect(find.text('Physics Notes'), findsOneWidget);

      // Tap Physics Notes card
      await tester.tap(find.text('Physics Notes'));
      await tester.pumpAndSettle();

      // Verify Editor opens with Physics Notes content
      expect(find.text('Content for Physics Notes'), findsOneWidget);
      expect(find.text('Content for Math Notes'), findsNothing);
    });

    testWidgets('Test 7 — Delete Note: Deleting a note leaves all other notes untouched', (WidgetTester tester) async {
      repository.createNote(title: 'Keep This Note');
      final note2 = repository.createNote(title: 'Delete This Note');

      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(repository: repository),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Keep This Note'), findsOneWidget);
      expect(find.text('Delete This Note'), findsOneWidget);

      // Open popup menu on note2
      await tester.tap(find.byKey(Key('note_menu_${note2.id}')));
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm delete dialog
      expect(find.text('Delete Note'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle();

      // Verify note2 is deleted and note1 is untouched
      expect(find.text('Delete This Note'), findsNothing);
      expect(find.text('Keep This Note'), findsOneWidget);
      expect(repository.notes.length, equals(1));
      expect(repository.notes.first.title, equals('Keep This Note'));
    });

    testWidgets('Test 8 — Basic Note Search: Searching by title filters notes accurately', (WidgetTester tester) async {
      repository.createNote(title: 'Algebra 101');
      repository.createNote(title: 'Biology Chapter 1');
      repository.createNote(title: 'Chemistry Lab');

      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(repository: repository),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Algebra 101'), findsOneWidget);
      expect(find.text('Biology Chapter 1'), findsOneWidget);
      expect(find.text('Chemistry Lab'), findsOneWidget);

      // Open search field
      await tester.tap(find.byKey(const Key('toggle_search_button')));
      await tester.pumpAndSettle();

      // Type "bio"
      await tester.enterText(find.byKey(const Key('search_notes_field')), 'bio');
      await tester.pumpAndSettle();

      // Verify only "Biology Chapter 1" is visible
      expect(find.text('Biology Chapter 1'), findsOneWidget);
      expect(find.text('Algebra 101'), findsNothing);
      expect(find.text('Chemistry Lab'), findsNothing);

      // Clear search
      await tester.tap(find.byKey(const Key('toggle_search_button')));
      await tester.pumpAndSettle();

      // All notes restored
      expect(find.text('Algebra 101'), findsOneWidget);
      expect(find.text('Biology Chapter 1'), findsOneWidget);
      expect(find.text('Chemistry Lab'), findsOneWidget);
    });
  });
}
