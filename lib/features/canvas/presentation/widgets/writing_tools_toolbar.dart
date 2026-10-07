import 'package:flutter/material.dart';

import '../../domain/models/argb_color.dart';
import '../../domain/models/writing_tool.dart';

class WritingToolsToolbar extends StatelessWidget {
  final ToolConfig activeConfig;
  final ValueChanged<ToolConfig> onConfigChanged;
  final bool vertical;

  const WritingToolsToolbar({
    super.key,
    required this.activeConfig,
    required this.onConfigChanged,
    this.vertical = false,
  });

  void _selectTool(WritingToolType toolType) {
    ToolConfig newConfig;
    switch (toolType) {
      case WritingToolType.pen:
        newConfig = activeConfig.copyWith(
          toolType: WritingToolType.pen,
          color: activeConfig.toolType == WritingToolType.pen
              ? activeConfig.color
              : ToolConfig.defaultPen.color,
          strokeWidth: activeConfig.toolType == WritingToolType.pen
              ? activeConfig.strokeWidth
              : ToolConfig.defaultPen.strokeWidth,
          opacity: activeConfig.toolType == WritingToolType.pen
              ? activeConfig.opacity
              : ToolConfig.defaultPen.opacity,
        );
        break;
      case WritingToolType.pencil:
        newConfig = activeConfig.copyWith(
          toolType: WritingToolType.pencil,
          color: activeConfig.toolType == WritingToolType.pencil
              ? activeConfig.color
              : ToolConfig.defaultPencil.color,
          strokeWidth: activeConfig.toolType == WritingToolType.pencil
              ? activeConfig.strokeWidth
              : ToolConfig.defaultPencil.strokeWidth,
          opacity: activeConfig.toolType == WritingToolType.pencil
              ? activeConfig.opacity
              : ToolConfig.defaultPencil.opacity,
        );
        break;
      case WritingToolType.highlighter:
        newConfig = activeConfig.copyWith(
          toolType: WritingToolType.highlighter,
          color: activeConfig.toolType == WritingToolType.highlighter
              ? activeConfig.color
              : ToolConfig.defaultHighlighter.color,
          strokeWidth: activeConfig.toolType == WritingToolType.highlighter
              ? activeConfig.strokeWidth
              : ToolConfig.defaultHighlighter.strokeWidth,
          opacity: activeConfig.toolType == WritingToolType.highlighter
              ? activeConfig.opacity
              : ToolConfig.defaultHighlighter.opacity,
        );
        break;
      case WritingToolType.eraser:
        newConfig = activeConfig.copyWith(toolType: WritingToolType.eraser);
        break;
      case WritingToolType.shape:
        newConfig = activeConfig.copyWith(toolType: WritingToolType.shape);
        break;
      case WritingToolType.ruler:
        newConfig = activeConfig.copyWith(toolType: WritingToolType.ruler);
        break;
    }
    onConfigChanged(newConfig);
  }

  void _applyPreset(ToolConfig preset) {
    onConfigChanged(preset);
  }

