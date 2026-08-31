import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class RenameNoteDialog extends StatefulWidget {
  final String currentTitle;

  const RenameNoteDialog({
    super.key,
    required this.currentTitle,
  });

  @override
  State<RenameNoteDialog> createState() => _RenameNoteDialogState();
}

class _RenameNoteDialogState extends State<RenameNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onRename() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.of(context).pop(text);
    } else {
      Navigator.of(context).pop('Untitled Note');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const Key('rename_note_input'),
            controller: _controller,
            labelText: 'Note Title',
            autofocus: true,
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(null),
        ),
        AppButton(
          key: const Key('confirm_rename_button'),
          label: 'Rename',
          onPressed: _onRename,
        ),
      ],
    );
  }
}
