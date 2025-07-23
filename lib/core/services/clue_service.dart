// lib/core/services/clue_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:clue_master/data/models/hunt.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/models/clue.dart';

class ClueService {
  static const String _huntsFileName = 'hunts.json';
  static const String _settingsFileName = 'admin_settings.json';

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

  Future<void> exportHunt(Hunt hunt) async {
    // ... (Code für den Export, falls du ihn brauchst, ansonsten kann dieser Teil weg)
  }

  Future<String?> importHunt() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) {
      return null;
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
        return "EXISTS";
      }
      allHunts.add(importedHunt);
      await saveHunts(allHunts);
      
      return importedHunt.name;
    } catch (e) {
      print("❌ Fehler beim Importieren der Jagd: $e");
      return "ERROR";
    }
  }

  Future<String> loadAdminPassword() async {
    // ...
    return 'admin123';
  }

  Future<void> saveAdminPassword(String password) async {
    // ...
  }
}