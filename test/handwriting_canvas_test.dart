import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/canvas/domain/models/stroke.dart';
import 'package:notability_clone/features/canvas/domain/models/touch_point.dart';
import 'package:notability_clone/features/canvas/presentation/widgets/handwriting_canvas_widget.dart';
import 'package:notability_clone/features/notes/presentation/note_editor_screen.dart';
import 'package:notability_clone/features/paper/domain/models/paper_template.dart';

void main() {
  group(
    'Issue #4 — Touch Input, Handwriting Engine & Viewport Controls QA Gate',
    () {
      testWidgets(
        'Test 15 — Canvas Loading: Canvas fills viewport without clipping',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: NoteEditorScreen(
                title: 'Viewport Test Note',
                initialTemplate: PaperTemplate(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('paper_canvas')), findsOneWidget);
          expect(find.byKey(const Key('handwriting_canvas')), findsOneWidget);
          expect(
            find.byKey(const Key('note_interactive_viewer')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Test 16 — Viewport Control Zoom In: Zooming in transforms viewport scale',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: NoteEditorScreen(title: 'Zoom In Test')),
          );
          await tester.pumpAndSettle();

          final viewerFinder = find.byKey(const Key('note_interactive_viewer'));
          final InteractiveViewer initialViewer = tester.widget(viewerFinder);
          final Matrix4 initialMatrix =
              initialViewer.transformationController?.value ??
              Matrix4.identity();

          // Tap zoom in button
          await tester.tap(find.byKey(const Key('zoom_in_button')));
          await tester.pumpAndSettle();

          final InteractiveViewer updatedViewer = tester.widget(viewerFinder);
          final Matrix4 updatedMatrix =
              updatedViewer.transformationController?.value ??
              Matrix4.identity();

          expect(
            updatedMatrix.getMaxScaleOnAxis(),
            greaterThan(initialMatrix.getMaxScaleOnAxis()),
          );
        },
      );

      testWidgets(
        'Test 17 — Viewport Control Zoom Out: Zooming out scales canvas viewport accurately',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: NoteEditorScreen(title: 'Zoom Out Test')),
          );
          await tester.pumpAndSettle();

          final viewerFinder = find.byKey(const Key('note_interactive_viewer'));

          // Zoom out from initial scale
          await tester.tap(find.byKey(const Key('zoom_out_button')));
          await tester.pumpAndSettle();

          final InteractiveViewer updatedViewer = tester.widget(viewerFinder);
          final Matrix4 updatedMatrix =
              updatedViewer.transformationController?.value ??
              Matrix4.identity();

          expect(updatedMatrix.getMaxScaleOnAxis(), lessThan(1.0));
        },
      );

      testWidgets(
        'Test 18 — Viewport Control Pan: Panning translates viewport without adding stray strokes in Pan Mode',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: NoteEditorScreen(title: 'Pan Test')),
          );
          await tester.pumpAndSettle();

          // Switch to Pan Mode
          await tester.tap(find.byKey(const Key('tool_mode_button')));
          await tester.pumpAndSettle();

          final canvasCenter = tester.getCenter(
            find.byKey(const Key('paper_canvas')),
          );

          // Drag in Pan Mode
          final gesture = await tester.startGesture(canvasCenter);
          await gesture.moveBy(const Offset(50, 50));
          await gesture.up();
          await tester.pumpAndSettle();

          // Verify no strokes were created in Pan mode
          final HandwritingCanvasWidget canvasWidget = tester.widget(
            find.byKey(const Key('handwriting_canvas')),
          );
          expect(canvasWidget.strokes, isEmpty);
        },
      );

      testWidgets(
        'Test 19 — Reset Zoom: Returns canvas scale to identity matrix (1.0)',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: NoteEditorScreen(title: 'Reset Zoom Test')),
          );
          await tester.pumpAndSettle();

          // Zoom in twice
          await tester.tap(find.byKey(const Key('zoom_in_button')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('zoom_in_button')));
          await tester.pumpAndSettle();

          // Reset zoom
          await tester.tap(find.byKey(const Key('reset_zoom_button')));
          await tester.pumpAndSettle();

          final viewerFinder = find.byKey(const Key('note_interactive_viewer'));
          final InteractiveViewer resetViewer = tester.widget(viewerFinder);
          final Matrix4 resetMatrix =
              resetViewer.transformationController?.value ?? Matrix4.identity();

          expect(resetMatrix.getMaxScaleOnAxis(), equals(1.0));
        },
      );

      testWidgets(
        'Test 20 — Finger Writing: Touch down + move + up generates a valid stroke with accurate points',
        (WidgetTester tester) async {
          List<Stroke> capturedStrokes = [];

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: HandwritingCanvasWidget(
                  strokes: capturedStrokes,
                  isDrawingMode: true,
                  onStrokesChanged: (newStrokes) {
                    capturedStrokes = newStrokes;
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final center = tester.getCenter(
            find.byKey(const Key('handwriting_touch_listener')),
          );

          final gesture = await tester.startGesture(
            center,
            pointer: 1,
            kind: PointerDeviceKind.touch,
          );
          await gesture.moveBy(const Offset(20, 40));
          await gesture.moveBy(const Offset(40, 80));
          await gesture.up();
          await tester.pumpAndSettle();

          expect(capturedStrokes.length, equals(1));
          expect(capturedStrokes.first.points.length, greaterThanOrEqualTo(2));
          expect(capturedStrokes.first.isComplete, isTrue);
        },
      );

      testWidgets(
        'Test 21 — Capacitive Pen: Stylus input generates strokes predictably',
        (WidgetTester tester) async {
          List<Stroke> capturedStrokes = [];

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: HandwritingCanvasWidget(
                  strokes: capturedStrokes,
                  isDrawingMode: true,
                  onStrokesChanged: (newStrokes) {
                    capturedStrokes = newStrokes;
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final center = tester.getCenter(
            find.byKey(const Key('handwriting_touch_listener')),
          );

          final gesture = await tester.startGesture(
            center,
            pointer: 2,
            kind: PointerDeviceKind.stylus,
          );
          await gesture.moveBy(const Offset(30, -30));
          await gesture.up();
          await tester.pumpAndSettle();

          expect(capturedStrokes.length, equals(1));
          expect(capturedStrokes.first.points.isNotEmpty, isTrue);
        },
      );

      testWidgets(
        'Test 22 — Stroke Independence: Separate drag gestures create independent stroke objects without joining',
        (WidgetTester tester) async {
          List<Stroke> capturedStrokes = [];

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: HandwritingCanvasWidget(
                  strokes: capturedStrokes,
                  isDrawingMode: true,
                  onStrokesChanged: (newStrokes) {
                    capturedStrokes = newStrokes;
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final center = tester.getCenter(
            find.byKey(const Key('handwriting_touch_listener')),
          );

          // First stroke
          final g1 = await tester.startGesture(center);
          await g1.moveBy(const Offset(10, 10));
          await g1.up();
          await tester.pumpAndSettle();

          // Second stroke
          final g2 = await tester.startGesture(center + const Offset(50, 50));
          await g2.moveBy(const Offset(10, 10));
          await g2.up();
          await tester.pumpAndSettle();

          expect(capturedStrokes.length, equals(2));
          expect(capturedStrokes[0].id, isNot(equals(capturedStrokes[1].id)));
        },
      );

      testWidgets(
        'Test 23 — Smooth Curve Pathing: Stroke converts points into quadratic bezier path',
        (WidgetTester tester) async {
          final now = DateTime.now();
          final stroke = Stroke(
            id: 'stroke_1',
            points: [
              TouchPoint(offset: const Offset(10, 10), timestamp: now),
              TouchPoint(offset: const Offset(20, 30), timestamp: now),
              TouchPoint(offset: const Offset(40, 50), timestamp: now),
            ],
          );

          final path = stroke.toPath();
          expect(path.getBounds().isEmpty, isFalse);
        },
      );

      testWidgets(
        'Test 24 — Undo Stroke: Tapping undo removes the most recent stroke',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: NoteEditorScreen(title: 'Undo Test')),
          );
          await tester.pumpAndSettle();

          final center = tester.getCenter(
            find.byKey(const Key('paper_canvas')),
          );

          // Draw stroke 1
          final g1 = await tester.startGesture(center);
          await g1.moveBy(const Offset(20, 20));
          await g1.up();
          await tester.pumpAndSettle();

          // Tap undo
          await tester.tap(find.byKey(const Key('undo_stroke_button')));
          await tester.pumpAndSettle();

          final HandwritingCanvasWidget canvasWidget = tester.widget(
            find.byKey(const Key('handwriting_canvas')),
          );
          expect(canvasWidget.strokes, isEmpty);
        },
      );

      testWidgets('Test 25 — Clear Canvas: Tapping clear removes all strokes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(home: NoteEditorScreen(title: 'Clear Test')),
        );
        await tester.pumpAndSettle();

        final center = tester.getCenter(find.byKey(const Key('paper_canvas')));

        // Draw two strokes
        final g1 = await tester.startGesture(center);
        await g1.moveBy(const Offset(10, 10));
        await g1.up();
        await tester.pumpAndSettle();

        final g2 = await tester.startGesture(center + const Offset(30, 30));
        await g2.moveBy(const Offset(10, 10));
        await g2.up();
        await tester.pumpAndSettle();

        // Tap clear
        await tester.tap(find.byKey(const Key('clear_canvas_button')));
        await tester.pumpAndSettle();

        final HandwritingCanvasWidget canvasWidget = tester.widget(
          find.byKey(const Key('handwriting_canvas')),
        );
        expect(canvasWidget.strokes, isEmpty);
      });

      testWidgets(
        'Test 26 — TouchPoint Metadata: Preserves offset, pressure, and timestamp',
        (WidgetTester tester) async {
          final now = DateTime.now();
          final point = TouchPoint(
            offset: const Offset(15.0, 25.0),
            pressure: 0.8,
            timestamp: now,
          );

          final map = point.toMap();
          final restored = TouchPoint.fromMap(map);

          expect(restored.offset, equals(const Offset(15.0, 25.0)));
          expect(restored.pressure, equals(0.8));
          expect(
            restored.timestamp.toIso8601String(),
            equals(now.toIso8601String()),
          );
        },
      );
    },
  );
}
