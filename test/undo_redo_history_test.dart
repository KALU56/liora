import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/canvas/domain/models/canvas_action.dart';
import 'package:notability_clone/features/canvas/domain/models/stroke.dart';
import 'package:notability_clone/features/canvas/domain/models/touch_point.dart';
import 'package:notability_clone/features/canvas/domain/services/canvas_history_manager.dart';
import 'package:notability_clone/features/canvas/presentation/widgets/handwriting_canvas_widget.dart';
import 'package:notability_clone/features/notes/presentation/note_editor_screen.dart';

void main() {
  group('Issue #6 — Undo & Redo History System QA Gate', () {
    testWidgets(
      'Test 42 — Undo Writing: Last stroke action disappears cleanly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: NoteEditorScreen(title: 'Undo Writing Test')),
        );
        await tester.pumpAndSettle();

        // Perform stroke 1
        final canvasFinder = find.byKey(
          const Key('handwriting_touch_listener'),
        );
        TestGesture gesture = await tester.startGesture(
          tester.getCenter(canvasFinder),
        );
        await gesture.moveBy(const Offset(30, 30));
        await gesture.up();
        await tester.pumpAndSettle();

        HandwritingCanvasWidget canvasWidget = tester.widget(
          find.byType(HandwritingCanvasWidget),
        );
        expect(canvasWidget.strokes.length, equals(1));

        // Tap Undo button
        await tester.tap(find.byKey(const Key('undo_stroke_button')));
        await tester.pumpAndSettle();

        canvasWidget = tester.widget(find.byType(HandwritingCanvasWidget));
        expect(canvasWidget.strokes.length, equals(0));
      },
    );

    testWidgets(
      'Test 43 — Redo Writing: Undone stroke action returns cleanly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: NoteEditorScreen(title: 'Redo Writing Test')),
        );
        await tester.pumpAndSettle();

        // Perform stroke
        final canvasFinder = find.byKey(
          const Key('handwriting_touch_listener'),
        );
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(canvasFinder),
        );
        await gesture.moveBy(const Offset(40, 40));
        await gesture.up();
        await tester.pumpAndSettle();

        // Tap Undo
        await tester.tap(find.byKey(const Key('undo_stroke_button')));
        await tester.pumpAndSettle();

        HandwritingCanvasWidget canvasWidget = tester.widget(
          find.byType(HandwritingCanvasWidget),
        );
        expect(canvasWidget.strokes.length, equals(0));

        // Tap Redo
        await tester.tap(find.byKey(const Key('redo_stroke_button')));
        await tester.pumpAndSettle();

        canvasWidget = tester.widget(find.byType(HandwritingCanvasWidget));
        expect(canvasWidget.strokes.length, equals(1));
      },
    );

    testWidgets(
      'Test 44 — Undo Erasing: Erased content is restored to canvas',
      (WidgetTester tester) async {
        final history = CanvasHistoryManager();
        final stroke1 = Stroke(
          id: 's1',
          points: [
            TouchPoint(
              offset: const Offset(100, 100),
              timestamp: DateTime.now(),
            ),
          ],
        );

        // Record adding stroke1
        history.recordAction(AddStrokeAction(stroke1));
        List<Stroke> strokes = [stroke1];

        // Simulate erasing stroke1
        history.recordAction(EraseStrokesAction([stroke1]));
        strokes = [];

        expect(strokes.length, equals(0));

        // Undo erasing stroke1
        strokes = history.undo(strokes);
        expect(strokes.length, equals(1));
        expect(strokes.first.id, equals('s1'));
      },
    );

    testWidgets(
      'Test 45 — Multiple Undo/Redo Operations: Reverses and restores in exact order',
      (WidgetTester tester) async {
        final history = CanvasHistoryManager();
        final stroke1 = Stroke(id: 's1');
        final stroke2 = Stroke(id: 's2');
        final stroke3 = Stroke(id: 's3');

        List<Stroke> strokes = [];

        // Perform 3 stroke actions
        history.recordAction(AddStrokeAction(stroke1));
        strokes = [stroke1];

        history.recordAction(AddStrokeAction(stroke2));
        strokes = [stroke1, stroke2];

        history.recordAction(AddStrokeAction(stroke3));
        strokes = [stroke1, stroke2, stroke3];

        expect(strokes.length, equals(3));

        // Undo stroke3
        strokes = history.undo(strokes);
        expect(strokes.length, equals(2));
        expect(strokes.last.id, equals('s2'));

        // Undo stroke2
        strokes = history.undo(strokes);
        expect(strokes.length, equals(1));
        expect(strokes.last.id, equals('s1'));

        // Redo stroke2
        strokes = history.redo(strokes);
        expect(strokes.length, equals(2));
        expect(strokes.last.id, equals('s2'));

        // Redo stroke3
        strokes = history.redo(strokes);
        expect(strokes.length, equals(3));
        expect(strokes.last.id, equals('s3'));
      },
    );

    testWidgets(
      'Test 46 — Action Stack Branching: New edit after Undo invalidates Redo stack',
      (WidgetTester tester) async {
        final history = CanvasHistoryManager();
        final stroke1 = Stroke(id: 's1');
        final stroke2 = Stroke(id: 's2');
        final strokeBranch = Stroke(id: 's_branch');

        List<Stroke> strokes = [];

        history.recordAction(AddStrokeAction(stroke1));
        strokes = [stroke1];

        history.recordAction(AddStrokeAction(stroke2));
        strokes = [stroke1, stroke2];

        // Undo stroke2 -> canRedo becomes true
        strokes = history.undo(strokes);
        expect(history.canRedo, isTrue);

        // Perform new stroke action -> Redo stack must be invalidated
        history.recordAction(AddStrokeAction(strokeBranch));
        strokes = [...strokes, strokeBranch];

        expect(history.canRedo, isFalse);
      },
    );

    testWidgets(
      'Test 47 — Clear Canvas Undo & Redo: Restores and re-clears canvas',
      (WidgetTester tester) async {
        final history = CanvasHistoryManager();
        final stroke1 = Stroke(id: 's1');
        final stroke2 = Stroke(id: 's2');

        List<Stroke> strokes = [stroke1, stroke2];

        // Record Clear Canvas Action
        history.recordAction(ClearCanvasAction([stroke1, stroke2]));
        strokes = [];

        expect(strokes.length, equals(0));

        // Undo Clear
        strokes = history.undo(strokes);
        expect(strokes.length, equals(2));

        // Redo Clear
        strokes = history.redo(strokes);
        expect(strokes.length, equals(0));
      },
    );
  });
}
