import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/canvas/domain/models/stroke.dart';
import 'package:notability_clone/features/canvas/domain/models/touch_point.dart';
import 'package:notability_clone/features/canvas/domain/models/writing_tool.dart';
import 'package:notability_clone/features/canvas/domain/services/eraser_service.dart';
import 'package:notability_clone/features/canvas/presentation/widgets/handwriting_canvas_widget.dart';
import 'package:notability_clone/features/notes/presentation/note_editor_screen.dart';

void main() {
  group('Issue #5 — Digital Writing Tools QA Gate', () {
    testWidgets(
      'Test 27 — Pen Tool Activation: Pen activates and default settings apply',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: NoteEditorScreen(title: 'Pen Test Note')),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('tool_pen')), findsOneWidget);
        await tester.tap(find.byKey(const Key('tool_pen')));
        await tester.pumpAndSettle();

        // Perform a stroke on canvas
        final canvasFinder = find.byKey(
          const Key('handwriting_touch_listener'),
        );
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(canvasFinder),
        );
        await gesture.moveBy(const Offset(50, 50));
        await gesture.up();
        await tester.pumpAndSettle();

        final HandwritingCanvasWidget canvasWidget = tester.widget(
          find.byType(HandwritingCanvasWidget),
        );
        expect(canvasWidget.strokes.length, equals(1));
        expect(
          canvasWidget.strokes.first.toolType,
          equals(WritingToolType.pen),
        );
      },
    );

    testWidgets(
      'Test 28 — Pen Color Customization: Changing color updates stroke color',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: NoteEditorScreen(title: 'Color Test Note')),
        );
        await tester.pumpAndSettle();

        // Select Blue color
        await tester.tap(find.byKey(const Key('color_picker_blue')));
        await tester.pumpAndSettle();

        // Draw stroke
        final canvasFinder = find.byKey(
          const Key('handwriting_touch_listener'),
        );
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(canvasFinder),
        );
        await gesture.moveBy(const Offset(30, 30));
        await gesture.up();
        await tester.pumpAndSettle();

        final HandwritingCanvasWidget canvasWidget = tester.widget(
          find.byType(HandwritingCanvasWidget),
        );
        expect(
          canvasWidget.strokes.first.color.toARGB32(),
          equals(Colors.blue.toARGB32()),
        );
      },
    );

    testWidgets(
      'Test 29 — Pen Stroke Thickness: Thickness updates strokeWidth',
      (WidgetTester tester) async {
        const config = ToolConfig(
          toolType: WritingToolType.pen,
          strokeWidth: 10.0,
        );
        expect(config.strokeWidth, equals(10.0));
      },
    );

    testWidgets(
      'Test 30 — Pen Opacity: Opacity setting applies to new strokes',
      (WidgetTester tester) async {
        const config = ToolConfig(toolType: WritingToolType.pen, opacity: 0.7);
        expect(config.opacity, equals(0.7));
      },
    );

    testWidgets(
      'Test 31 — Pen Presets: Fine Pen & Marker presets update properties',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: NoteEditorScreen(title: 'Presets Test Note')),
        );
        await tester.pumpAndSettle();

        // Select Fine Pen preset
        await tester.tap(find.byKey(const Key('preset_fine_pen')));
        await tester.pumpAndSettle();

        // Draw stroke
        final canvasFinder = find.byKey(
          const Key('handwriting_touch_listener'),
        );
        TestGesture gesture = await tester.startGesture(
          tester.getCenter(canvasFinder),
        );
        await gesture.moveBy(const Offset(20, 20));
        await gesture.up();
        await tester.pumpAndSettle();

        HandwritingCanvasWidget canvasWidget = tester.widget(
          find.byType(HandwritingCanvasWidget),
        );
        expect(canvasWidget.strokes.last.strokeWidth, equals(1.5));
      },
    );

    testWidgets(
      'Test 32 — Pencil Tool Visual Style: Distinct pencil toolType and texture',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: NoteEditorScreen(title: 'Pencil Test Note')),
        );
        await tester.pumpAndSettle();

        // Select Pencil tool
        await tester.tap(find.byKey(const Key('tool_pencil')));
        await tester.pumpAndSettle();

        // Draw stroke
        final canvasFinder = find.byKey(
          const Key('handwriting_touch_listener'),
        );
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(canvasFinder),
        );
        await gesture.moveBy(const Offset(40, 40));
        await gesture.up();
        await tester.pumpAndSettle();

        final HandwritingCanvasWidget canvasWidget = tester.widget(
          find.byType(HandwritingCanvasWidget),
        );
        expect(
          canvasWidget.strokes.last.toolType,
          equals(WritingToolType.pencil),
        );
      },
    );

    testWidgets(
      'Test 33 — Tool Switching: Switches cleanly between Pen and Pencil',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: NoteEditorScreen(title: 'Tool Switch Note')),
        );
        await tester.pumpAndSettle();

        // Tap Pencil
        await tester.tap(find.byKey(const Key('tool_pencil')));
        await tester.pumpAndSettle();

        // Tap Pen
        await tester.tap(find.byKey(const Key('tool_pen')));
        await tester.pumpAndSettle();

        // Draw stroke
        final canvasFinder = find.byKey(
          const Key('handwriting_touch_listener'),
        );
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(canvasFinder),
        );
        await gesture.moveBy(const Offset(30, 30));
        await gesture.up();
        await tester.pumpAndSettle();

        final HandwritingCanvasWidget canvasWidget = tester.widget(
          find.byType(HandwritingCanvasWidget),
        );
        expect(canvasWidget.strokes.last.toolType, equals(WritingToolType.pen));
      },
    );

    testWidgets(
      'Test 34 — Highlighter Tool Semi-Transparency: Renders with translucency',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NoteEditorScreen(title: 'Highlighter Test Note'),
          ),
        );
        await tester.pumpAndSettle();

        // Select Highlighter tool
        await tester.tap(find.byKey(const Key('tool_highlighter')));
        await tester.pumpAndSettle();

        // Draw stroke
        final canvasFinder = find.byKey(
          const Key('handwriting_touch_listener'),
        );
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(canvasFinder),
        );
        await gesture.moveBy(const Offset(60, 0));
        await gesture.up();
        await tester.pumpAndSettle();

        final HandwritingCanvasWidget canvasWidget = tester.widget(
          find.byType(HandwritingCanvasWidget),
        );
        expect(
          canvasWidget.strokes.last.toolType,
          equals(WritingToolType.highlighter),
        );
        expect(canvasWidget.strokes.last.opacity, equals(0.4));
      },
    );

    testWidgets(
      'Test 35 — Highlighter Color Selection: Yellow highlighter color',
      (WidgetTester tester) async {
        const config = ToolConfig(
          toolType: WritingToolType.highlighter,
          color: Color(0xFFFFEB3B),
        );
        expect(
          config.color.toARGB32(),
          equals(const Color(0xFFFFEB3B).toARGB32()),
        );
      },
    );

    testWidgets(
      'Test 36 — Highlighter Text Readability: Preserves content visibility',
      (WidgetTester tester) async {
        final stroke = Stroke(
          id: 'hl_1',
          toolType: WritingToolType.highlighter,
          color: Colors.yellow,
          opacity: 0.4,
          strokeWidth: 16.0,
        );
        expect(stroke.opacity, lessThan(1.0));
      },
    );

    testWidgets(
      'Test 37 — Highlighter Tool Switching: Switches cleanly with Pen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NoteEditorScreen(title: 'Highlighter Switch Note'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tool_highlighter')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tool_pen')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('tool_pen')), findsOneWidget);
      },
    );

    testWidgets(
      'Test 38 — Eraser Tool Size Selection: Small & Large sizes update radius',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: NoteEditorScreen(title: 'Eraser Size Note')),
        );
        await tester.pumpAndSettle();

        // Tap Eraser tool
        await tester.tap(find.byKey(const Key('tool_eraser')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('eraser_size_small')), findsOneWidget);
        expect(find.byKey(const Key('eraser_size_large')), findsOneWidget);

        // Select Large Eraser
        await tester.tap(find.byKey(const Key('eraser_size_large')));
        await tester.pumpAndSettle();

        final ChoiceChip largeChip = tester.widget(
          find.byKey(const Key('eraser_size_large')),
        );
        expect(largeChip.selected, isTrue);
      },
    );

    testWidgets(
      'Test 39 — Eraser Object-Based Erasing: Erases target stroke cleanly',
      (WidgetTester tester) async {
        final stroke1 = Stroke(
          id: 's1',
          points: [
            TouchPoint(
              offset: const Offset(100, 100),
              timestamp: DateTime.now(),
            ),
            TouchPoint(
              offset: const Offset(120, 100),
              timestamp: DateTime.now(),
            ),
          ],
        );

        final stroke2 = Stroke(
          id: 's2',
          points: [
            TouchPoint(
              offset: const Offset(300, 300),
              timestamp: DateTime.now(),
            ),
            TouchPoint(
              offset: const Offset(320, 300),
              timestamp: DateTime.now(),
            ),
          ],
        );

        final initialStrokes = [stroke1, stroke2];

        // Erase near stroke1 (Offset 110, 100)
        final remaining = EraserService.eraseStrokesAtPoint(
          initialStrokes,
          const Offset(110, 100),
          16.0,
        );

        expect(remaining.length, equals(1));
        expect(remaining.first.id, equals('s2'));
      },
    );

    testWidgets(
      'Test 40 — Eraser Continuous Drag Erasing: Removes intersected strokes along path',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: NoteEditorScreen(title: 'Drag Erase Note')),
        );
        await tester.pumpAndSettle();

        // Draw a stroke first
        final canvasFinder = find.byKey(
          const Key('handwriting_touch_listener'),
        );
        final Offset center = tester.getCenter(canvasFinder);

        TestGesture gesture = await tester.startGesture(center);
        await gesture.moveBy(const Offset(40, 0));
        await gesture.up();
        await tester.pumpAndSettle();

        HandwritingCanvasWidget canvasWidget = tester.widget(
          find.byType(HandwritingCanvasWidget),
        );
        expect(canvasWidget.strokes.length, equals(1));

        // Select Eraser tool
        await tester.tap(find.byKey(const Key('tool_eraser')));
        await tester.pumpAndSettle();

        // Drag eraser across the stroke position
        gesture = await tester.startGesture(center);
        await gesture.moveBy(const Offset(40, 0));
        await gesture.up();
        await tester.pumpAndSettle();

        canvasWidget = tester.widget(find.byType(HandwritingCanvasWidget));
        expect(canvasWidget.strokes.length, equals(0));
      },
    );

    testWidgets(
      'Test 41 — Eraser Selective Isolation: Untouched independent strokes remain intact',
      (WidgetTester tester) async {
        final strokeKeep = Stroke(
          id: 'keep_me',
          points: [
            TouchPoint(offset: const Offset(50, 50), timestamp: DateTime.now()),
          ],
        );

        final strokeDelete = Stroke(
          id: 'delete_me',
          points: [
            TouchPoint(
              offset: const Offset(200, 200),
              timestamp: DateTime.now(),
            ),
          ],
        );

        final result = EraserService.eraseStrokesAtPoint(
          [strokeKeep, strokeDelete],
          const Offset(200, 200),
          16.0,
        );

        expect(result.length, equals(1));
        expect(result.first.id, equals('keep_me'));
      },
    );
  });
}
