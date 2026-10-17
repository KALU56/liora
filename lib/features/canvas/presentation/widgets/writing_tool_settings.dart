import 'package:flutter/material.dart';

import '../../domain/models/writing_tool.dart';
import 'eraser_size_selector.dart';
import 'writing_tool_appearance_controls.dart';

/// Composes settings specific to the selected writing tool.
class WritingToolSettings extends StatelessWidget {
  final ToolConfig activeConfig;
  final ValueChanged<ToolConfig> onConfigChanged;
  final bool vertical;

  const WritingToolSettings({
    super.key,
    required this.activeConfig,
    required this.onConfigChanged,
    this.vertical = false,
  });

  Widget _buildShapeSelector() {
    if (vertical) {
      return PopupMenuButton<ShapeType>(
        key: const Key('shape_type_selector'),
        tooltip: 'Choose shape',
        icon: const Icon(Icons.change_history),
        onSelected: (shape) =>
            onConfigChanged(activeConfig.copyWith(shapeType: shape)),
        itemBuilder: (context) => ShapeType.values
            .map(
              (shape) => PopupMenuItem(value: shape, child: Text(shape.name)),
            )
            .toList(),
      );
    }
    return DropdownButton<ShapeType>(
      key: const Key('shape_type_selector'),
      value: activeConfig.shapeType,
      items: ShapeType.values
          .map(
            (shape) => DropdownMenuItem(value: shape, child: Text(shape.name)),
          )
          .toList(),
      onChanged: (shape) {
        if (shape != null) {
          onConfigChanged(activeConfig.copyWith(shapeType: shape));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (activeConfig.toolType == WritingToolType.eraser) {
      return EraserSizeSelector(
        activeConfig: activeConfig,
        onConfigChanged: onConfigChanged,
        vertical: vertical,
      );
    }
    final children = <Widget>[
      if (activeConfig.toolType == WritingToolType.shape) _buildShapeSelector(),
      WritingToolAppearanceControls(
        activeConfig: activeConfig,
        onConfigChanged: onConfigChanged,
        vertical: vertical,
      ),
    ];
    return Flex(
      direction: vertical ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
