import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/note_model.dart';
import 'note_page_thumbnail.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final bool isGrid;
  final bool isTrashed;
  final VoidCallback? onRestore;
  final VoidCallback? onPermanentlyDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    this.isGrid = false,
    this.isTrashed = false,
    this.onRestore,
    this.onPermanentlyDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isGrid) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: note.pages.isEmpty
                      ? ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.description_outlined,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : NotePageThumbnail(page: note.pages.first),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${note.pageCount} ${note.pageCount == 1 ? 'page' : 'pages'} • ${_formatDate(note.modifiedDate)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      key: Key('note_menu_${note.id}'),
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        if (value == 'rename') onRename();
                        if (value == 'delete') {
                          isTrashed ? onPermanentlyDelete?.call() : onDelete();
                        }
                        if (value == 'restore') onRestore?.call();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Rename'),
                            ],
                          ),
                        ),
                        if (isTrashed)
                          const PopupMenuItem(
                            value: 'restore',
                            child: Row(
                              children: [
                                Icon(Icons.restore, size: 18),
                                SizedBox(width: 8),
                                Text('Restore'),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  isTrashed
                                      ? 'Delete permanently'
                                      : 'Move to trash',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.notes_rounded, color: theme.colorScheme.primary),
        ),
        title: Text(
          note.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${note.pageCount} ${note.pageCount == 1 ? 'page' : 'pages'} • ${_formatDate(note.modifiedDate)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          key: Key('note_menu_${note.id}'),
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'rename') onRename();
            if (value == 'delete') {
              isTrashed ? onPermanentlyDelete?.call() : onDelete();
            }
            if (value == 'restore') onRestore?.call();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              key: Key('menu_rename_option'),
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Rename'),
                ],
              ),
            ),
            if (isTrashed)
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.restore, size: 18),
                    SizedBox(width: 8),
                    Text('Restore'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              key: Key('menu_delete_option'),
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isTrashed ? 'Delete permanently' : 'Move to trash',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
