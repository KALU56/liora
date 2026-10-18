import 'package:flutter/material.dart';
import 'package:notability_clone/core/constants/app_constants.dart';
import 'package:notability_clone/features/canvas/domain/models/writing_tool.dart';
import 'package:notability_clone/features/editor/presentation/widgets/editor_toolbar_button.dart';

/// Shows shape type and fill controls as a nested toolbar row.
class EditorShapeToolbarOptions extends StatelessWidget {
  const EditorShapeToolbarOptions({
    super.key,
    required this.selectedShape,
    required this.isFilled,
    required this.onSelectShape,
    required this.onToggleFill,
  });

  final ShapeType selectedShape;
  final bool isFilled;
  final ValueChanged<ShapeType> onSelectShape;
  final VoidCallback onToggleFill;

  IconData _iconForShape(ShapeType shape) => switch (shape) {
    ShapeType.line => Icons.show_chart,
    ShapeType.rectangle => Icons.crop_16_9,
    ShapeType.square => Icons.crop_square,
    ShapeType.oval => Icons.circle_outlined,
    ShapeType.circle => Icons.circle,
    ShapeType.triangle => Icons.change_history,
    ShapeType.arrow => Icons.arrow_right_alt,
  };

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ...ShapeType.values.map(
        (shape) => EditorToolbarButton(
          buttonKey: Key('toolbar_shape_${shape.name}'),
          tooltip: shape.name,
          icon: Icon(_iconForShape(shape)),
          active: selectedShape == shape,
          onPressed: () => onSelectShape(shape),
        ),
      ),
      EditorToolbarButton(
        buttonKey: const Key('toolbar_shape_fill_button'),
        tooltip: isFilled
            ? AppConstants.removeShapeFill
            : AppConstants.fillShape,
        icon: const Icon(Icons.format_color_fill),
        active: isFilled,
        onPressed: onToggleFill,
      ),
    ],
  );
}
