import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notability_clone/core/theme/accent_color_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccentColorStorage', () {
    test('MemoryAccentColorStorage saves, loads, and clears', () async {
      final storage = MemoryAccentColorStorage();
      expect(await storage.loadAccentColor(), isNull);

      const color = Color(0xFF506C73);
      await storage.saveAccentColor(color);
      expect(await storage.loadAccentColor(), equals(color));

      await storage.clear();
      expect(await storage.loadAccentColor(), isNull);
    });

    test(
      'SharedPreferencesAccentColorStorage saves, loads, and clears',
      () async {
        SharedPreferences.setMockInitialValues({});
        final storage = SharedPreferencesAccentColorStorage();
        expect(await storage.loadAccentColor(), isNull);

        const color = Color(0xFF626E55);
        await storage.saveAccentColor(color);

        final loaded = await storage.loadAccentColor();
        expect(loaded, isNotNull);
        expect(loaded!.toARGB32(), equals(color.toARGB32()));

        await storage.clear();
        expect(await storage.loadAccentColor(), isNull);
      },
    );
  });
}
