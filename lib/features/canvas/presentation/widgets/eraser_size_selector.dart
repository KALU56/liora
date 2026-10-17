import 'package:flutter/material.dart';

import '../../domain/models/writing_tool.dart';

/// Shows the supported eraser sizes in the toolbar's current orientation.
class EraserSizeSelector extends StatelessWidget {
  final ToolConfig activeConfig;
  final ValueChanged<ToolConfig> onConfigChanged;
  final bool vertical;

  const EraserSizeSelector({
    super.key,
    required this.activeConfig,
    required this.onConfigChanged,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final smallLabel = vertical ? 'S' : 'Small Eraser';
    final largeLabel = vertical ? 'L' : 'Large Eraser';
    final sizes = <Widget>[
      ChoiceChip(
        key: const Key('eraser_size_small'),
        label: Text(smallLabel),
        selected: activeConfig.eraserSize == EraserSize.small,
        onSelected: (selected) {
          if (selected) {
            onConfigChanged(
              activeConfig.copyWith(eraserSize: EraserSize.small),
            );
          }
        },
      ),
      ChoiceChip(
        key: const Key('eraser_size_large'),
        label: Text(largeLabel),
        selected: activeConfig.eraserSize == EraserSize.large,
        onSelected: (selected) {
          if (selected) {
            onConfigChanged(
              activeConfig.copyWith(eraserSize: EraserSize.large),
            );
          }
        },
      ),
    ];
    return Flex(
      direction: vertical ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      children: sizes,
    );
  }
}
