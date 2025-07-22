// ============================================================
// SECTION: Clue Klasse
// ============================================================
class Clue {
  // ============================================================
  // SECTION: Bestehende Eigenschaften
  // ============================================================
  final String code;
  final String type; // 'text', 'image', 'audio' oder 'video'
  final String content; // Der eigentliche Hinweis (Text oder Dateipfad)
  final String? description;
  bool solved;

  // ============================================================
  // SECTION: Optionale Eigenschaften für RÄTSEL
  // ============================================================
  final String? question; // Die Frage des Rätsels. Wenn null, ist es kein Rätsel.
  final String? answer;   // Die korrekte Antwort.

  // NEU: Optionale Eigenschaften für MULTIPLE-CHOICE-Rätsel
  final List<String>? options; // Eine Liste von Antwortmöglichkeiten.

  // ============================================================
  // SECTION: Konstruktor
  // ============================================================
  Clue({
    required this.code,
    required this.type,
    required this.content,
    this.description,
    this.solved = false,
    this.question,
    this.answer,
    this.options, // Hinzugefügt
  });

  // ============================================================
  // SECTION: Hilfs-Methoden (Getters)
  // ============================================================

  /// Prüft, ob dieser Hinweis ein Rätsel ist (hat Frage und Antwort).
  bool get isRiddle => question != null && answer != null;

  /// NEU: Prüft, ob das Rätsel ein Multiple-Choice-Rätsel ist.
  bool get isMultipleChoice => isRiddle && options != null && options!.isNotEmpty;

  // ============================================================
  // SECTION: JSON-Konvertierung
  // ============================================================

  /// Erstellt ein Clue-Objekt aus JSON-Daten.
  factory Clue.fromJson(String code, Map<String, dynamic> json) {
    return Clue(
      code: code,
      type: json['type'],
      content: json['content'],
      description: json['description'],
      solved: json['solved'] ?? false,
      question: json['question'],
      answer: json['answer'],
      // Liest die neuen Multiple-Choice-Optionen, falls sie existieren.
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  /// Wandelt das Clue-Objekt in ein JSON-Format um.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      if (description != null) 'description': description,
      'solved': solved,
      // Schreibt die Rätsel-Felder, falls sie existieren.
      if (question != null) 'question': question,
      if (answer != null) 'answer': answer,
      // Schreibt die Multiple-Choice-Optionen, falls sie existieren.
      if (options != null) 'options': options,
    };
  }
}
