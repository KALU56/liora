import 'package:flutter/material.dart';

import '../../domain/models/writing_tool.dart';
import 'writing_tool_selector.dart';
import 'writing_tool_settings.dart';

/// Provides responsive tool selection and settings for the writing canvas.
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

  @override
  Widget build(BuildContext context) {
    final selector = WritingToolSelector(
      activeConfig: activeConfig,
      onConfigChanged: onConfigChanged,
      vertical: vertical,
    );
    final settings = WritingToolSettings(
      activeConfig: activeConfig,
      onConfigChanged: onConfigChanged,
      vertical: vertical,
    );
    if (vertical) {
      return Card(
        margin: EdgeInsets.zero,
        child: SizedBox(
          width: 76,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [selector, const Divider(height: 8), settings],
            ),
          ),
        ),
      );
    }
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              selector,
              const VerticalDivider(width: 16, indent: 8, endIndent: 8),
              settings,
            ],
          ),
        ),
      ),
    );
  }
}
