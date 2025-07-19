import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/clue.dart';

class ClueService {
  static const String _fileName = 'codes.json';

  /// Lädt Clues aus Datei oder kopiert initial aus Assets (nur wenn Datei nicht existiert).
  Future<Map<String, Clue>> loadClues() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    try {
      // Kopiere nur, wenn Datei noch nicht existiert
      if (!await file.exists()) {
        final assetJson = await rootBundle.loadString('assets/$_fileName');
        await file.writeAsString(assetJson);
      }

      final jsonStr = await file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);

      print("✅ Geladene Codes: ${decoded.keys.toList()}");

      return decoded.map((key, value) => MapEntry(
            key,
            Clue.fromJson(key, value),
          ));
    } catch (e) {
      print("❌ Fehler beim Laden der Clues: $e");
      return {};
    }
  }

  /// Speichert Clues in die lokale Datei.
  Future<void> saveClues(Map<String, Clue> clues) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    final Map<String, dynamic> jsonMap = {
      for (var entry in clues.entries) entry.key: entry.value.toJson()
    };

    await file.writeAsString(jsonEncode(jsonMap));
    print("💾 Clues gespeichert: ${clues.keys.toList()}");
  }

  /// Reset auf ursprüngliche Assets-Version (z. B. für Tests)
  Future<void> resetCluesFromAssets() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    final assetJson = await rootBundle.loadString('assets/$_fileName');
    await file.writeAsString(assetJson);
    print("🔁 Clues zurückgesetzt");
  }
}
