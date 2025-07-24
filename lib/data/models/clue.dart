// ============================================================
// SECTION: Clue Klasse
// ============================================================
class Clue {
  // ============================================================
  // SECTION: Kerneigenschaften
  // ============================================================
  final String code;
  bool solved;

  // ============================================================
  // SECTION: HINWEIS (Was der Spieler immer sieht)
  // ============================================================
  final String type; // 'text', 'image', 'audio', 'video'
  final String content; // Der Inhalt des Hinweises (Text oder Dateipfad)
  final String? description; // Optionale Beschreibung zum Hinweis

  // ============================================================
  // SECTION: OPTIONALES RÄTSEL
  // ============================================================
  final String? question; // Die Frage. Wenn dieses Feld leer ist, ist es kein Rätsel.
  final String? answer;   // Die korrekte Antwort.
  final List<String>? options; // Antwortmöglichkeiten für Multiple-Choice.
  final String? hint1; // Hilfe nach 2 falschen Versuchen.
  final String? hint2; // Hilfe nach 4 falschen Versuchen.

  // ============================================================
  // SECTION: BELOHNUNG (Was nach dem Lösen eines Rätsels angezeigt wird)
  // ============================================================
  final String? rewardText;

  // ============================================================
  // SECTION: FINALE (v1.42)
  // ============================================================
  /// Markiert diesen Hinweis als den letzten der Mission.
  final bool isFinalClue;

  // ============================================================
  // SECTION: Konstruktor
  // ============================================================
  Clue({
    required this.code,
    this.solved = false,
    required this.type,
    required this.content,
    this.description,
    this.question,
    this.answer,
    this.options,
    this.hint1,
    this.hint2,
    this.rewardText,
    this.isFinalClue = false,
  });

  // ============================================================
  // SECTION: Hilfs-Methoden (Getters)
  // ============================================================

  /// Prüft, ob dieser Hinweis ein Rätsel ist.
  bool get isRiddle => question != null && question!.isNotEmpty && answer != null;

  /// Prüft, ob das Rätsel ein Multiple-Choice-Rätsel ist.
  bool get isMultipleChoice => isRiddle && options != null && options!.isNotEmpty;

  // ============================================================
  // SECTION: JSON-Konvertierung
  // ============================================================

  /// Erstellt ein Clue-Objekt aus JSON-Daten.
  factory Clue.fromJson(String code, Map<String, dynamic> json) {
    return Clue(
      code: code,
      solved: json['solved'] ?? false,
      type: json['type'],
      content: json['content'],
      description: json['description'],
      question: json['question'],
      answer: json['answer'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      hint1: json['hint1'],
      hint2: json['hint2'],
      rewardText: json['rewardText'],
      isFinalClue: json['isFinalClue'] ?? false,
    );
  }

  /// Wandelt das Clue-Objekt in ein JSON-Format um.
  Map<String, dynamic> toJson() {
    return {
      'solved': solved,
      'type': type,
      'content': content,
      if (description != null) 'description': description,
      if (question != null) 'question': question,
      if (answer != null) 'answer': answer,
      if (options != null) 'options': options,
      if (hint1 != null) 'hint1': hint1,
      if (hint2 != null) 'hint2': hint2,
      if (rewardText != null) 'rewardText': rewardText,
      'isFinalClue': isFinalClue,
    };
  }
}
