import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class DeleteNoteDialog extends StatelessWidget {
  final String noteTitle;

  const DeleteNoteDialog({
    super.key,
    required this.noteTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Note'),
      content: Text(
        'Are you sure you want to delete "$noteTitle"? This action cannot be undone.',
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          key: const Key('confirm_delete_button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
