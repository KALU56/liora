import 'package:flutter/material.dart';

/// Editable, persistable text content placed on a note page.
class NoteTextBlock {
  final String text;
  final String fontFamily;
  final double fontSize;
  final bool bold;
  final bool italic;
  final TextAlign alignment;
  final int colorValue;
  final double x;
  final double y;

  const NoteTextBlock({
    required this.text,
    this.fontFamily = 'Roboto',
    this.fontSize = 18,
    this.bold = false,
    this.italic = false,
    this.alignment = TextAlign.left,
    this.colorValue = 0xFF202124,
    this.x = 24,
    this.y = 24,
  });

  NoteTextBlock copyWith({
    String? text,
    String? fontFamily,
    double? fontSize,
    bool? bold,
    bool? italic,
    TextAlign? alignment,
    int? colorValue,
    double? x,
    double? y,
  }) => NoteTextBlock(
    text: text ?? this.text,
    fontFamily: fontFamily ?? this.fontFamily,
    fontSize: fontSize ?? this.fontSize,
    bold: bold ?? this.bold,
    italic: italic ?? this.italic,
    alignment: alignment ?? this.alignment,
    colorValue: colorValue ?? this.colorValue,
    x: x ?? this.x,
    y: y ?? this.y,
  );
}
