import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/library/presentation/new_note_screen.dart';
import 'package:notability_clone/features/notes/data/repositories/note_repository.dart';
import 'package:notability_clone/features/notes/data/repositories/note_storage.dart';

class _MemoryStorage implements NoteStorage {
  String? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}

void main() {
  testWidgets('title is edited in the app bar and auto-saved', (tester) async {
    final repository = NoteRepository(storage: _MemoryStorage());
    await tester.pumpWidget(
      MaterialApp(home: NewNoteScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('editor_title_input')), findsNothing);
    expect(find.byKey(const Key('save_editor_button')), findsNothing);
    await tester.tap(find.byKey(const Key('editor_title')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Meeting notes');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(repository.notes.single.title, 'Meeting notes');
  });

  testWidgets('text typed with the keyboard is saved on the page', (
    tester,
  ) async {
    final repository = NoteRepository(storage: _MemoryStorage());
    await tester.pumpWidget(
      MaterialApp(home: NewNoteScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('text_tool_button')));
    await tester.pumpAndSettle();
    final paperRect = tester.getRect(find.byKey(const Key('paper_canvas')));
    await tester.tapAt(paperRect.topLeft + const Offset(40, 40));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('canvas_inline_text_field')), findsOneWidget);
    expect(find.text('Text formatting'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Typed on the page');

    expect(find.text('Typed on the page'), findsOneWidget);
    expect(repository.notes.single.pages.first.textItems, [
      'Typed on the page',
    ]);
    final savedBlock = repository.notes.single.pages.first.textBlocks.single;
    expect(savedBlock.x, closeTo(40, 2));
    expect(savedBlock.y, closeTo(40, 2));
  });

  testWidgets('canvas text can be repositioned by dragging', (tester) async {
    final repository = NoteRepository(storage: _MemoryStorage());
    await tester.pumpWidget(
      MaterialApp(home: NewNoteScreen(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('text_tool_button')));
    await tester.pumpAndSettle();
    final paperRect = tester.getRect(find.byKey(const Key('paper_canvas')));
    await tester.tapAt(paperRect.topLeft + const Offset(40, 40));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('canvas_inline_text_field')),
      'Move me',
    );
    final before = repository.notes.single.pages.first.textBlocks.single;

    // Leave typing mode, then drag the note text into the desired spot.
    await tester.tap(find.byKey(const Key('text_tool_button')));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Move me'), const Offset(64, 48));
    await tester.pumpAndSettle();

    final after = repository.notes.single.pages.first.textBlocks.single;
    expect(after.x, greaterThan(before.x));
    expect(after.y, greaterThan(before.y));
  });

  testWidgets('editor controls fit a narrow screen and tools open on demand', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = NoteRepository(storage: _MemoryStorage());
    await tester.pumpWidget(
      MaterialApp(home: NewNoteScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('handwriting_tool_button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('pen_tool_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tool_pen')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tool_shape')));
    await tester.pumpAndSettle();
    final canvas = find.byKey(const Key('handwriting_touch_listener'));
    final gesture = await tester.startGesture(tester.getCenter(canvas));
    await gesture.moveBy(const Offset(40, 30));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      repository.notes.single.pages.first.strokes.single.shapeType,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });
}
