import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/core/theme/accent_palette.dart';
import 'package:notability_clone/core/theme/app_theme.dart';
import 'package:notability_clone/core/theme/color_contrast.dart';
import 'package:notability_clone/features/notes/presentation/widgets/note_card.dart';
import 'package:notability_clone/main.dart';

void main() {
  group('Issue #1 — Foundation Library & App Launch QA Gate', () {
    testWidgets(
      'Test 1 — App Launch: App launches without crashing and displays Library header',
      (WidgetTester tester) async {
        await tester.pumpWidget(const PaperNoteApp());
        await tester.pumpAndSettle();

        expect(find.text('PaperNote'), findsOneWidget);
      },
    );

    testWidgets(
      'Test 2 — Empty Library: Displays clear empty state view when no notes exist',
      (WidgetTester tester) async {
        await tester.pumpWidget(const PaperNoteApp());
        await tester.pumpAndSettle();

        expect(find.text('No Notes Yet'), findsOneWidget);
        expect(
          find.text(
            'Create your first notebook to start writing, drawing, and organizing your thoughts.',
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('create_first_note_button')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('create_note_fab')), findsOneWidget);
      },
    );

    testWidgets('Accent picker updates the active app theme', (tester) async {
      await tester.pumpWidget(const PaperNoteApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('accent_color_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('accent_swatch_ocean')));
      await tester.pumpAndSettle();

      final theme = Theme.of(
        tester.element(find.byKey(const Key('create_note_fab'))),
      );
      expect(theme.colorScheme.primary, const Color(0xFF506C73));
    });

    test('all accent colors provide AA contrast in light and dark themes', () {
      for (final accent in AccentPalette.options) {
        final lightTheme = AppTheme.lightTheme(accent: accent.color);
        final darkTheme = AppTheme.darkTheme(accent: accent.color);

        expect(
          ColorContrast.contrastRatio(
            accent.color,
            lightTheme.colorScheme.onPrimary,
          ),
          greaterThanOrEqualTo(4.5),
          reason: '${accent.name} light button text contrast',
        );
        expect(
          ColorContrast.contrastRatio(
            accent.color,
            darkTheme.colorScheme.onPrimary,
          ),
          greaterThanOrEqualTo(4.5),
          reason: '${accent.name} dark button text contrast',
        );
      }
    });

    testWidgets('Test 3 — Create New Note: Tapping + opens Note Editor route', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PaperNoteApp());
      await tester.pumpAndSettle();

      // Tap FAB to open Editor / New Note screen
      await tester.tap(find.byKey(const Key('create_note_fab')));
      await tester.pumpAndSettle();

      expect(find.text('Create New Note'), findsOneWidget);
      expect(find.text('Note Title'), findsOneWidget);
      expect(
        find.byKey(const Key('submit_create_note_button')),
        findsOneWidget,
      );
    });

    testWidgets(
      'Test 4 — Library Display: Newly created note appears immediately in the library list',
      (WidgetTester tester) async {
        await tester.pumpWidget(const PaperNoteApp());
        await tester.pumpAndSettle();

        // Open new note creation
        await tester.tap(find.byKey(const Key('create_first_note_button')));
        await tester.pumpAndSettle();

        // Enter title
        await tester.enterText(find.byType(TextField), 'Biology Chapter 1');
        await tester.pumpAndSettle();

        // Submit creation
        await tester.tap(find.byKey(const Key('submit_create_note_button')));
        await tester.pumpAndSettle();

        // Verify empty library state is gone and new note appears in list
        expect(find.text('No Notes Yet'), findsNothing);
        expect(find.text('Biology Chapter 1'), findsOneWidget);
        expect(find.byType(NoteCard), findsOneWidget);
      },
    );
  });
}
