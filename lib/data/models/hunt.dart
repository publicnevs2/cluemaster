// lib/data/models/hunt.dart

// ============================================================
// SECTION: Imports
// ============================================================
import 'clue.dart';

// ============================================================
// SECTION: Hunt Klasse
// ============================================================
/// Repräsentiert eine komplette Schnitzeljagd mit einem Namen und einer
/// Sammlung von dazugehörigen Hinweisen (Clues).
class Hunt {
  // ============================================================
  // SECTION: Eigenschaften
  // ============================================================

  /// Der Name der Schnitzeljagd, z.B. "Kindergeburtstag Maja".
  /// Dient als einzigartiger Identifikator.
  final String name;

  /// Eine Map, die alle Hinweise (Clues) dieser Jagd enthält.
  /// Der Key ist der Code des Hinweises (z.B. "START"), der Value das Clue-Objekt.
  Map<String, Clue> clues;

  // NEUE FELDER FÜR DAS BRIEFING
  /// Optionaler Einleitungstext für die Mission.
  final String? briefingText;

  /// Optionaler Pfad zu einem Bild für das Missions-Briefing.
  final String? briefingImageUrl;

  // NEU: Optionale Zielzeit in Minuten für die Statistik
  final int? targetTimeInMinutes;


  // ============================================================
  // SECTION: Konstruktor
  // ============================================================
  Hunt({
    required this.name,
    this.clues = const {}, // Standardmäßig eine leere Map
    this.briefingText,
    this.briefingImageUrl,
    this.targetTimeInMinutes, // NEU
  });

  // ============================================================
  // SECTION: JSON-Konvertierung
  // ============================================================

  /// Erstellt ein Hunt-Objekt aus JSON-Daten.
  factory Hunt.fromJson(Map<String, dynamic> json) {
    // Wandelt die Clue-Daten aus der JSON-Struktur in eine Map von Clue-Objekten um.
    final cluesData = json['clues'] as Map<String, dynamic>;
    final cluesMap = cluesData.map(
      (code, clueJson) => MapEntry(code, Clue.fromJson(code, clueJson)),
    );

    return Hunt(
      name: json['name'],
      clues: cluesMap,
      briefingText: json['briefingText'] as String?,
      briefingImageUrl: json['briefingImageUrl'] as String?,
      // NEU: Liest die Zielzeit aus der JSON-Datei
      targetTimeInMinutes: json['targetTimeInMinutes'] as int?,
    );
  }

  /// Wandelt das Hunt-Objekt in ein JSON-Format um.
  Map<String, dynamic> toJson() {
    // Wandelt die Map von Clue-Objekten zurück in ein JSON-Format.
    final cluesJson = clues.map(
      (code, clue) => MapEntry(code, clue.toJson()),
    );

    return {
      'name': name,
      'briefingText': briefingText,
      'briefingImageUrl': briefingImageUrl,
      // NEU: Schreibt die Zielzeit nur in die Datei, wenn sie auch existiert
      if (targetTimeInMinutes != null) 'targetTimeInMinutes': targetTimeInMinutes,
      'clues': cluesJson,
    };
  }
}