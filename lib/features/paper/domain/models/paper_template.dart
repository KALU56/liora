import '../../../../core/domain/value_objects/argb_color.dart';
import '../../../../core/domain/value_objects/page_size.dart';

/// Supported paper background patterns.
enum PaperPattern { blank, ruled, grid, dotted }

/// Supported page orientations.
enum PageOrientation { portrait, landscape }

/// Paper color options with presets.
class PaperColorOption {
  final String name;
  final ArgbColor color;

  const PaperColorOption({required this.name, required this.color});

  static const List<PaperColorOption> presets = [
    PaperColorOption(name: 'White', color: ArgbColor(0xFFFFFFFF)),
    PaperColorOption(name: 'Cream', color: ArgbColor(0xFFFFFDF0)),
    PaperColorOption(name: 'Canary', color: ArgbColor(0xFFFFF9C4)),
    PaperColorOption(name: 'Soft Gray', color: ArgbColor(0xFFF5F5F7)),
    PaperColorOption(name: 'Soft Blue', color: ArgbColor(0xFFE8F0FE)),
    PaperColorOption(name: 'Soft Green', color: ArgbColor(0xFFE6F4EA)),
    PaperColorOption(name: 'Dark', color: ArgbColor(0xFF1E1E1E)),
  ];
}

/// Configuration data structure for page background paper template.
class PaperTemplate {
  final PaperPattern pattern;
  final ArgbColor backgroundColor;
  final PageOrientation orientation;
  final double lineSpacing;
  final double gridSize;
  final double dotSpacing;
  final double dotRadius;
  final ArgbColor? lineColor;
  final double baseWidth;
  final double baseHeight;

  const PaperTemplate({
    this.pattern = PaperPattern.blank,
    this.backgroundColor = const ArgbColor(0xFFFFFFFF),
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
  PageSize get pageSize => PageSize(width, height);

  /// Effective color used to render guidelines or dots.
  /// Automatically picks a contrasting color if custom [lineColor] is not set.
  ArgbColor get effectivePatternColor {
    if (lineColor != null) return lineColor!;
    final red = (backgroundColor.value >> 16) & 0xFF;
    final green = (backgroundColor.value >> 8) & 0xFF;
    final blue = backgroundColor.value & 0xFF;
    final double luminance = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luminance < 0.5
        ? const ArgbColor(0x55FFFFFF)
        : const ArgbColor(0x33000000);
  }

  PaperTemplate copyWith({
    PaperPattern? pattern,
    ArgbColor? backgroundColor,
    PageOrientation? orientation,
    double? lineSpacing,
    double? gridSize,
    double? dotSpacing,
    double? dotRadius,
    ArgbColor? lineColor,
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
