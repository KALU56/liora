import 'package:flutter/material.dart';

abstract class ColorContrast {
  static Color readableForeground(Color background) {
    const candidates = [Colors.black, Colors.white];
    return candidates.reduce(
      (best, candidate) =>
          contrastRatio(background, candidate) > contrastRatio(background, best)
          ? candidate
          : best,
    );
  }

  static double contrastRatio(Color first, Color second) {
    final lighter = first.computeLuminance() > second.computeLuminance()
        ? first.computeLuminance()
        : second.computeLuminance();
    final darker = first.computeLuminance() > second.computeLuminance()
        ? second.computeLuminance()
        : first.computeLuminance();
    return (lighter + 0.05) / (darker + 0.05);
  }
}
