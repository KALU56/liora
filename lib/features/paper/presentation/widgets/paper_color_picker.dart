import 'package:flutter/material.dart';

import '../../domain/models/paper_template.dart';

/// Palette widget for selecting paper background colors.
class PaperColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const PaperColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paper Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: PaperColorOption.presets.map((preset) {
              final isSelected =
                  selectedColor.toARGB32() == preset.color.toARGB32();
              final isDark = preset.color.computeLuminance() < 0.5;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Tooltip(
                  message: preset.name,
                  child: InkWell(
                    key: Key(
                      'paper_color_${preset.name.toLowerCase().replaceAll(' ', '_')}',
                    ),
                    onTap: () => onColorChanged(preset.color),
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: preset.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade400,
                          width: isSelected ? 3.0 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 20,
                              color: isDark ? Colors.white : Colors.black87,
                            )
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
