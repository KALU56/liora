import 'package:flutter/material.dart';
import 'package:notability_clone/core/theme/app_spacing.dart';

/// A themed, consistently sized button for the floating editor toolbar.
class EditorToolbarButton extends StatelessWidget {
  const EditorToolbarButton({
    super.key,
    required this.buttonKey,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.active = false,
    this.label,
  });

  final Key buttonKey;
  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;
  final bool active;
  final String? label;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      key: buttonKey,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      onTap: onPressed,
      child: AnimatedContainer(
        duration: AppSpacing.toolbarAnimationDuration,
        width: AppSpacing.touchTarget,
        height: AppSpacing.touchTarget,
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary.withValues(alpha: .12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Center(
          child: label == null
              ? IconTheme.merge(
                  data: IconThemeData(
                    size: AppSpacing.toolbarIconSize,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  child: icon,
                )
              : Text(
                  label ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppSpacing.toolbarLabelFontSize,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    ),
  );
}
