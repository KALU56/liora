import 'package:flutter/material.dart';

import '../../domain/models/paper_template.dart';

class PaperPatternMetadata {
  const PaperPatternMetadata({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}

PaperPatternMetadata patternMetadata(PaperPattern pattern) {
  return switch (pattern) {
    PaperPattern.blank => const PaperPatternMetadata(
        label: 'Blank',
        description: 'Plain paper without guidelines',
        icon: Icons.crop_din,
      ),
    PaperPattern.ruled => const PaperPatternMetadata(
        label: 'Ruled',
        description: 'Horizontal guidelines for handwriting',
        icon: Icons.format_align_left,
      ),
    PaperPattern.grid => const PaperPatternMetadata(
        label: 'Grid',
        description: 'Square grid cells for alignment & math',
        icon: Icons.grid_on,
      ),
    PaperPattern.dotted => const PaperPatternMetadata(
        label: 'Dotted',
        description: 'Evenly spaced dots for bullet journaling',
        icon: Icons.grain,
      ),
  };
}

IconData orientationIcon(PageOrientation orientation) {
  return switch (orientation) {
    PageOrientation.portrait => Icons.crop_portrait,
    PageOrientation.landscape => Icons.crop_landscape,
  };
}

String orientationLabel(PageOrientation orientation) {
  return switch (orientation) {
    PageOrientation.portrait => 'Portrait',
    PageOrientation.landscape => 'Landscape',
  };
}
