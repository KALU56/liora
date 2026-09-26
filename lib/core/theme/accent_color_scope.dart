import 'package:flutter/material.dart';

class AccentColorScope extends InheritedWidget {
  const AccentColorScope({
    super.key,
    required this.accentColor,
    required this.onAccentChanged,
    required super.child,
  });

  final Color accentColor;
  final ValueChanged<Color> onAccentChanged;

  static AccentColorScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AccentColorScope>();
    assert(scope != null, 'AccentColorScope is missing above this context.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AccentColorScope oldWidget) {
    return accentColor != oldWidget.accentColor;
  }
}
