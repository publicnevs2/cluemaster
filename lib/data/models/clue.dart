// ============================================================
// SECTION: Clue Klasse (Stark überarbeitet für Finetuning)
// ============================================================
class Clue {
  // ============================================================
  // SECTION: Kerneigenschaften
  // ============================================================
  final String code;
  bool solved;

  // ============================================================
  // SECTION: Das RÄTSEL (Was der Spieler zuerst sieht)
  // ============================================================
  final String riddleType;      // Typ des Rätsel-Mediums: 'text', 'image', 'audio', 'video'
  final String riddleContent;   // Inhalt des Rätsels: Text oder Dateipfad zum Medium
  final String? riddleDescription; // Optionale Beschreibung für das Rätsel-Medium

  final String question;        // Die Frage, die zum Rätsel-Medium gestellt wird
  final String answer;          // Die korrekte Antwort auf die Frage

  // Eigenschaften für Multiple-Choice
  final bool isMultipleChoice;
  final List<String>? options;

  // NEU: Eigenschaften für die gestaffelte Hilfe
  final String? hint1; // Hilfe nach 3 falschen Versuchen
  final String? hint2; // Hilfe nach 6 falschen Versuchen

  // ============================================================
  // SECTION: Die BELOHNUNG (Was der Spieler nach dem Lösen sieht)
  // ============================================================
  final String rewardType;      // Typ der Belohnung: 'text', 'image', 'audio', 'video'
  final String rewardContent;   // Inhalt der Belohnung: Text oder Dateipfad
  final String? rewardDescription; // Optionale Beschreibung für die Belohnung

  // ============================================================
  // SECTION: Konstruktor
  // ============================================================
  Clue({
    required this.code,
    this.solved = false,
    
    // Rätsel-Teil
    required this.riddleType,
    required this.riddleContent,
    this.riddleDescription,
    required this.question,
    required this.answer,
    this.isMultipleChoice = false,
    this.options,
    this.hint1,
    this.hint2,

    // Belohnungs-Teil
    required this.rewardType,
    required this.rewardContent,
    this.rewardDescription,
  });

  // ============================================================
  // SECTION: JSON-Konvertierung
  // ============================================================

  factory Clue.fromJson(String code, Map<String, dynamic> json) {
    return Clue(
      code: code,
      solved: json['solved'] ?? false,
      
      riddleType: json['riddleType'],
      riddleContent: json['riddleContent'],
      riddleDescription: json['riddleDescription'],
      question: json['question'],
      answer: json['answer'],
      isMultipleChoice: json['isMultipleChoice'] ?? false,
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      hint1: json['hint1'],
      hint2: json['hint2'],

      rewardType: json['rewardType'],
      rewardContent: json['rewardContent'],
      rewardDescription: json['rewardDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solved': solved,
      
      'riddleType': riddleType,
      'riddleContent': riddleContent,
      if (riddleDescription != null) 'riddleDescription': riddleDescription,
      'question': question,
      'answer': answer,
      'isMultipleChoice': isMultipleChoice,
      if (options != null) 'options': options,
      if (hint1 != null) 'hint1': hint1,
      if (hint2 != null) 'hint2': hint2,

      'rewardType': rewardType,
      'rewardContent': rewardContent,
      if (rewardDescription != null) 'rewardDescription': rewardDescription,
    };
  }
}
