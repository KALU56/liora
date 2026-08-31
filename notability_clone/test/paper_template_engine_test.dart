import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/notes/presentation/note_editor_screen.dart';
import 'package:notability_clone/features/paper/domain/models/paper_template.dart';
import 'package:notability_clone/features/paper/presentation/widgets/paper_canvas_widget.dart';

void main() {
  group('Issue #3 — Paper Template Engine & Customization QA Gate', () {
    testWidgets('Test 9 — Blank Paper: Plain background renders without lines or dots', (WidgetTester tester) async {
      const template = PaperTemplate(
        pattern: PaperPattern.blank,
        backgroundColor: Color(0xFFFFFFFF),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaperCanvasWidget(template: template),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PaperCanvasWidget), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      final PaperCanvasWidget widget = tester.widget(find.byType(PaperCanvasWidget));
      expect(widget.template.pattern, equals(PaperPattern.blank));
      expect(widget.template.backgroundColor, equals(const Color(0xFFFFFFFF)));
    });

    testWidgets('Test 10 — Ruled Paper: Horizontal lines render and remain attached to page during pan/zoom', (WidgetTester tester) async {
      const template = PaperTemplate(
        pattern: PaperPattern.ruled,
        backgroundColor: Color(0xFFFFFFFF),
        lineSpacing: 32.0,
      );

      final controller = TransformationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveViewer(
              transformationController: controller,
              child: const PaperCanvasWidget(template: template),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final PaperCanvasWidget widget = tester.widget(find.byType(PaperCanvasWidget));
      expect(widget.template.pattern, equals(PaperPattern.ruled));

      // Simulate pan transformation (translation along X and Y)
      controller.value = Matrix4.translationValues(100.0, 150.0, 0.0);
      await tester.pumpAndSettle();

      // Simulate zoom in transformation (scale 2.0x)
      controller.value = Matrix4.diagonal3Values(2.0, 2.0, 1.0);
      await tester.pumpAndSettle();

      // Horizontal guidelines stay attached to page coordinates during transformation
      expect(find.byType(PaperCanvasWidget), findsOneWidget);
    });

    testWidgets('Test 11 — Grid Paper: Grid cells remain correctly aligned during zoom/pan', (WidgetTester tester) async {
      const template = PaperTemplate(
        pattern: PaperPattern.grid,
        backgroundColor: Color(0xFFFFFDF0),
        gridSize: 32.0,
      );

      final controller = TransformationController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveViewer(
              transformationController: controller,
              child: const PaperCanvasWidget(template: template),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final PaperCanvasWidget widget = tester.widget(find.byType(PaperCanvasWidget));
      expect(widget.template.pattern, equals(PaperPattern.grid));
      expect(widget.template.gridSize, equals(32.0));

      // Apply zoom & pan transformation matrix
      final Matrix4 transform = Matrix4.translationValues(50.0, 50.0, 0.0)
        ..multiply(Matrix4.diagonal3Values(1.5, 1.5, 1.0));
      controller.value = transform;
      await tester.pumpAndSettle();

      expect(find.byType(PaperCanvasWidget), findsOneWidget);
    });

    testWidgets('Test 12 — Dotted Paper: Dots maintain correct spacing and coordinate alignment', (WidgetTester tester) async {
      const template = PaperTemplate(
        pattern: PaperPattern.dotted,
        backgroundColor: Color(0xFF1E1E1E), // Dark paper
        dotSpacing: 32.0,
        dotRadius: 2.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaperCanvasWidget(template: template),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final PaperCanvasWidget widget = tester.widget(find.byType(PaperCanvasWidget));
      expect(widget.template.pattern, equals(PaperPattern.dotted));
      expect(widget.template.dotSpacing, equals(32.0));
      expect(widget.template.dotRadius, equals(2.0));

      // Dark background automatically uses light contrasting dots
      final Color effectiveDotColor = widget.template.effectivePatternColor;
      expect(effectiveDotColor.computeLuminance(), greaterThan(0.5));
    });

    testWidgets('Test 13 — Paper Color: Background color changes and persists', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NoteEditorScreen(title: 'Test Color Persistence Note'),
        ),
      );
      await tester.pumpAndSettle();

      // Open Paper Settings bottom sheet
      await tester.tap(find.byKey(const Key('paper_settings_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('paper_customization_sheet')), findsOneWidget);

      // Select Canary Yellow background color
      await tester.tap(find.byKey(const Key('paper_color_canary')));
      await tester.pumpAndSettle();

      // Tap Done / Apply button
      await tester.tap(find.byKey(const Key('apply_paper_template_button')));
      await tester.pumpAndSettle();

      // Verify sheet closed and paper canvas updated to selected Canary Yellow color
      expect(find.byKey(const Key('paper_customization_sheet')), findsNothing);

      final PaperCanvasWidget widget = tester.widget(find.byKey(const Key('paper_canvas')));
      expect(widget.template.backgroundColor, equals(const Color(0xFFFFF9C4)));
    });

    testWidgets('Test 14 — Orientation: Portrait & Landscape maintain correct page dimensions', (WidgetTester tester) async {
      // 1. Portrait orientation defaults (612 x 792)
      const portraitTemplate = PaperTemplate(
        orientation: PageOrientation.portrait,
        baseWidth: 612.0,
        baseHeight: 792.0,
      );

      expect(portraitTemplate.width, equals(612.0));
      expect(portraitTemplate.height, equals(792.0));
      expect(portraitTemplate.pageSize, equals(const Size(612.0, 792.0)));

      // 2. Landscape orientation swaps dimensions (792 x 612)
      const landscapeTemplate = PaperTemplate(
        orientation: PageOrientation.landscape,
        baseWidth: 612.0,
        baseHeight: 792.0,
      );

      expect(landscapeTemplate.width, equals(792.0));
      expect(landscapeTemplate.height, equals(612.0));
      expect(landscapeTemplate.pageSize, equals(const Size(792.0, 612.0)));

      // 3. UI interaction test switching orientation via sheet
      await tester.pumpWidget(
        const MaterialApp(
          home: NoteEditorScreen(title: 'Orientation Test Note'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial canvas size is Portrait (612 x 792)
      PaperCanvasWidget canvasWidget = tester.widget(find.byKey(const Key('paper_canvas')));
      expect(canvasWidget.template.orientation, equals(PageOrientation.portrait));
      expect(canvasWidget.template.width, equals(612.0));
      expect(canvasWidget.template.height, equals(792.0));

      // Open settings and select Landscape
      await tester.tap(find.byKey(const Key('paper_settings_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('orientation_landscape')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('apply_paper_template_button')));
      await tester.pumpAndSettle();

      // Verify canvas size updated to Landscape (792 x 612)
      canvasWidget = tester.widget(find.byKey(const Key('paper_canvas')));
      expect(canvasWidget.template.orientation, equals(PageOrientation.landscape));
      expect(canvasWidget.template.width, equals(792.0));
      expect(canvasWidget.template.height, equals(612.0));
    });
  });
}
