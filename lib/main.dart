import 'package:flutter/material.dart';

import 'core/dependencies/app_dependencies.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/accent_palette.dart';
import 'core/theme/accent_color_scope.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appDependencies.initialize();
  runApp(const PaperNoteApp());
}

class PaperNoteApp extends StatefulWidget {
  const PaperNoteApp({super.key});

  @override
  State<PaperNoteApp> createState() => _PaperNoteAppState();
}

class _PaperNoteAppState extends State<PaperNoteApp> {
  Color _accentColor = AccentPalette.defaultColor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaperNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(accent: _accentColor),
      darkTheme: AppTheme.darkTheme(accent: _accentColor),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      builder: (context, child) => AccentColorScope(
        accentColor: _accentColor,
        onAccentChanged: (color) => setState(() => _accentColor = color),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
