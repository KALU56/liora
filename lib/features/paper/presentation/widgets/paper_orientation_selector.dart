import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/paper_template.dart';
import 'paper_ui_metadata.dart';

/// Toggle selector for Page Orientation (Portrait / Landscape).
class PaperOrientationSelector extends StatelessWidget {
  final PageOrientation selectedOrientation;
  final ValueChanged<PageOrientation> onOrientationChanged;

  const PaperOrientationSelector({
    super.key,
    required this.selectedOrientation,
    required this.onOrientationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Page Orientation', style: Theme.of(context).textTheme.titleSmall),
        AppSpacing.gapSm,
        Row(
          children: PageOrientation.values.map((orientation) {
            final label = orientationLabel(orientation);
            final isSelected = orientation == selectedOrientation;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: InkWell(
                  key: Key('orientation_${orientation.name}'),
                  onTap: () => onOrientationChanged(orientation),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          orientationIcon(orientation),
                          size: 20,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        AppSpacing.gapSm,
                        Text(
                          label,
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
