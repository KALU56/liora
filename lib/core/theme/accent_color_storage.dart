import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage contract for saving and loading the user's selected accent color.
abstract class AccentColorStorage {
  Future<Color?> loadAccentColor();
  Future<void> saveAccentColor(Color color);
  Future<void> clear();
}

/// SharedPreferences-backed storage for accent color persistence.
class SharedPreferencesAccentColorStorage implements AccentColorStorage {
  static const String _storageKey = 'papernote.settings.accent_color.v1';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  @override
  Future<Color?> loadAccentColor() async {
    final prefs = await _preferences;
    final value = prefs.getInt(_storageKey);
    if (value == null) {
      return null;
    }
    return Color(value);
  }

  @override
  Future<void> saveAccentColor(Color color) async {
    final prefs = await _preferences;
    await prefs.setInt(_storageKey, color.toARGB32());
  }

  @override
  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.remove(_storageKey);
  }
}

/// In-memory storage for testing without platform plugins.
class MemoryAccentColorStorage implements AccentColorStorage {
  MemoryAccentColorStorage([this.savedColor]);

  Color? savedColor;

  @override
  Future<Color?> loadAccentColor() async => savedColor;

  @override
  Future<void> saveAccentColor(Color color) async {
    savedColor = color;
  }

  @override
  Future<void> clear() async {
    savedColor = null;
  }
}
