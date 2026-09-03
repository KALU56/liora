import 'package:flutter/material.dart';

import '../models/writing_tool.dart';

class WritingToolsToolbar extends StatelessWidget {
  final ToolConfig activeConfig;
  final ValueChanged<ToolConfig> onConfigChanged;

  const WritingToolsToolbar({
    super.key,
    required this.activeConfig,
    required this.onConfigChanged,
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
        newConfig = activeConfig.copyWith(
          toolType: WritingToolType.eraser,
        );
        break;
    }
    onConfigChanged(newConfig);
  }

  void _applyPreset(ToolConfig preset) {
    onConfigChanged(preset);
  }

  @override
  Widget build(BuildContext context) {
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
                key: const Key('tool_pen'),
                icon: Icons.edit,
                label: 'Pen',
                toolType: WritingToolType.pen,
              ),
              _buildToolButton(
                key: const Key('tool_pencil'),
                icon: Icons.mode_edit_outline,
                label: 'Pencil',
                toolType: WritingToolType.pencil,
              ),
              _buildToolButton(
                key: const Key('tool_highlighter'),
                icon: Icons.highlight,
                label: 'Highlighter',
                toolType: WritingToolType.highlighter,
              ),
              _buildToolButton(
                key: const Key('tool_eraser'),
                icon: Icons.auto_fix_high,
                label: 'Eraser',
                toolType: WritingToolType.eraser,
              ),

              const VerticalDivider(width: 16, indent: 8, endIndent: 8),

              // Tool-Specific Property Controls
              if (activeConfig.toolType == WritingToolType.eraser)
                _buildEraserControls()
              else ...[
                _buildColorPicker(),
                const SizedBox(width: 8),
                _buildThicknessSelector(),
                const SizedBox(width: 8),
                _buildOpacitySelector(),
                const SizedBox(width: 8),
                _buildPresetsDropdown(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
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
        color: isSelected ? Colors.blue : Colors.grey[700],
        style: isSelected
            ? IconButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.15))
            : null,
        onPressed: () => _selectTool(toolType),
      ),
    );
  }

  Widget _buildColorPicker() {
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
        final isSelected = activeConfig.color.value == color.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: GestureDetector(
            key: Key(keyStr),
            onTap: () {
              onConfigChanged(activeConfig.copyWith(color: color));
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[400]!,
                  width: isSelected ? 2.5 : 1.0,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThicknessSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.line_weight, size: 18, color: Colors.grey),
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

  Widget _buildOpacitySelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.opacity, size: 18, color: Colors.grey),
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
          onPressed: () => _applyPreset(ToolConfig.defaultPen.copyWith(strokeWidth: 1.5)),
          child: const Text('Fine Pen', style: TextStyle(fontSize: 12)),
        ),
        TextButton(
          key: const Key('preset_marker'),
          onPressed: () => _applyPreset(ToolConfig.defaultPen.copyWith(strokeWidth: 6.0)),
          child: const Text('Marker', style: TextStyle(fontSize: 12)),
        ),
        TextButton(
          key: const Key('preset_chisel_highlighter'),
          onPressed: () => _applyPreset(ToolConfig.defaultHighlighter.copyWith(strokeWidth: 20.0)),
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
              onConfigChanged(activeConfig.copyWith(eraserSize: EraserSize.small));
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
              onConfigChanged(activeConfig.copyWith(eraserSize: EraserSize.large));
            }
          },
        ),
      ],
    );
  }
}
