import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/paper_template.dart';
import 'paper_ui_metadata.dart';

/// Segmented grid/list selector for paper pattern (Blank, Ruled, Grid, Dotted).
class PaperPatternSelector extends StatelessWidget {
  final PaperPattern selectedPattern;
  final ValueChanged<PaperPattern> onPatternChanged;

  const PaperPatternSelector({
    super.key,
    required this.selectedPattern,
    required this.onPatternChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paper Pattern', style: Theme.of(context).textTheme.titleSmall),
        AppSpacing.gapSm,
        Row(
          children: PaperPattern.values.map((pattern) {
            final metadata = patternMetadata(pattern);
            final isSelected = pattern == selectedPattern;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: InkWell(
                  key: Key('paper_pattern_${pattern.name}'),
                  onTap: () => onPatternChanged(pattern),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          metadata.icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        AppSpacing.gapXs,
                        Text(
                          metadata.label,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
