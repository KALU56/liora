import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/main.dart';

void main() {
  testWidgets('Foundation app smoke test & navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PaperNoteApp());
    await tester.pumpAndSettle();

    // Verify home screen is loaded with empty state.
    expect(find.text('PaperNote'), findsOneWidget);
    expect(find.text('No Notes Yet'), findsOneWidget);

    // Tap Create Note button and trigger transition.
    await tester.tap(find.byKey(const Key('create_first_note_button')));
    await tester.pumpAndSettle();

    // Verify NewNoteScreen is displayed.
    expect(find.text('Create New Note'), findsOneWidget);
    expect(find.text('Note Title'), findsOneWidget);
  });
}
