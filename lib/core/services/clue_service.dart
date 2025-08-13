import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/models/hunt.dart';
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
      // ignore: avoid_print
      print("❌ Fehler beim Laden der Schnitzeljagden: $e");
      return [];
    }
  }

  Future<void> saveHunts(List<Hunt> hunts) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_huntsFileName');
    final List<Map<String, dynamic>> jsonList =
        hunts.map((hunt) => hunt.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    // ignore: avoid_print
    print("💾 Alle Schnitzeljagden gespeichert.");
  }

  Future<void> resetHuntProgress(Hunt hunt) async {
    final allHunts = await loadHunts();
    final huntIndex = allHunts.indexWhere((h) => h.name == hunt.name);

    if (huntIndex != -1) {
      allHunts[huntIndex].clues.forEach((code, clue) {
        clue.solved = false;
        clue.hasBeenViewed = false;
      });
      await saveHunts(allHunts);
      // ignore: avoid_print
      print("🔄 Fortschritt für '${hunt.name}' zurückgesetzt.");
    }
  }

  Future<void> exportHunt(Hunt hunt, BuildContext context) async {
    try {
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
          if (await file.exists()) {
            mediaFilesToPack.add(file);
            newContent = 'media/${file.path.split('/').last}';
          } else {
            // ignore: avoid_print
            print("⚠️ Datei nicht gefunden, wird ignoriert: ${file.path}");
          }
        }
        
        final clueJson = clue.toJson();
        clueJson['content'] = newContent;
        clueJson['solved'] = false;
        clueJson['hasBeenViewed'] = false;
        updatedClues[entry.key] = Clue.fromJson(entry.key, clueJson);
      }
      exportHunt.clues = updatedClues;

      for (var file in mediaFilesToPack) {
        final bytes = await file.readAsBytes();
        archive.addFile(
            ArchiveFile('media/${file.path.split('/').last}', bytes.length, bytes));
      }

      final huntJsonString = jsonEncode(exportHunt.toJson());
      archive.addFile(
          ArchiveFile('hunt.json', huntJsonString.length, utf8.encode(huntJsonString)));

      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);
      if (zipData == null) {
        throw Exception("Fehler beim Erstellen der ZIP-Datei.");
      }

      final sanitizedHuntName = hunt.name.replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
      final exportFile = File('${tempDir.path}/$sanitizedHuntName.cluemaster');
      await exportFile.writeAsBytes(zipData);

      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(exportFile.path)],
        text: 'Hier ist die Schnitzeljagd "${hunt.name}"!',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      // ignore: avoid_print
      print("❌ Fehler beim Exportieren der Jagd: $e");
      rethrow;
    }
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
      
      if (!importFile.path.toLowerCase().endsWith('.cluemaster')) {
          throw Exception("Die ausgewählte Datei ist keine .cluemaster-Datei.");
      }

      final bytes = await importFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final huntJsonFile = archive.findFile('hunt.json');
      if (huntJsonFile == null) throw Exception("Datei 'hunt.json' nicht im Archiv gefunden.");
      
      final huntJsonString = utf8.decode(huntJsonFile.content as List<int>);
      final importedHuntData = jsonDecode(huntJsonString);
      Hunt huntToSave = Hunt.fromJson(importedHuntData);

      final appDir = await getApplicationDocumentsDirectory();
      for (var file in archive.files) {
        if (file.name.startsWith('media/')) {
          final mediaFile = File('${appDir.path}/${file.name}');
          await mediaFile.create(recursive: true);
          await mediaFile.writeAsBytes(file.content as List<int>);
        }
      }

      final Map<String, Clue> updatedClues = {};
      for (var entry in huntToSave.clues.entries) {
        final clue = entry.value;
        String newContent = clue.content;
        if (clue.content.startsWith('media/')) {
          newContent = 'file://${appDir.path}/${clue.content}';
        }
        final clueJson = clue.toJson();
        clueJson['content'] = newContent;
        updatedClues[entry.key] = Clue.fromJson(entry.key, clueJson);
      }
      huntToSave.clues = updatedClues;

      final allHunts = await loadHunts();
      
      // --- KORRIGIERTE LOGIK ---
      if (allHunts.any((h) => h.name.toLowerCase() == huntToSave.name.toLowerCase())) {
        String originalName = huntToSave.name;
        int counter = 1;
        String newName;
        do {
          newName = '$originalName ($counter)';
          counter++;
        } while (allHunts.any((h) => h.name.toLowerCase() == newName.toLowerCase()));
        
        // Erstelle eine NEUE Hunt-Instanz mit dem neuen Namen
        huntToSave = Hunt(
          name: newName,
          clues: huntToSave.clues,
          briefingText: huntToSave.briefingText,
        );
      }
      // --- ENDE KORREKTUR ---

      allHunts.add(huntToSave);
      await saveHunts(allHunts);
      
      return huntToSave.name;
    } catch (e) {
      // ignore: avoid_print
      print("❌ Fehler beim Importieren der Jagd: $e");
      return "ERROR";
    }
  }

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
      // ignore: avoid_print
      print("❌ Fehler beim Laden des Admin-Passworts: $e");
      return 'admin123';
    }
  }

  Future<void> saveAdminPassword(String password) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_settingsFileName');
    final settings = {'admin_password': password};
    await file.writeAsString(jsonEncode(settings));
    // ignore: avoid_print 
    print("🔑 Admin-Passwort aktualisiert.");
  }
}
