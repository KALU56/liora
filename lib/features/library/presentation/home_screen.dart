import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import 'widgets/empty_library_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _notes = [];

  void _navigateToCreateNote() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.editor);
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _notes.add(result);
      });
    }
  }

  void _openNoteEditor(Map<String, dynamic> note) {
    Navigator.of(context).pushNamed(AppRoutes.noteEditor, arguments: note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search Notes',
          ),
        ],
      ),
      body: _notes.isEmpty
          ? EmptyLibraryView(onCreateNote: _navigateToCreateNote)
          : ListView.separated(
              padding: AppSpacing.paddingLg,
              itemCount: _notes.length,
              separatorBuilder: (context, index) => AppSpacing.gapMd,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  key: Key('note_card_$index'),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.description_outlined),
                    ),
                    title: Text(
                      note['title'] ?? 'Untitled Note',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Modified: ${note['date'] ?? 'Just now'} • 1 page',
                    ),
                    onTap: () => _openNoteEditor(note),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        key: const Key('create_note_fab'),
        onPressed: _navigateToCreateNote,
        tooltip: 'Create Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
