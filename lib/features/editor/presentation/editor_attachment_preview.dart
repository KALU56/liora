part of 'new_note_screen.dart';

extension _EditorAttachmentPreview on _NewNoteScreenState {
  Future<void> _leaveEditor() async {
    _autosaveNote();
    await _notes.flush();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _showAddContentMenu() {
    _openPopover(EditorPopover.content);
  }

  Future<void> _addLink() async {
    var enteredUrl = '';
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a link'),
        content: TextField(
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'https://example.com'),
          onChanged: (value) => enteredUrl = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, enteredUrl),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (value == null || !mounted) return;
    final normalized = value.trim().startsWith('http')
        ? value.trim()
        : 'https://${value.trim()}';
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasAuthority) {
      _showMediaError(message: 'Enter a valid web link.');
      return;
    }
    _replaceCurrentPage(
      _currentPage.copyWith(
        attachments: [..._currentPage.attachments, 'url:$normalized'],
      ),
    );
    _updateEditorState(() => _activePopover = null);
  }

  Widget _attachmentPreview(String path) {
    if (path.startsWith('url:')) {
      final url = path.substring(4);
      return Material(
        color: Colors.transparent,
        child: ListTile(
          leading: const Icon(Icons.link),
          title: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () async {
            try {
              if (!await _attachmentStorage.openLink(url)) {
                _showMediaError(message: 'Could not open this link.');
              }
            } catch (_) {
              _showMediaError(message: 'Could not open this link.');
            }
          },
        ),
      );
    }
    if (path.startsWith('attachment:')) {
      return FutureBuilder<StoredAttachment?>(
        future: _attachmentStorage.load(path),
        builder: (context, snapshot) {
          final attachment = snapshot.data;
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (attachment == null) {
            return const ListTile(
              leading: Icon(Icons.broken_image_outlined),
              title: Text('Attachment is unavailable'),
            );
          }
          final name = attachment.name;
          final lowerName = name.toLowerCase();
          if (attachment.mimeType.startsWith('image/') ||
              lowerName.endsWith('.png') ||
              lowerName.endsWith('.jpg') ||
              lowerName.endsWith('.jpeg') ||
              lowerName.endsWith('.webp')) {
            return Image.memory(
              attachment.bytes,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Text('$name is unavailable'),
            );
          }
          final isAudio =
              attachment.mimeType.startsWith('audio/') ||
              lowerName.endsWith('.m4a') ||
              lowerName.endsWith('.mp3') ||
              lowerName.endsWith('.wav') ||
              lowerName.endsWith('.aac');
          return ListTile(
            leading: Icon(
              isAudio ? Icons.audio_file : Icons.insert_drive_file_outlined,
            ),
            title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: isAudio
                ? null
                : () async {
                    try {
                      if (!await _attachmentStorage.openFile(path)) {
                        _showMediaError(message: 'Could not open this file.');
                      }
                    } catch (_) {
                      _showMediaError(message: 'Could not open this file.');
                    }
                  },
            trailing: isAudio
                ? IconButton(
                    icon: const Icon(Icons.play_arrow),
                    tooltip: 'Play audio',
                    onPressed: () async {
                      try {
                        await _media.playAudioBytes(
                          attachment.bytes,
                          mimeType: attachment.mimeType,
                        );
                      } catch (_) {
                        _showMediaError();
                      }
                    },
                  )
                : null,
          );
        },
      );
    }
    final fileUri = Uri.file(path);
    final name = fileUri.pathSegments.isEmpty
        ? path
        : fileUri.pathSegments.last;
    if (name.toLowerCase().endsWith('.png') ||
        name.toLowerCase().endsWith('.jpg') ||
        name.toLowerCase().endsWith('.jpeg') ||
        name.toLowerCase().endsWith('.webp')) {
      return Image.file(
        File(path),
        height: 180,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text('$name is unavailable'),
      );
    }
    final isAudio =
        name.toLowerCase().endsWith('.m4a') ||
        name.toLowerCase().endsWith('.mp3') ||
        name.toLowerCase().endsWith('.wav') ||
        name.toLowerCase().endsWith('.aac');
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          isAudio ? Icons.audio_file : Icons.insert_drive_file_outlined,
        ),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: isAudio
            ? null
            : () async {
                try {
                  if (!await _attachmentStorage.openFile(path)) {
                    _showMediaError(message: 'Could not open this file.');
                  }
                } catch (_) {
                  _showMediaError(message: 'Could not open this file.');
                }
              },
        trailing: isAudio
            ? IconButton(
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Play audio',
                onPressed: () async {
                  try {
                    await _media.playAudio(path);
                  } catch (_) {
                    _showMediaError();
                  }
                },
              )
            : null,
      ),
    );
  }
}
