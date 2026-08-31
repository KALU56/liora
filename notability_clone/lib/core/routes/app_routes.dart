import 'package:flutter/material.dart';
import '../../features/library/presentation/home_screen.dart';
import '../../features/library/presentation/new_note_screen.dart';

abstract class AppRoutes {
  static const String home = '/';
  static const String editor = '/editor';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      editor: (context) => const NewNoteScreen(),
    };
  }
}
