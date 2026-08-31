import 'package:flutter/material.dart';

import '../../features/library/presentation/home_screen.dart';
import '../../features/library/presentation/new_note_screen.dart';
import '../../features/notes/presentation/note_editor_screen.dart';

abstract class AppRoutes {
  static const String home = '/';
  static const String editor = '/editor';
  static const String noteEditor = '/note_editor';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      editor: (context) => const NewNoteScreen(),
      noteEditor: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map<String, dynamic>) {
          return NoteEditorScreen(
            title: args['title'] as String? ?? 'Untitled Note',
          );
        }
        return const NoteEditorScreen();
      },
    };
  }
}
