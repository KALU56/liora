import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../notes/domain/models/note_model.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({super.key});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  NoteModel? _existingNote;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is NoteModel) {
        _existingNote = args;
        _titleController.text = args.title;
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final noteTitle = title.isEmpty ? 'Untitled Note' : title;
    Navigator.of(context).pop({
      'id': _existingNote?.id,
      'title': noteTitle,
      'date': 'Today',
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingNote != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? _titleController.text : 'Create New Note'),
        actions: [
          IconButton(
            key: const Key('save_editor_button'),
            icon: const Icon(Icons.check),
            onPressed: _submit,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              key: const Key('editor_title_input'),
              controller: _titleController,
              labelText: 'Note Title',
              hintText: 'e.g. Biology Lecture 1',
              autofocus: !isEditing,
              onChanged: (val) {
                setState(() {});
              },
            ),
            AppSpacing.gapLg,
            Expanded(
              child: Container(
                width: double.infinity,
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    AppSpacing.gapMd,
                    Text(
                      'Note Canvas Workspace',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppSpacing.gapSm,
                    Text(
                      'Note ID: ${_existingNote?.id ?? "New"}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.gapLg,
            AppButton(
              key: const Key('submit_create_note_button'),
              label: isEditing ? 'Save Changes' : 'Create Note',
              isFullWidth: true,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
