// ============================================================
// SECTION: Imports
// ============================================================
import 'dart:convert';
import 'dart:io';
import 'package:clue_master/data/models/hunt.dart';
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
  
  /// NEU: Dateiname für die Speicherdatei, die alle Schnitzeljagden enthält.
  static const String _huntsFileName = 'hunts.json';
  static const String _settingsFileName = 'admin_settings.json';

  // ============================================================
  // SECTION: Methoden für Schnitzeljagden (Hunts)
  // ============================================================

  /// Lädt alle Schnitzeljagden aus der Datei.
  /// Wenn die Datei nicht existiert, wird eine Beispieldatei aus den Assets kopiert.
  Future<List<Hunt>> loadHunts() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_huntsFileName');

    try {
      if (!await file.exists()) {
        // Lade die Vorlage aus den Assets, die eine Beispieljagd enthält.
        final assetJson = await rootBundle.loadString('assets/$_huntsFileName');
        await file.writeAsString(assetJson);
      }

      final jsonStr = await file.readAsString();
      // Die JSON-Datei enthält eine Liste von Jagden.
      final List<dynamic> decodedList = jsonDecode(jsonStr);

      // Wandle jedes Element der Liste in ein Hunt-Objekt um.
      return decodedList.map((json) => Hunt.fromJson(json)).toList();
    } catch (e) {
      print("❌ Fehler beim Laden der Schnitzeljagden: $e");
      return []; // Gib eine leere Liste zurück, wenn ein Fehler auftritt.
    }
  }

  /// Speichert die komplette Liste aller Schnitzeljagden.
  Future<void> saveHunts(List<Hunt> hunts) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_huntsFileName');

    // Wandle die Liste von Hunt-Objekten in ein JSON-Format um.
    final List<Map<String, dynamic>> jsonList =
        hunts.map((hunt) => hunt.toJson()).toList();

    // Schreibe die JSON-Daten in die Datei.
    await file.writeAsString(jsonEncode(jsonList));
    print("💾 Alle Schnitzeljagden gespeichert.");
  }

  // ============================================================
  // SECTION: Alte Methoden (werden jetzt als veraltet markiert)
  // ============================================================
  // Diese Methoden werden wir in den nächsten Schritten entfernen oder anpassen,
  // da die Logik jetzt über die Hunts läuft. Vorerst lassen wir sie hier,
  // damit die App nicht sofort komplett bricht.

  @Deprecated('Nutze stattdessen loadHunts und wähle die gewünschte Jagd aus.')
  Future<Map<String, Clue>> loadClues() async {
    // Provisorische Implementierung: Lade die erste Jagd aus der Liste.
    final hunts = await loadHunts();
    if (hunts.isNotEmpty) {
      return hunts.first.clues;
    }
    return {};
  }

  @Deprecated('Nutze stattdessen saveHunts.')
  Future<void> saveClues(Map<String, Clue> clues) async {
    // Diese Methode wird komplexer, da wir wissen müssen, zu welcher Jagd wir speichern.
    // Vorerst speichert sie die Clues in die erste gefundene Jagd.
    final hunts = await loadHunts();
    if (hunts.isNotEmpty) {
      hunts.first.clues = clues;
      await saveHunts(hunts);
    }
  }

  // ============================================================
  // SECTION: Methoden für Admin-Einstellungen (unverändert)
  // ============================================================
  
  Future<String> loadAdminPassword() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_settingsFileName');

      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final Map<String, dynamic> settings = jsonDecode(jsonStr);
        return settings['admin_password'] ?? 'admin123';
      } else {
        return 'admin123';
      }
    } catch (e) {
      print("❌ Fehler beim Laden des Admin-Passworts: $e");
      return 'admin123';
    }
  }

  Future<void> saveAdminPassword(String password) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_settingsFileName');
    final settings = {'admin_password': password};
    await file.writeAsString(jsonEncode(settings));
    print("🔑 Admin-Passwort aktualisiert.");
  }
}
