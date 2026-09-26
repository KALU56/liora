import 'package:flutter/material.dart';

class AppAccent {
  const AppAccent(this.name, this.color);

  final String name;
  final Color color;
}

abstract class AccentPalette {
  static const List<AppAccent> options = [
    AppAccent('Sage', Color(0xFF626E55)),
    AppAccent('Terracotta', Color(0xFF965F49)),
    AppAccent('Ocean', Color(0xFF506C73)),
    AppAccent('Berry', Color(0xFF795565)),
    AppAccent('Honey', Color(0xFF80612F)),
  ];

  static Color get defaultColor => options.first.color;
}
