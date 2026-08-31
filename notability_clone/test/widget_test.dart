import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/main.dart';

void main() {
  testWidgets('Foundation app smoke test & navigation', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PaperNoteApp());

    // Verify home screen is loaded.
    expect(find.text('Welcome to PaperNote'), findsOneWidget);
    expect(find.text('New Note'), findsOneWidget);

    // Tap New Note button and trigger transition.
    await tester.tap(find.text('New Note'));
    await tester.pumpAndSettle();

    // Verify NewNoteScreen is displayed.
    expect(find.text('Create New Note'), findsOneWidget);
    expect(find.text('Note Title'), findsOneWidget);
  });
}
