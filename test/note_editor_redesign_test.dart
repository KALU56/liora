import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/core/theme/app_colors.dart';
import 'package:notability_clone/core/theme/app_theme.dart';
import 'package:notability_clone/features/canvas/domain/models/writing_tool.dart';
import 'package:notability_clone/features/canvas/presentation/widgets/stroke_painter.dart';
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

  testWidgets('editor popovers follow the app dark theme', (tester) async {
    final repository = NoteRepository(storage: _MemoryStorage());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        home: NewNoteScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('expand_tools_button')));
    await tester.pumpAndSettle();

    final popover = find.byKey(const Key('active_editor_popover_expanded'));
    expect(tester.widget<Material>(popover).color, AppColors.darkSurface);
    expect(
      Theme.of(tester.element(popover)).colorScheme.onSurface,
      AppColors.darkTextPrimary,
    );
  });

  testWidgets('ruler moves and rotates without becoming a stroke', (
    tester,
  ) async {
    final repository = NoteRepository(storage: _MemoryStorage());
    await tester.pumpWidget(
      MaterialApp(home: NewNoteScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('expand_tools_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('select_ruler_tool')));
    await tester.pumpAndSettle();

    final canvas = find.byKey(const Key('handwriting_touch_listener'));
    final canvasRect = tester.getRect(canvas);
    final canvasCenter = canvasRect.center;
    final paintFinder = find.byKey(const Key('stroke_canvas_paint'));
    StrokePainter painter() =>
        tester.widget<CustomPaint>(paintFinder).painter! as StrokePainter;

    expect(painter().ruler, isNotNull);
    final originalCenter = painter().ruler!.center;
    final move = await tester.startGesture(canvasCenter);
    await move.moveBy(const Offset(36, 24));
    await move.up();
    await tester.pumpAndSettle();
    expect(painter().ruler!.center, originalCenter + const Offset(36, 24));
    expect(repository.notes.single.pages.first.strokes, isEmpty);

    final ruler = painter().ruler!;
    final handlePosition =
        canvasRect.topLeft + ruler.toCanvas(Offset(ruler.length / 2 + 20, 0));
    final rotate = await tester.startGesture(handlePosition);
    await rotate.moveBy(const Offset(-140, 140));
    await rotate.up();
    await tester.pumpAndSettle();
    expect(painter().ruler!.angle, closeTo(3.141592653589793 / 2, 0.03));
    expect(repository.notes.single.pages.first.strokes, isEmpty);
  });

  testWidgets('ruler edge drag creates a straight persisted line', (
    tester,
  ) async {
    final repository = NoteRepository(storage: _MemoryStorage());
    await tester.pumpWidget(
      MaterialApp(home: NewNoteScreen(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('expand_tools_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('select_ruler_tool')));
    await tester.pumpAndSettle();

    final canvas = find.byKey(const Key('handwriting_touch_listener'));
    final rect = tester.getRect(canvas);
    final gesture = await tester.startGesture(
      rect.center + const Offset(-70, -22),
    );
    await gesture.moveBy(const Offset(120, 30));
    await gesture.up();
    await tester.pumpAndSettle();

    final strokes = repository.notes.single.pages.first.strokes;
    expect(strokes, hasLength(1));
    expect(strokes.single.toolType, WritingToolType.pen);
    final yValues = strokes.single.points.map((point) => point.position.y);
    expect(yValues.reduce(math.min), closeTo(yValues.reduce(math.max), 0.01));

    await tester.tapAt(rect.topLeft + const Offset(12, 12));
    await tester.pumpAndSettle();
    final resumedStrokes = repository.notes.single.pages.first.strokes;
    expect(resumedStrokes, hasLength(2));
    expect(resumedStrokes.last.toolType, WritingToolType.pen);
  });

  testWidgets('tapping existing text in pen mode opens text editing controls', (
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
    await tester.enterText(
      find.byKey(const Key('canvas_inline_text_field')),
      'Edit this',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('text_tool_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('handwriting_tool_button')));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(find.text('Edit this')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('canvas_inline_text_field')), findsOneWidget);
    expect(find.byKey(const Key('text_font_selector')), findsOneWidget);
    await tester.tap(find.byKey(const Key('text_bold_button')));
    await tester.pumpAndSettle();
    expect(repository.notes.single.pages.first.textBlocks.single.bold, isTrue);
    expect(repository.notes.single.pages.first.strokes, isEmpty);
  });

  testWidgets('tapping a stroke opens controls that restyle that stroke', (
    tester,
  ) async {
    final repository = NoteRepository(storage: _MemoryStorage());
    await tester.pumpWidget(
      MaterialApp(home: NewNoteScreen(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pen_tool_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tool_pen')));
    await tester.pumpAndSettle();

    final canvas = find.byKey(const Key('handwriting_touch_listener'));
    final center = tester.getCenter(canvas);
    final draw = await tester.startGesture(center + const Offset(-30, 0));
    await draw.moveBy(const Offset(90, 0));
    await draw.up();
    await tester.pumpAndSettle();

    await tester.tapAt(center + const Offset(12, 0));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('selected_stroke_width_slider')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(Key('stroke_color_${0xFFF44336}')));
    await tester.pumpAndSettle();

    expect(
      repository.notes.single.pages.first.strokes.single.color.value,
      0xFFF44336,
    );
  });

  testWidgets('shape controls create a filled triangle', (tester) async {
    final repository = NoteRepository(storage: _MemoryStorage());
    await tester.pumpWidget(
      MaterialApp(home: NewNoteScreen(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pen_tool_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tool_shape')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pen_tool_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shape_type_selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('triangle').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shape_fill_toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pen_tool_button')));
    await tester.pumpAndSettle();

    final canvas = find.byKey(const Key('handwriting_touch_listener'));
    final draw = await tester.startGesture(tester.getCenter(canvas));
    await draw.moveBy(const Offset(70, 90));
    await draw.up();
    await tester.pumpAndSettle();

    final stroke = repository.notes.single.pages.first.strokes.single;
    expect(stroke.shapeType, ShapeType.triangle);
    expect(stroke.filled, isTrue);
    expect(tester.takeException(), isNull);
  });
}
