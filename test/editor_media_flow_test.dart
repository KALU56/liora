import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/features/editor/data/editor_media_service.dart';
import 'package:notability_clone/features/editor/presentation/new_note_screen.dart';
import 'package:notability_clone/features/notes/data/note_attachment_storage.dart';
import 'package:notability_clone/features/notes/data/repositories/note_repository.dart';
import 'package:notability_clone/features/notes/data/repositories/note_storage.dart';
import 'package:notability_clone/features/notes/domain/models/note_model.dart';
import 'package:notability_clone/features/notes/domain/models/note_page.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'photo and file picker results are attached to the current page',
    (tester) async {
      final repository = NoteRepository(storage: _MemoryNoteStorage());
      final attachments = _FakeAttachmentStorage();
      await tester.pumpWidget(
        MaterialApp(
          home: NewNoteScreen(
            repository: repository,
            attachmentStorage: attachments,
            mediaService: _FakeEditorMediaService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_content_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add file'));
      await tester.pumpAndSettle();

      final page = repository.notes.single.pages.single;
      expect(page.attachments, ['/kept/photo.png', '/kept/document.pdf']);
    },
  );

  testWidgets('speech results are written into the selected page text', (
    tester,
  ) async {
    final repository = NoteRepository(storage: _MemoryNoteStorage());
    await tester.pumpWidget(
      MaterialApp(
        home: NewNoteScreen(
          repository: repository,
          attachmentStorage: _FakeAttachmentStorage(),
          mediaService: _FakeEditorMediaService(speechAvailable: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('voice_input_button')));
    await tester.pumpAndSettle();

    expect(
      repository.notes.single.pages.single.textBlocks.single.text,
      'captured words',
    );
  });

  testWidgets('audio recording results are attached to the current page', (
    tester,
  ) async {
    final repository = NoteRepository(storage: _MemoryNoteStorage());
    await tester.pumpWidget(
      MaterialApp(
        home: NewNoteScreen(
          repository: repository,
          attachmentStorage: _FakeAttachmentStorage(),
          mediaService: _FakeEditorMediaService(recordingAvailable: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('expand_tools_button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Record audio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record audio'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Stop audio recording'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stop audio recording'));
    await tester.pumpAndSettle();

    expect(repository.notes.single.pages.single.attachments, ['recording.m4a']);
  });

  testWidgets('a denied microphone permission explains why recording stopped', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewNoteScreen(
          repository: NoteRepository(storage: _MemoryNoteStorage()),
          attachmentStorage: _FakeAttachmentStorage(),
          mediaService: _FakeEditorMediaService(recordingAvailable: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('expand_tools_button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Record audio'));
    await tester.tap(find.text('Record audio'));
    await tester.pumpAndSettle();

    expect(
      find.text('Microphone permission is needed to record audio.'),
      findsOneWidget,
    );
  });

  testWidgets('unavailable speech recognition explains the failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewNoteScreen(
          repository: NoteRepository(storage: _MemoryNoteStorage()),
          attachmentStorage: _FakeAttachmentStorage(),
          mediaService: _FakeEditorMediaService(speechAvailable: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('voice_input_button')));
    await tester.pumpAndSettle();

    expect(find.text('Speech recognition is not available.'), findsOneWidget);
  });

  testWidgets(
    'failed speech startup resets voice input and explains the failure',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NewNoteScreen(
            repository: NoteRepository(storage: _MemoryNoteStorage()),
            attachmentStorage: _FakeAttachmentStorage(),
            mediaService: _FakeEditorMediaService(
              speechAvailable: true,
              throwOnListen: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('voice_input_button')));
      await tester.pumpAndSettle();

      expect(find.text('Voice input could not start.'), findsOneWidget);
      expect(find.byKey(const Key('voice_input_button')), findsOneWidget);
    },
  );

  testWidgets('recording startup failure resets the recording control', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewNoteScreen(
          repository: NoteRepository(storage: _MemoryNoteStorage()),
          attachmentStorage: _FakeAttachmentStorage(),
          mediaService: _FakeEditorMediaService(throwOnRecordStart: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('expand_tools_button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Record audio'));
    await tester.tap(find.text('Record audio'));
    await tester.pumpAndSettle();

    expect(find.text('Audio recording is unavailable.'), findsOneWidget);
    expect(find.text('Record audio'), findsOneWidget);
  });

  testWidgets('audio playback failure gives the user feedback', (tester) async {
    final note = _noteWithAttachment('/missing/recording.mp3');
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/editor',
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: RouteSettings(arguments: note),
          builder: (_) => NewNoteScreen(
            attachmentStorage: _FakeAttachmentStorage(),
            mediaService: _FakeEditorMediaService(throwOnPlayback: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not add that file. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('failed file opening gives the user feedback', (tester) async {
    final note = _noteWithAttachment('/missing/document.pdf');
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/editor',
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: RouteSettings(arguments: note),
          builder: (_) => NewNoteScreen(
            attachmentStorage: _FakeAttachmentStorage(openFileResult: false),
            mediaService: _FakeEditorMediaService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.insert_drive_file_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Could not open this file.'), findsOneWidget);
  });

  testWidgets('failed link opening gives the user feedback', (tester) async {
    final note = _noteWithAttachment('url:https://example.com');
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/editor',
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          settings: RouteSettings(arguments: note),
          builder: (_) => NewNoteScreen(
            attachmentStorage: _FakeAttachmentStorage(openLinkResult: false),
            mediaService: _FakeEditorMediaService(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.link));
    await tester.pumpAndSettle();

    expect(find.text('Could not open this link.'), findsOneWidget);
  });

  testWidgets('failed media picking gives the user feedback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewNoteScreen(
          repository: NoteRepository(storage: _MemoryNoteStorage()),
          attachmentStorage: _FakeAttachmentStorage(throwOnPick: true),
          mediaService: _FakeEditorMediaService(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add_content_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not add that file. Please try again.'),
      findsOneWidget,
    );
  });
}

NoteModel _noteWithAttachment(String attachment) {
  final now = DateTime.utc(2026);
  return NoteModel(
    id: 'attachment-note',
    title: 'Attachment note',
    pages: [
      NotePage(id: 'attachment-page', attachments: [attachment]),
    ],
    modifiedDate: now,
    createdDate: now,
  );
}

class _FakeAttachmentStorage implements NoteAttachmentStorage {
  _FakeAttachmentStorage({
    this.throwOnPick = false,
    this.openFileResult = true,
    this.openLinkResult = true,
  });

  final bool throwOnPick;
  final bool openFileResult;
  final bool openLinkResult;

  @override
  Future<String?> pickImageAndKeep() async {
    if (throwOnPick) throw StateError('Picker failed');
    return '/kept/photo.png';
  }

  @override
  Future<String?> pickFileAndKeep() async {
    if (throwOnPick) throw StateError('Picker failed');
    return '/kept/document.pdf';
  }

  @override
  Future<String> keepFile(String sourcePath) async => sourcePath;

  @override
  Future<StoredAttachment?> load(String reference) async => null;

  @override
  Future<NoteModel> migrateLegacyReferences(NoteModel note) async => note;

  @override
  Future<bool> openFile(String path) async => openFileResult;

  @override
  Future<bool> openLink(String url) async => openLinkResult;

  @override
  Future<void> deleteUnusedFiles(
    NoteModel deletedNote,
    Iterable<NoteModel> remainingNotes,
  ) async {}
}

class _FakeEditorMediaService implements EditorMediaService {
  _FakeEditorMediaService({
    this.speechAvailable = false,
    this.recordingAvailable = false,
    this.throwOnListen = false,
    this.throwOnRecordStart = false,
    this.throwOnPlayback = false,
  });

  final bool speechAvailable;
  final bool recordingAvailable;
  final bool throwOnListen;
  final bool throwOnRecordStart;
  final bool throwOnPlayback;

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> initializeSpeech({
    required void Function(String status) onStatus,
    required void Function(SpeechRecognitionError error) onError,
  }) async => speechAvailable;

  @override
  Future<void> listenSpeech({
    required void Function(String words, bool isFinal) onResult,
  }) async {
    if (throwOnListen) throw StateError('Speech startup failed');
    onResult('captured words', true);
  }

  @override
  Future<void> playAudio(String path) async {
    if (throwOnPlayback) throw StateError('Playback failed');
  }

  @override
  Future<void> playAudioBytes(Uint8List bytes, {String? mimeType}) async {}

  @override
  Future<void> stopSpeech() async {}

  @override
  Future<void> cancelSpeech() async {}

  @override
  Future<bool> startRecording() async {
    if (throwOnRecordStart) throw StateError('Recorder startup failed');
    return recordingAvailable;
  }

  @override
  Future<String?> stopRecording() async =>
      recordingAvailable ? 'recording.m4a' : null;
}

class _MemoryNoteStorage implements NoteStorage {
  final Map<String, (String, int)> values = {};

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<List<String>> readNotes() async {
    final entries = values.values.toList()
      ..sort((first, second) => first.$2.compareTo(second.$2));
    return entries.map((entry) => entry.$1).toList();
  }

  @override
  Future<void> writeNote(String id, String value, int sortOrder) async {
    values[id] = (value, sortOrder);
  }

  @override
  Future<void> deleteNote(String id) async => values.remove(id);
}
