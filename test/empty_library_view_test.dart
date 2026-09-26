import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/library/presentation/widgets/empty_library_view.dart';

void main() {
  Widget buildTestWidget({VoidCallback? onCreateNote, ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(
        body: EmptyLibraryView(onCreateNote: onCreateNote ?? () {}),
      ),
    );
  }

  group('EmptyLibraryView', () {
    testWidgets('displays the empty library content', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('No Notes Yet'), findsOneWidget);
      expect(
        find.text(
          'Create your first notebook to start writing, drawing, and organizing your thoughts.',
        ),
        findsOneWidget,
      );
      expect(find.text('Create Note'), findsOneWidget);
    });

    testWidgets('displays the expected icons', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('has a create-first-note button', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byKey(const Key('create_first_note_button')), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onCreateNote when the button is tapped', (tester) async {
      var callbackCount = 0;

      await tester.pumpWidget(
        buildTestWidget(onCreateNote: () => callbackCount++),
      );

      await tester.tap(find.byKey(const Key('create_first_note_button')));
      await tester.pump();

      expect(callbackCount, 1);
    });

    testWidgets('works correctly with a dark theme', (tester) async {
      await tester.pumpWidget(buildTestWidget(theme: ThemeData.dark()));

      expect(find.text('No Notes Yet'), findsOneWidget);
      expect(find.text('Create Note'), findsOneWidget);
      expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
