// ============================================================
// SECTION: Imports
// ============================================================
import 'dart:convert';
import 'dart:io';
import 'package:clue_master/data/models/hunt.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

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
  // SECTION: Export & Import
  // ============================================================
  
  Future<void> exportHunt(Hunt hunt) async {
    final tempDir = await getTemporaryDirectory();
    final archive = Archive();
    final mediaFilesToPack = <File>{};

    final exportHunt = Hunt.fromJson(hunt.toJson());
    final Map<String, Clue> updatedClues = {};

    for (var entry in exportHunt.clues.entries) {
      final clue = entry.value;
      String newContent = clue.content;

      if (clue.content.startsWith('file://')) {
        final file = File(clue.content.replaceFirst('file://', ''));
        mediaFilesToPack.add(file);
        newContent = 'media/${file.path.split('/').last}';
      }

      updatedClues[entry.key] = Clue(
        code: clue.code,
        solved: clue.solved,
        type: clue.type,
        content: newContent,
        description: clue.description,
        question: clue.question,
        answer: clue.answer,
        options: clue.options,
        hint1: clue.hint1,
        hint2: clue.hint2,
        rewardText: clue.rewardText,
      );
    }
    exportHunt.clues = updatedClues;

    for (var file in mediaFilesToPack) {
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile('media/${file.path.split('/').last}', bytes.length, bytes));
      }
    }

    final huntJsonString = jsonEncode(exportHunt.toJson());
    archive.addFile(ArchiveFile('hunt.json', huntJsonString.length, utf8.encode(huntJsonString)));

    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    if (zipData == null) {
      print("❌ Fehler beim Erstellen der ZIP-Datei.");
      return;
    }

    final exportFile = File('${tempDir.path}/${hunt.name.replaceAll(' ', '_')}.cluemaster');
    await exportFile.writeAsBytes(zipData);

    await Share.shareXFiles([XFile(exportFile.path)], text: 'Hier ist die Schnitzeljagd "${hunt.name}"!');
  }

  /// Importiert eine .cluemaster-Datei und fügt sie als neue Jagd hinzu.
  /// Gibt den Namen der importierten Jagd oder einen Fehlercode zurück.
  Future<String?> importHunt() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) {
      return null; // Nutzer hat abgebrochen
    }

    try {
      final importFile = File(result.files.single.path!);
      final bytes = await importFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final huntJsonFile = archive.findFile('hunt.json');
      if (huntJsonFile == null) throw Exception("Datei 'hunt.json' nicht im Archiv gefunden.");
      
      final huntJsonString = utf8.decode(huntJsonFile.content);
      final importedHunt = Hunt.fromJson(jsonDecode(huntJsonString));

      final appDir = await getApplicationDocumentsDirectory();
      for (var file in archive.files) {
        if (file.name.startsWith('media/')) {
          final mediaFile = File('${appDir.path}/${file.name}');
          await mediaFile.create(recursive: true);
          await mediaFile.writeAsBytes(file.content);
        }
      }

      final Map<String, Clue> updatedClues = {};
      for (var entry in importedHunt.clues.entries) {
        final clue = entry.value;
        String newContent = clue.content;
        if (clue.content.startsWith('media/')) {
          newContent = 'file://${appDir.path}/${clue.content}';
        }
        final clueJson = clue.toJson();
        clueJson['content'] = newContent;
        updatedClues[entry.key] = Clue.fromJson(entry.key, clueJson);
      }
      importedHunt.clues = updatedClues;

      final allHunts = await loadHunts();
      if (allHunts.any((h) => h.name.toLowerCase() == importedHunt.name.toLowerCase())) {
        return "EXISTS"; // Spezieller Rückgabewert für Duplikate
      }
      allHunts.add(importedHunt);
      await saveHunts(allHunts);
      
      return importedHunt.name;
    } catch (e) {
      print("❌ Fehler beim Importieren der Jagd: $e");
      return "ERROR"; // Spezieller Rückgabewert für generelle Fehler
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
