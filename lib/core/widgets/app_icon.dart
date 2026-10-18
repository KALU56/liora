import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays a themed SVG icon and keeps a Material fallback for asset errors.
class AppIcon extends StatelessWidget {
  const AppIcon(this.assetPath, {super.key, this.size = 24});

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.broken_image_outlined, size: size, color: color),
    );
  }
}