  @override
  Widget build(BuildContext context) {
    if (vertical) return _buildVertical(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tool Selector Buttons
              _buildToolButton(
                context: context,
                key: const Key('tool_pen'),
                icon: Icons.edit,
                label: 'Pen',
                toolType: WritingToolType.pen,
              ),
              _buildToolButton(
                context: context,
                key: const Key('tool_pencil'),
                icon: Icons.mode_edit_outline,
                label: 'Pencil',
                toolType: WritingToolType.pencil,
              ),
              _buildToolButton(
                context: context,
                key: const Key('tool_highlighter'),
                icon: Icons.highlight,
                label: 'Highlighter',
                toolType: WritingToolType.highlighter,
              ),
              _buildToolButton(
                context: context,
                key: const Key('tool_eraser'),
                icon: Icons.auto_fix_high,
                label: 'Eraser',
                toolType: WritingToolType.eraser,
              ),
              _buildToolButton(
                context: context,
                key: const Key('tool_shape'),
                icon: Icons.category_outlined,
                label: 'Shapes',
                toolType: WritingToolType.shape,
              ),
              _buildToolButton(
                context: context,
                key: const Key('tool_ruler'),
                icon: Icons.straighten,
                label: 'Ruler',
                toolType: WritingToolType.ruler,
              ),

              const VerticalDivider(width: 16, indent: 8, endIndent: 8),

              // Tool-Specific Property Controls
              if (activeConfig.toolType == WritingToolType.eraser)
                _buildEraserControls()
              else ...[
                if (activeConfig.toolType == WritingToolType.shape)
                  DropdownButton<ShapeType>(
                    key: const Key('shape_type_selector'),
                    value: activeConfig.shapeType,
                    items: ShapeType.values
                        .map(
                          (shape) => DropdownMenuItem(
                            value: shape,
                            child: Text(shape.name),
                          ),
                        )
                        .toList(),
                    onChanged: (shape) {
                      if (shape != null) {
                        onConfigChanged(
                          activeConfig.copyWith(shapeType: shape),
                        );
                      }
                    },
                  ),
                _buildColorPicker(context),
                const SizedBox(width: 8),
                _buildThicknessSelector(context),
                const SizedBox(width: 8),
                _buildOpacitySelector(context),
                const SizedBox(width: 8),
                _buildPresetsDropdown(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVertical(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: 76,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToolButton(
                context: context,
                key: const Key('tool_pen'),
                icon: Icons.edit,
                label: 'Pen',
                toolType: WritingToolType.pen,
              ),
              _buildToolButton(
                context: context,
                key: const Key('tool_pencil'),
                icon: Icons.mode_edit_outline,
                label: 'Pencil',
                toolType: WritingToolType.pencil,
              ),
              _buildToolButton(
                context: context,
                key: const Key('tool_highlighter'),
                icon: Icons.highlight,
                label: 'Highlighter',
                toolType: WritingToolType.highlighter,
              ),
              _buildToolButton(
                context: context,
                key: const Key('tool_eraser'),
                icon: Icons.auto_fix_high,
                label: 'Eraser',
                toolType: WritingToolType.eraser,
              ),
              _buildToolButton(
                context: context,
                key: const Key('tool_shape'),
                icon: Icons.category_outlined,
                label: 'Shapes',
                toolType: WritingToolType.shape,
              ),
              _buildToolButton(
                context: context,
                key: const Key('tool_ruler'),
                icon: Icons.straighten,
                label: 'Ruler',
                toolType: WritingToolType.ruler,
              ),
              const Divider(height: 8),
              if (activeConfig.toolType == WritingToolType.eraser) ...[
                ChoiceChip(
                  key: const Key('eraser_size_small'),
                  label: const Text('S'),
                  selected: activeConfig.eraserSize == EraserSize.small,
                  onSelected: (_) => onConfigChanged(
                    activeConfig.copyWith(eraserSize: EraserSize.small),
                  ),
                ),
                ChoiceChip(
                  key: const Key('eraser_size_large'),
                  label: const Text('L'),
                  selected: activeConfig.eraserSize == EraserSize.large,
                  onSelected: (_) => onConfigChanged(
                    activeConfig.copyWith(eraserSize: EraserSize.large),
                  ),
                ),
              ] else ...[
                if (activeConfig.toolType == WritingToolType.shape)
                  PopupMenuButton<ShapeType>(
                    key: const Key('shape_type_selector'),
                    tooltip: 'Choose shape',
                    icon: const Icon(Icons.change_history),
                    onSelected: (shape) => onConfigChanged(
                      activeConfig.copyWith(shapeType: shape),
                    ),
                    itemBuilder: (context) => ShapeType.values
                        .map(
                          (shape) => PopupMenuItem(
                            value: shape,
                            child: Text(shape.name),
                          ),
                        )
                        .toList(),
                  ),
                ...[
                  (Colors.black, 'color_picker_black'),
                  (Colors.blue, 'color_picker_blue'),
                  (Colors.red, 'color_picker_red'),
                  (Colors.green, 'color_picker_green'),
                  (const Color(0xFFFFEB3B), 'color_picker_yellow'),
                ].map(
                  (item) => GestureDetector(
                    key: Key(item.$2),
                    onTap: () => onConfigChanged(
                      activeConfig.copyWith(
                        color: ArgbColor(item.$1.toARGB32()),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: item.$1,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activeConfig.color.value == item.$1.toARGB32()
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: SizedBox(
                    width: 112,
                    height: 28,
                    child: Slider(
                      key: const Key('thickness_slider'),
                      value: activeConfig.strokeWidth.clamp(1, 32),
                      min: 1,
                      max: 32,
                      onChanged: (value) => onConfigChanged(
                        activeConfig.copyWith(strokeWidth: value),
                      ),
                    ),
                  ),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: SizedBox(
                    width: 92,
                    height: 28,
                    child: Slider(
                      key: const Key('opacity_slider'),
                      value: activeConfig.opacity.clamp(0.1, 1),
                      min: 0.1,
                      max: 1,
                      onChanged: (value) => onConfigChanged(
                        activeConfig.copyWith(opacity: value),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('preset_fine_pen'),
                  tooltip: 'Fine pen',
                  icon: const Icon(Icons.line_weight),
                  onPressed: () => _applyPreset(
                    ToolConfig.defaultPen.copyWith(strokeWidth: 1.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required BuildContext context,
    required Key key,
    required IconData icon,
    required String label,
    required WritingToolType toolType,
  }) {
    final isSelected = activeConfig.toolType == toolType;
    return Tooltip(
      message: label,
      child: IconButton(
        key: key,
        icon: Icon(icon),
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        style: isSelected
            ? IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.15),
              )
            : null,
        onPressed: () => _selectTool(toolType),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    final colors = [
      (Colors.black, 'color_picker_black'),
      (Colors.blue, 'color_picker_blue'),
      (Colors.red, 'color_picker_red'),
      (Colors.green, 'color_picker_green'),
      (const Color(0xFFFFEB3B), 'color_picker_yellow'),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors.map((item) {
        final color = item.$1;
        final keyStr = item.$2;
        final isSelected = activeConfig.color.value == color.toARGB32();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: GestureDetector(
            key: Key(keyStr),
            onTap: () {
              onConfigChanged(
                activeConfig.copyWith(color: ArgbColor(color.toARGB32())),
              );
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isSelected ? 2.5 : 1.0,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThicknessSelector(BuildContext context) {
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
            min: 1.0,
            max: 32.0,
            onChanged: (val) {
              onConfigChanged(activeConfig.copyWith(strokeWidth: val));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOpacitySelector(BuildContext context) {
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
            max: 1.0,
            onChanged: (val) {
              onConfigChanged(activeConfig.copyWith(opacity: val));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPresetsDropdown() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          key: const Key('preset_fine_pen'),
          onPressed: () =>
              _applyPreset(ToolConfig.defaultPen.copyWith(strokeWidth: 1.5)),
          child: const Text('Fine Pen', style: TextStyle(fontSize: 12)),
        ),
        TextButton(
          key: const Key('preset_marker'),
          onPressed: () =>
              _applyPreset(ToolConfig.defaultPen.copyWith(strokeWidth: 6.0)),
          child: const Text('Marker', style: TextStyle(fontSize: 12)),
        ),
        TextButton(
          key: const Key('preset_chisel_highlighter'),
          onPressed: () => _applyPreset(
            ToolConfig.defaultHighlighter.copyWith(strokeWidth: 20.0),
          ),
          child: const Text('Chisel', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildEraserControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChoiceChip(
          key: const Key('eraser_size_small'),
          label: const Text('Small Eraser'),
          selected: activeConfig.eraserSize == EraserSize.small,
          onSelected: (selected) {
            if (selected) {
              onConfigChanged(
                activeConfig.copyWith(eraserSize: EraserSize.small),
              );
            }
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          key: const Key('eraser_size_large'),
          label: const Text('Large Eraser'),
          selected: activeConfig.eraserSize == EraserSize.large,
          onSelected: (selected) {
            if (selected) {
              onConfigChanged(
                activeConfig.copyWith(eraserSize: EraserSize.large),
              );
            }
          },
        ),
      ],
    );
  }
}
