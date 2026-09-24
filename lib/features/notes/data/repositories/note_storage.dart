import 'package:shared_preferences/shared_preferences.dart';

/// Small storage boundary that makes persistence testable without platform code.
abstract class NoteStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

/// Device-backed storage used by the application.
class SharedPreferencesNoteStorage implements NoteStorage {
  static const _storageKey = 'papernote.notes.v1';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  @override
  Future<String?> read() async {
    return (await _preferences).getString(_storageKey);
  }

  @override
  Future<void> write(String value) async {
    await (await _preferences).setString(_storageKey, value);
  }

  @override
  Future<void> clear() async {
    await (await _preferences).remove(_storageKey);
  }
}
