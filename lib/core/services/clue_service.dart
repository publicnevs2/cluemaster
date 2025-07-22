// ============================================================
// SECTION: Imports
// ============================================================
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/clue.dart';

// ============================================================
// SECTION: ClueService Klasse
// ============================================================
class ClueService {
  // ============================================================
  // SECTION: Dateinamen-Konstanten
  // ============================================================
  
  /// Dateiname für die Speicherdatei der Hinweise.
  static const String _cluesFileName = 'codes.json';

  /// NEU: Eigener Dateiname für die Admin-Einstellungen, um sie von den Spieldaten zu trennen.
  static const String _settingsFileName = 'admin_settings.json';

  // ============================================================
  // SECTION: Methoden für Hinweise (Clues)
  // ============================================================

  /// Lädt Clues aus der Datei oder kopiert sie initial aus den Assets, falls die Datei nicht existiert.
  Future<Map<String, Clue>> loadClues() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_cluesFileName');

    try {
      // Kopiere die Standard-Hinweise aus den Assets nur, wenn die Speicherdatei noch nicht existiert.
      if (!await file.exists()) {
        final assetJson = await rootBundle.loadString('assets/$_cluesFileName');
        await file.writeAsString(assetJson);
      }

      // Lese die JSON-Daten aus der Datei.
      final jsonStr = await file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);

      print("✅ Geladene Codes: ${decoded.keys.toList()}");

      // Wandle die JSON-Daten in eine Map von Clue-Objekten um.
      return decoded.map((key, value) => MapEntry(
            key,
            Clue.fromJson(key, value),
          ));
    } catch (e) {
      print("❌ Fehler beim Laden der Clues: $e");
      return {};
    }
  }

  /// Speichert die aktuelle Map von Hinweisen in die lokale Datei.
  Future<void> saveClues(Map<String, Clue> clues) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_cluesFileName');

    // Wandle die Map von Clue-Objekten zurück in ein JSON-Format.
    final Map<String, dynamic> jsonMap = {
      for (var entry in clues.entries) entry.key: entry.value.toJson()
    };

    // Schreibe die JSON-Daten in die Datei.
    await file.writeAsString(jsonEncode(jsonMap));
    print("💾 Clues gespeichert: ${clues.keys.toList()}");
  }

  /// Setzt die Hinweise auf die ursprüngliche Version aus den Assets zurück.
  Future<void> resetCluesFromAssets() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_cluesFileName');
    final assetJson = await rootBundle.loadString('assets/$_cluesFileName');
    await file.writeAsString(assetJson);
    print("🔁 Clues zurückgesetzt");
  }

  // ============================================================
  // NEUER ABSCHNITT: Methoden für Admin-Einstellungen
  // ============================================================

  /// Lädt das Admin-Passwort aus der Einstellungsdatei.
  /// Gibt 'admin123' als Standardwert zurück, falls die Datei nicht existiert.
  Future<String> loadAdminPassword() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_settingsFileName');

      // Prüfe, ob die Einstellungsdatei existiert.
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final Map<String, dynamic> settings = jsonDecode(jsonStr);
        // Gib das Passwort zurück oder das Standardpasswort, falls es leer ist.
        return settings['admin_password'] ?? 'admin123';
      } else {
        // Wenn die Datei nicht existiert, wird das Standardpasswort verwendet.
        return 'admin123';
      }
    } catch (e) {
      print("❌ Fehler beim Laden des Admin-Passworts: $e");
      return 'admin123'; // Sicherheits-Fallback
    }
  }

  /// Speichert ein neues Admin-Passwort in die Einstellungsdatei.
  Future<void> saveAdminPassword(String password) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_settingsFileName');
    
    // Erstelle eine Map mit dem neuen Passwort.
    final settings = {'admin_password': password};
    
    // Wandle die Map in einen JSON-String um und speichere ihn.
    await file.writeAsString(jsonEncode(settings));
    print("🔑 Admin-Passwort aktualisiert.");
  }
}