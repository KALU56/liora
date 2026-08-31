import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onPressed,
      padding: AppSpacing.paddingSm,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
