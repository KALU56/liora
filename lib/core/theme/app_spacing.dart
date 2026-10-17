import 'package:flutter/material.dart';

/// Centralized spacing system: 4, 8, 12, 16, 24, 32.
abstract class AppSpacing {
  static const double floatingControlElevation = 8.0;
  static const double floatingControlShadowAlpha = 0.14;
  static const double floatingControlCornerRadius = 24.0;
  static const double floatingControlPadding = 4.0;
  static const double pageControlRailWidth = 56.0;
  static const double pageControlRailMaxHeight = 304.0;
  static const double touchTarget = 48.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // EdgeInsets helpers
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  // SizedBox gap helpers
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);
}
