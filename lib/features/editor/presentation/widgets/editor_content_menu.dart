import 'package:flutter/material.dart';

/// Shows content actions without painting over the editor popover's ink layer.
class EditorContentMenu extends StatelessWidget {
  final VoidCallback onAddPhoto;
  final VoidCallback onAddFile;
  final VoidCallback onAddLink;

  const EditorContentMenu({
    super.key,
    required this.onAddPhoto,
    required this.onAddFile,
    required this.onAddLink,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _EditorContentAction(
        icon: Icons.image_outlined,
        label: 'Add photo',
        onTap: onAddPhoto,
      ),
      _EditorContentAction(
        icon: Icons.attach_file,
        label: 'Add file',
        onTap: onAddFile,
      ),
      _EditorContentAction(
        icon: Icons.link,
        label: 'Add link',
        onTap: onAddLink,
      ),
    ],
  );
}

class _EditorContentAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EditorContentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon),
          const SizedBox(width: 16),
          Text(label),
        ],
      ),
    ),
  );
}
