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

  // ============================================================
  // SECTION: Konstruktor
  // ============================================================
  Hunt({
    required this.name,
    this.clues = const {}, // Standardmäßig eine leere Map
    this.briefingText,
    this.briefingImageUrl,
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
      // NEUE FELDER AUS JSON LESEN
      briefingText: json['briefingText'] as String?,
      briefingImageUrl: json['briefingImageUrl'] as String?,
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
      'clues': cluesJson,
      // NEUE FELDER IN JSON SCHREIBEN
      'briefingText': briefingText,
      'briefingImageUrl': briefingImageUrl,
    };
  }
}
