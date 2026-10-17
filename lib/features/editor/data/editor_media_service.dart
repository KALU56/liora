import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Owns speech, recording, and playback plugins used by the note editor.
class EditorMediaService {
  EditorMediaService({
    stt.SpeechToText? speech,
    AudioRecorder? recorder,
    AudioPlayer? audioPlayer,
  }) : _speech = speech ?? stt.SpeechToText(),
       _recorder = recorder ?? AudioRecorder(),
       _audioPlayer = audioPlayer ?? AudioPlayer();

  static const _recordingExtension = '.m4a';
  final stt.SpeechToText _speech;
  final AudioRecorder _recorder;
  final AudioPlayer _audioPlayer;

  Future<bool> initializeSpeech({
    required void Function(String status) onStatus,
    required void Function(SpeechRecognitionError error) onError,
  }) => _speech.initialize(onStatus: onStatus, onError: onError);

  Future<void> listenSpeech({
    required void Function(String words, bool isFinal) onResult,
  }) => _speech.listen(
    onResult: (result) => onResult(result.recognizedWords, result.finalResult),
    listenOptions: stt.SpeechListenOptions(
      partialResults: true,
      pauseFor: const Duration(seconds: 30),
      listenFor: const Duration(minutes: 5),
      listenMode: stt.ListenMode.dictation,
    ),
  );

  Future<void> stopSpeech() => _speech.stop();

  Future<void> cancelSpeech() => _speech.cancel();

  Future<bool> startRecording() async {
    if (!await _recorder.hasPermission()) return false;
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/audio_${DateTime.now().microsecondsSinceEpoch}$_recordingExtension';
    await _recorder.start(const RecordConfig(), path: path);
    return true;
  }

  Future<String?> stopRecording() => _recorder.stop();

  Future<void> playAudio(String path) =>
      _audioPlayer.play(DeviceFileSource(path));

  Future<void> playAudioBytes(Uint8List bytes, {String? mimeType}) =>
      _audioPlayer.play(BytesSource(bytes, mimeType: mimeType));

  Future<void> dispose() async {
    await _recorder.dispose();
    await _audioPlayer.dispose();
    await _speech.cancel();
  }
}
