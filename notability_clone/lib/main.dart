import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/library/presentation/home_screen.dart';

void main() {
  runApp(const PaperNoteApp());
}

class PaperNoteApp extends StatelessWidget {
  const PaperNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaperNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
