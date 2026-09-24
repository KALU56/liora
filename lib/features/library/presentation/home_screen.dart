import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../notes/application/notes_dependencies.dart';
import '../../notes/application/notes_use_cases.dart';
import '../../notes/domain/models/note_model.dart';
import '../../notes/domain/models/note_page.dart';
import '../../notes/domain/repositories/notes_repository.dart';
import '../../notes/presentation/widgets/delete_note_dialog.dart';
import '../../notes/presentation/widgets/note_card.dart';
import '../../notes/presentation/widgets/rename_note_dialog.dart';
import 'widgets/empty_library_view.dart';

class HomeScreen extends StatefulWidget {
  final NotesRepository? repository;
  final NotesUseCases? useCases;

  const HomeScreen({super.key, this.repository, this.useCases});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final NotesUseCases _notes;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isGridView = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _notes =
        widget.useCases ??
        (widget.repository == null
            ? appNotesUseCases
            : NotesUseCases(widget.repository!));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCreateNote() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.editor);
    if (result != null && result is Map<String, dynamic>) {
      final title = result['title'] as String?;
      setState(() {
        final note = _notes.createNote(title: title);
        final pages = result['pages'];
        if (pages is List<NotePage>) {
          _notes.updateNote(note.copyWith(pages: pages));
        }
      });
    }
  }

  void _onOpenNote(NoteModel note) async {
    final result = await Navigator.of(context)
        .pushNamed(AppRoutes.editor, arguments: note);
    if (result != null && result is Map<String, dynamic>) {
      final updatedTitle = result['title'] as String?;
      final pages = result['pages'];
      if (updatedTitle != null || pages is List<NotePage>) {
        setState(() {
          final currentNote = _notes.getNoteById(note.id) ?? note;
          _notes.updateNote(
            currentNote.copyWith(
              title: updatedTitle ?? currentNote.title,
              pages: pages is List<NotePage> ? pages : currentNote.pages,
            ),
          );
        });
      }
    }
  }

  void _onRenameNote(NoteModel note) async {
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => RenameNoteDialog(currentTitle: note.title),
    );
    if (newTitle != null) {
      setState(() {
        _notes.renameNote(note.id, newTitle);
      });
    }
  }

  void _onDeleteNote(NoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteNoteDialog(noteTitle: note.title),
    );
    if (confirmed == true) {
      setState(() {
        _notes.deleteNote(note.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _notes.searchNotes(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                key: const Key('search_notes_field'),
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search notes by title...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              )
            : const Text(AppConstants.appName),
        centerTitle: false,
        actions: [
          IconButton(
            key: const Key('toggle_search_button'),
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
            tooltip: _isSearching ? 'Close Search' : 'Search Notes',
          ),
          IconButton(
            key: const Key('toggle_view_button'),
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'Switch to List' : 'Switch to Grid',
          ),
        ],
      ),
      body: _notes.notes.isEmpty
          ? EmptyLibraryView(onCreateNote: _onCreateNote)
          : filteredNotes.isEmpty
          ? Center(
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Text(
                  'No notes found matching "$_searchQuery"',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : _isGridView
          ? GridView.builder(
              padding: AppSpacing.paddingLg,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return NoteCard(
                  key: Key('note_card_${note.id}'),
                  note: note,
                  isGrid: true,
                  onTap: () => _onOpenNote(note),
                  onRename: () => _onRenameNote(note),
                  onDelete: () => _onDeleteNote(note),
                );
              },
            )
          : ListView.separated(
              padding: AppSpacing.paddingLg,
              itemCount: filteredNotes.length,
              separatorBuilder: (context, index) => AppSpacing.gapMd,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return NoteCard(
                  key: Key('note_card_${note.id}'),
                  note: note,
                  isGrid: false,
                  onTap: () => _onOpenNote(note),
                  onRename: () => _onRenameNote(note),
                  onDelete: () => _onDeleteNote(note),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        key: const Key('create_note_fab'),
        onPressed: _onCreateNote,
        tooltip: 'Create Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
