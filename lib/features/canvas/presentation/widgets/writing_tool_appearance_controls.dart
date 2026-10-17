import 'package:flutter/material.dart';

import '../../domain/models/argb_color.dart';
import '../../domain/models/writing_tool.dart';

/// Controls color, width, opacity, and presets for non-eraser tools.
class WritingToolAppearanceControls extends StatelessWidget {
  final ToolConfig activeConfig;
  final ValueChanged<ToolConfig> onConfigChanged;
  final bool vertical;

  const WritingToolAppearanceControls({
    super.key,
    required this.activeConfig,
    required this.onConfigChanged,
    this.vertical = false,
  });

  static const _colors = <(Color, String)>[
    (Colors.black, 'color_picker_black'),
    (Colors.blue, 'color_picker_blue'),
    (Colors.red, 'color_picker_red'),
    (Colors.green, 'color_picker_green'),
    (Color(0xFFFFEB3B), 'color_picker_yellow'),
  ];

  Widget _buildColorPicker(BuildContext context) {
    final swatches = _colors.map((item) {
      final (color, keyName) = item;
      final isSelected = activeConfig.color.value == color.toARGB32();
      return GestureDetector(
        key: Key(keyName),
        onTap: () => onConfigChanged(
          activeConfig.copyWith(color: ArgbColor(color.toARGB32())),
        ),
        child: Container(
          margin: vertical
              ? const EdgeInsets.symmetric(vertical: 4)
              : const EdgeInsets.symmetric(horizontal: 2),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: vertical ? 2 : (isSelected ? 2.5 : 1),
            ),
          ),
        ),
      );
    }).toList();
    return Flex(
      direction: vertical ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      children: swatches,
    );
  }

  Widget _buildThicknessSelector(BuildContext context) {
    if (vertical) {
      return RotatedBox(
        quarterTurns: 3,
        child: SizedBox(
          width: 112,
          height: 28,
          child: Slider(
            key: const Key('thickness_slider'),
            value: activeConfig.strokeWidth.clamp(1, 32),
            min: 1,
            max: 32,
            onChanged: (value) =>
                onConfigChanged(activeConfig.copyWith(strokeWidth: value)),
          ),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.line_weight,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(
          width: 90,
          child: Slider(
            key: const Key('thickness_slider'),
            value: activeConfig.strokeWidth,
            min: 1,
            max: 32,
            onChanged: (value) =>
                onConfigChanged(activeConfig.copyWith(strokeWidth: value)),
          ),
        ),
      ],
    );
  }

  Widget _buildOpacitySelector(BuildContext context) {
    if (vertical) {
      return RotatedBox(
        quarterTurns: 3,
        child: SizedBox(
          width: 92,
          height: 28,
          child: Slider(
            key: const Key('opacity_slider'),
            value: activeConfig.opacity.clamp(0.1, 1),
            min: 0.1,
            max: 1,
            onChanged: (value) =>
                onConfigChanged(activeConfig.copyWith(opacity: value)),
          ),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.opacity,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(
          width: 80,
          child: Slider(
            key: const Key('opacity_slider'),
            value: activeConfig.opacity,
            min: 0.1,
            max: 1,
            onChanged: (value) =>
                onConfigChanged(activeConfig.copyWith(opacity: value)),
          ),
        ),
      ],
    );
  }

  Widget _buildPresets() {
    if (vertical) {
      return IconButton(
        key: const Key('preset_fine_pen'),
        tooltip: 'Fine pen',
        icon: const Icon(Icons.line_weight),
        onPressed: () =>
            onConfigChanged(ToolConfig.defaultPen.copyWith(strokeWidth: 1.5)),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          key: const Key('preset_fine_pen'),
          onPressed: () =>
              onConfigChanged(ToolConfig.defaultPen.copyWith(strokeWidth: 1.5)),
          child: const Text('Fine Pen', style: TextStyle(fontSize: 12)),
        ),
        TextButton(
          key: const Key('preset_marker'),
          onPressed: () =>
              onConfigChanged(ToolConfig.defaultPen.copyWith(strokeWidth: 6)),
          child: const Text('Marker', style: TextStyle(fontSize: 12)),
        ),
        TextButton(
          key: const Key('preset_chisel_highlighter'),
          onPressed: () => onConfigChanged(
            ToolConfig.defaultHighlighter.copyWith(strokeWidth: 20),
          ),
          child: const Text('Chisel', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      _buildColorPicker(context),
      _buildThicknessSelector(context),
      _buildOpacitySelector(context),
      _buildPresets(),
    ];
    if (!vertical) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          controls[0],
          const SizedBox(width: 8),
          controls[1],
          const SizedBox(width: 8),
          controls[2],
          const SizedBox(width: 8),
          controls[3],
        ],
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: controls);
  }
}
