import 'package:flutter/material.dart';

/// Supported paper background patterns.
enum PaperPattern {
  blank('Blank', 'Plain paper without guidelines', Icons.crop_din),
  ruled(
    'Ruled',
    'Horizontal guidelines for handwriting',
    Icons.format_align_left,
  ),
  grid('Grid', 'Square grid cells for alignment & math', Icons.grid_on),
  dotted('Dotted', 'Evenly spaced dots for bullet journaling', Icons.grain);

  final String displayName;
  final String description;
  final IconData icon;

  const PaperPattern(this.displayName, this.description, this.icon);
}

/// Supported page orientations.
enum PageOrientation {
  portrait('Portrait', Icons.crop_portrait),
  landscape('Landscape', Icons.crop_landscape);

  final String displayName;
  final IconData icon;

  const PageOrientation(this.displayName, this.icon);
}

/// Paper color options with presets.
class PaperColorOption {
  final String name;
  final Color color;

  const PaperColorOption({required this.name, required this.color});

  static const List<PaperColorOption> presets = [
    PaperColorOption(name: 'White', color: Color(0xFFFFFFFF)),
    PaperColorOption(name: 'Cream', color: Color(0xFFFFFDF0)),
    PaperColorOption(name: 'Canary', color: Color(0xFFFFF9C4)),
    PaperColorOption(name: 'Soft Gray', color: Color(0xFFF5F5F7)),
    PaperColorOption(name: 'Soft Blue', color: Color(0xFFE8F0FE)),
    PaperColorOption(name: 'Soft Green', color: Color(0xFFE6F4EA)),
    PaperColorOption(name: 'Dark', color: Color(0xFF1E1E1E)),
  ];
}

/// Configuration data structure for page background paper template.
class PaperTemplate {
  final PaperPattern pattern;
  final Color backgroundColor;
  final PageOrientation orientation;
  final double lineSpacing;
  final double gridSize;
  final double dotSpacing;
  final double dotRadius;
  final Color? lineColor;
  final double baseWidth;
  final double baseHeight;

  const PaperTemplate({
    this.pattern = PaperPattern.blank,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.orientation = PageOrientation.portrait,
    this.lineSpacing = 32.0,
    this.gridSize = 32.0,
    this.dotSpacing = 32.0,
    this.dotRadius = 1.5,
    this.lineColor,
    this.baseWidth = 612.0,
    this.baseHeight = 792.0,
  });

  /// Page width based on orientation.
  double get width =>
      orientation == PageOrientation.portrait ? baseWidth : baseHeight;

  /// Page height based on orientation.
  double get height =>
      orientation == PageOrientation.portrait ? baseHeight : baseWidth;

  /// Size object matching page dimensions.
  Size get pageSize => Size(width, height);

  /// Effective color used to render guidelines or dots.
  /// Automatically picks a contrasting color if custom [lineColor] is not set.
  Color get effectivePatternColor {
    if (lineColor != null) return lineColor!;
    final double luminance = backgroundColor.computeLuminance();
    return luminance < 0.5
        ? const Color(0x55FFFFFF) // Light lines on dark paper
        : const Color(0x33000000); // Subtle dark lines on light paper
  }

  PaperTemplate copyWith({
    PaperPattern? pattern,
    Color? backgroundColor,
    PageOrientation? orientation,
    double? lineSpacing,
    double? gridSize,
    double? dotSpacing,
    double? dotRadius,
    Color? lineColor,
    double? baseWidth,
    double? baseHeight,
  }) {
    return PaperTemplate(
      pattern: pattern ?? this.pattern,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      orientation: orientation ?? this.orientation,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      gridSize: gridSize ?? this.gridSize,
      dotSpacing: dotSpacing ?? this.dotSpacing,
      dotRadius: dotRadius ?? this.dotRadius,
      lineColor: lineColor ?? this.lineColor,
      baseWidth: baseWidth ?? this.baseWidth,
      baseHeight: baseHeight ?? this.baseHeight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pattern': pattern.name,
      'backgroundColor': backgroundColor.toARGB32(),
      'orientation': orientation.name,
      'lineSpacing': lineSpacing,
      'gridSize': gridSize,
      'dotSpacing': dotSpacing,
      'dotRadius': dotRadius,
      'lineColor': lineColor?.toARGB32(),
      'baseWidth': baseWidth,
      'baseHeight': baseHeight,
    };
  }

  factory PaperTemplate.fromJson(Map<String, dynamic> json) {
    return PaperTemplate(
      pattern: PaperPattern.values.firstWhere(
        (e) => e.name == json['pattern'],
        orElse: () => PaperPattern.blank,
      ),
      backgroundColor: Color(json['backgroundColor'] as int? ?? 0xFFFFFFFF),
      orientation: PageOrientation.values.firstWhere(
        (e) => e.name == json['orientation'],
        orElse: () => PageOrientation.portrait,
      ),
      lineSpacing: (json['lineSpacing'] as num?)?.toDouble() ?? 32.0,
      gridSize: (json['gridSize'] as num?)?.toDouble() ?? 32.0,
      dotSpacing: (json['dotSpacing'] as num?)?.toDouble() ?? 32.0,
      dotRadius: (json['dotRadius'] as num?)?.toDouble() ?? 1.5,
      lineColor: json['lineColor'] != null
          ? Color(json['lineColor'] as int)
          : null,
      baseWidth: (json['baseWidth'] as num?)?.toDouble() ?? 612.0,
      baseHeight: (json['baseHeight'] as num?)?.toDouble() ?? 792.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaperTemplate &&
        other.pattern == pattern &&
        other.backgroundColor == backgroundColor &&
        other.orientation == orientation &&
        other.lineSpacing == lineSpacing &&
        other.gridSize == gridSize &&
        other.dotSpacing == dotSpacing &&
        other.dotRadius == dotRadius &&
        other.lineColor == lineColor &&
        other.baseWidth == baseWidth &&
        other.baseHeight == baseHeight;
  }

  @override
  int get hashCode {
    return Object.hash(
      pattern,
      backgroundColor,
      orientation,
      lineSpacing,
      gridSize,
      dotSpacing,
      dotRadius,
      lineColor,
      baseWidth,
      baseHeight,
    );
  }
}
