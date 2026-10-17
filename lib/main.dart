import 'package:flutter/material.dart';

import 'core/dependencies/app_dependencies.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/accent_color_scope.dart';
import 'core/theme/accent_color_storage.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appDependencies.initialize();
  runApp(const PaperNoteApp());
}

class PaperNoteApp extends StatefulWidget {
  const PaperNoteApp({
    super.key,
    this.initialAccentColor,
    this.accentColorStorage,
  });

  final Color? initialAccentColor;
  final AccentColorStorage? accentColorStorage;

  @override
  State<PaperNoteApp> createState() => _PaperNoteAppState();
}

class _PaperNoteAppState extends State<PaperNoteApp> {
  late Color _accentColor;

  AccentColorStorage get _storage =>
      widget.accentColorStorage ?? appDependencies.accentColorStorage;

  @override
  void initState() {
    super.initState();
    _accentColor =
        widget.initialAccentColor ?? appDependencies.cachedAccentColor;
  }

  void _onAccentChanged(Color color) {
    setState(() => _accentColor = color);
    appDependencies.cachedAccentColor = color;
    _storage.saveAccentColor(color);
  }

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
        onAccentChanged: _onAccentChanged,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
