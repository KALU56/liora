import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/color_contrast.dart';
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
        Text('Paper Color', style: Theme.of(context).textTheme.titleSmall),
        AppSpacing.gapSm,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: PaperColorOption.presets.map((preset) {
              final isSelected = selectedColor.toARGB32() == preset.color.value;
              final presetColor = Color(preset.color.value);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Tooltip(
                  message: preset.name,
                  child: InkWell(
                    key: Key(
                      'paper_color_${preset.name.toLowerCase().replaceAll(' ', '_')}',
                    ),
                    onTap: () => onColorChanged(presetColor),
                    borderRadius: BorderRadius.circular(AppSpacing.xl),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: presetColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: isSelected ? 3.0 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow
                                .withValues(alpha: 0.08),
                            blurRadius: AppSpacing.sm,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 20,
                              color: ColorContrast.readableForeground(
                                presetColor,
                              ),
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
