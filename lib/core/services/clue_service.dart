// ============================================================
// SECTION: Imports
// ============================================================
import 'dart:convert';
import 'dart:io';
import 'package:clue_master/data/models/hunt.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart'; // NEU: Für das Erstellen von ZIP-Dateien
import 'package:share_plus/share_plus.dart'; // NEU: Für das Teilen von Dateien

import '../../data/models/clue.dart';

// ============================================================
// SECTION: ClueService Klasse
// ============================================================
class ClueService {
  // ============================================================
  // SECTION: Dateinamen-Konstanten
  // ============================================================
  static const String _huntsFileName = 'hunts.json';
  static const String _settingsFileName = 'admin_settings.json';

  // ============================================================
  // SECTION: Methoden für Schnitzeljagden (Hunts)
  // ============================================================

  Future<List<Hunt>> loadHunts() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_huntsFileName');
    try {
      if (!await file.exists()) {
        final assetJson = await rootBundle.loadString('assets/$_huntsFileName');
        await file.writeAsString(assetJson);
      }
      final jsonStr = await file.readAsString();
      final List<dynamic> decodedList = jsonDecode(jsonStr);
      return decodedList.map((json) => Hunt.fromJson(json)).toList();
    } catch (e) {
      print("❌ Fehler beim Laden der Schnitzeljagden: $e");
      return [];
    }
  }

  Future<void> saveHunts(List<Hunt> hunts) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_huntsFileName');
    final List<Map<String, dynamic>> jsonList = hunts.map((hunt) => hunt.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    print("💾 Alle Schnitzeljagden gespeichert.");
  }

  // ============================================================
  // NEUE METHODE: Exportieren einer Schnitzeljagd
  // ============================================================
  /// Erstellt ein teilbares .cluemaster (ZIP) Archiv für eine einzelne Schnitzeljagd.
  Future<void> exportHunt(Hunt hunt) async {
    final tempDir = await getTemporaryDirectory();
    final archive = Archive();
    final mediaFilesToPack = <File>{}; // Ein Set, um doppelte Dateien zu vermeiden

    // 1. Erstelle eine Kopie der Jagd, um die Dateipfade anzupassen.
    final exportHunt = Hunt.fromJson(hunt.toJson()); // Tiefe Kopie
    final Map<String, Clue> updatedClues = {};

    for (var entry in exportHunt.clues.entries) {
      final clue = entry.value;
      String newContent = clue.content;

      if (clue.content.startsWith('file://')) {
        final file = File(clue.content.replaceFirst('file://', ''));
        mediaFilesToPack.add(file);
        // Ersetze den langen Pfad durch einen kurzen, relativen Pfad für das Archiv.
        newContent = 'media/${file.path.split('/').last}';
      }

      // Erstelle ein neues Clue-Objekt mit dem aktualisierten Inhalt.
      updatedClues[entry.key] = Clue(
        code: clue.code,
        solved: clue.solved,
        type: clue.type,
        content: newContent, // Verwende den neuen, angepassten Inhalt
        description: clue.description,
        question: clue.question,
        answer: clue.answer,
        options: clue.options,
        hint1: clue.hint1,
        hint2: clue.hint2,
        rewardText: clue.rewardText,
      );
    }
    // Ersetze die alte Clue-Map durch die aktualisierte.
    exportHunt.clues = updatedClues;


    // 2. Füge die Mediendateien zum Archiv hinzu.
    for (var file in mediaFilesToPack) {
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile('media/${file.path.split('/').last}', bytes.length, bytes));
      }
    }

    // 3. Füge die Logik-Datei (hunt.json) zum Archiv hinzu.
    final huntJsonString = jsonEncode(exportHunt.toJson());
    archive.addFile(ArchiveFile('hunt.json', huntJsonString.length, utf8.encode(huntJsonString)));

    // 4. Erstelle die finale ZIP-Datei.
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    if (zipData == null) {
      print("❌ Fehler beim Erstellen der ZIP-Datei.");
      return;
    }

    final exportFile = File('${tempDir.path}/${hunt.name.replaceAll(' ', '_')}.cluemaster');
    await exportFile.writeAsBytes(zipData);

    // 5. Öffne das native "Teilen"-Menü.
    await Share.shareXFiles([XFile(exportFile.path)], text: 'Hier ist die Schnitzeljagd "${hunt.name}"!');
  }


  // ============================================================
  // SECTION: Veraltete Methoden (bleiben vorerst)
  // ============================================================
  @Deprecated('Nutze stattdessen loadHunts und wähle die gewünschte Jagd aus.')
  Future<Map<String, Clue>> loadClues() async {
    final hunts = await loadHunts();
    if (hunts.isNotEmpty) return hunts.first.clues;
    return {};
  }

  @Deprecated('Nutze stattdessen saveHunts.')
  Future<void> saveClues(Map<String, Clue> clues) async {
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
