import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/models/writing_tool.dart';

/// Selects a writing tool while preserving each tool's current settings.
class WritingToolSelector extends StatelessWidget {
  final ToolConfig activeConfig;
  final ValueChanged<ToolConfig> onConfigChanged;
  final bool vertical;

  const WritingToolSelector({
    super.key,
    required this.activeConfig,
    required this.onConfigChanged,
    this.vertical = false,
  });

  static const _tools = <(WritingToolType, String, String)>[
    (WritingToolType.pen, AppIcons.pen, 'Pen'),
    (WritingToolType.pencil, AppIcons.pencil, 'Pencil'),
    (WritingToolType.highlighter, AppIcons.highlighter, 'Highlighter'),
    (WritingToolType.eraser, AppIcons.eraser, 'Eraser'),
    (WritingToolType.shape, AppIcons.shapes, 'Shapes'),
    (WritingToolType.ruler, '', 'Ruler'),
  ];

  ToolConfig _configForTool(WritingToolType toolType) {
    final defaultConfig = switch (toolType) {
      WritingToolType.pen => ToolConfig.defaultPen,
      WritingToolType.pencil => ToolConfig.defaultPencil,
      WritingToolType.highlighter => ToolConfig.defaultHighlighter,
      WritingToolType.eraser ||
      WritingToolType.shape ||
      WritingToolType.ruler => activeConfig,
    };
    final preservesSettings = activeConfig.toolType == toolType;
    return activeConfig.copyWith(
      toolType: toolType,
      color: preservesSettings ? activeConfig.color : defaultConfig.color,
      strokeWidth: preservesSettings
          ? activeConfig.strokeWidth
          : defaultConfig.strokeWidth,
      opacity: preservesSettings ? activeConfig.opacity : defaultConfig.opacity,
    );
  }

  Widget _buildButton(
    BuildContext context,
    (WritingToolType, String, String) tool,
  ) {
    final (toolType, icon, label) = tool;
    final isSelected = activeConfig.toolType == toolType;
    return Tooltip(
      message: label,
      child: IconButton(
        key: Key('tool_${toolType.name}'),
        icon: icon.isEmpty ? const Icon(Icons.straighten) : AppIcon(icon),
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        style: isSelected
            ? IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.15),
              )
            : null,
        onPressed: () => onConfigChanged(_configForTool(toolType)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Flex(
    direction: vertical ? Axis.vertical : Axis.horizontal,
    mainAxisSize: MainAxisSize.min,
    children: _tools.map((tool) => _buildButton(context, tool)).toList(),
  );
}
