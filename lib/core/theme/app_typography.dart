import 'package:flutter/material.dart';

/// Centralized typography system.
abstract class AppTypography {
  static const TextStyle appTitle = TextStyle(
    fontSize: 27.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.15,
    fontFamily: 'serif',
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.0,
  );

  static const TextStyle smallText = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
