import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/notes/data/repositories/note_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appNoteRepository.initialize();
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
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
