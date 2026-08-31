import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';

class EmptyLibraryView extends StatelessWidget {
  final VoidCallback onCreateNote;

  const EmptyLibraryView({super.key, required this.onCreateNote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_add_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            AppSpacing.gapLg,
            Text(
              'No Notes Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapSm,
            Text(
              'Create your first notebook to start writing, drawing, and organizing your thoughts.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.brightness == Brightness.light
                    ? AppColors.lightTextSecondary
                    : AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapXl,
            AppButton(
              key: const Key('create_first_note_button'),
              label: 'Create Note',
              icon: Icons.add,
              onPressed: onCreateNote,
            ),
          ],
        ),
      ),
    );
  }
}
