// ============================================================
// SECTION: Enum für den Rätsel-Typ (NEU)
// ============================================================
/// Definiert, welche Art von Rätsel ein Hinweis enthalten kann.
enum RiddleType {
  TEXT,           // Standard-Textfrage
  MULTIPLE_CHOICE, // Multiple-Choice-Frage
  GPS,            // GPS-Ortungs-Rätsel
}

// ============================================================
// SECTION: Clue Klasse
// ============================================================
class Clue {
  // ============================================================
  // SECTION: Kerneigenschaften
  // ============================================================
  final String code;
  bool solved;
  bool hasBeenViewed;

  // ============================================================
  // SECTION: HINWEIS (Was der Spieler immer sieht)
  // ============================================================
  final String type;
  final String content;
  final String? description;

  // ============================================================
  // SECTION: OPTIONALES RÄTSEL
  // ============================================================
  final String? question; // Die Frage. Wenn dieses Feld leer ist, ist es kein Rätsel.
  final RiddleType riddleType; // NEU: Bestimmt die Art des Rätsels
  
  // Felder für TEXT & MULTIPLE_CHOICE Rätsel
  final String? answer;
  final List<String>? options;
  final String? hint1;
  final String? hint2;

  // Felder für GPS Rätsel
  final double? latitude;
  final double? longitude;
  final double? radius;

  // ============================================================
  // SECTION: BELOHNUNG
  // ============================================================
  final String? rewardText;

  // ============================================================
  // SECTION: FINALE
  // ============================================================
  final bool isFinalClue;

  // ============================================================
  // SECTION: Konstruktor
  // ============================================================
  Clue({
    required this.code,
    this.solved = false,
    this.hasBeenViewed = false,
    required this.type,
    required this.content,
    this.description,
    this.question,
    this.riddleType = RiddleType.TEXT, // Standard ist TEXT
    this.answer,
    this.options,
    this.hint1,
    this.hint2,
    this.latitude,
    this.longitude,
    this.radius,
    this.rewardText,
    this.isFinalClue = false,
  });

  // ============================================================
  // SECTION: Hilfs-Methoden (Getters)
  // ============================================================

  /// Prüft, ob dieser Hinweis ein Rätsel ist (egal welcher Art).
  bool get isRiddle => question != null && question!.isNotEmpty;

  /// Prüft, ob das Rätsel ein GPS-Rätsel ist.
  bool get isGpsRiddle => isRiddle && riddleType == RiddleType.GPS;

  /// Prüft, ob das Rätsel ein Multiple-Choice-Rätsel ist.
  bool get isMultipleChoice => isRiddle && riddleType == RiddleType.MULTIPLE_CHOICE;

  // ============================================================
  // SECTION: JSON-Konvertierung
  // ============================================================

  factory Clue.fromJson(String code, Map<String, dynamic> json) {
    return Clue(
      code: code,
      solved: json['solved'] ?? false,
      hasBeenViewed: json['hasBeenViewed'] ?? false,
      type: json['type'],
      content: json['content'],
      description: json['description'],
      question: json['question'],
      riddleType: RiddleType.values.firstWhere(
            (e) => e.toString() == json['riddleType'],
            orElse: () => RiddleType.TEXT // Fallback für alte Daten
      ),
      answer: json['answer'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      hint1: json['hint1'],
      hint2: json['hint2'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      rewardText: json['rewardText'],
      isFinalClue: json['isFinalClue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solved': solved,
      'hasBeenViewed': hasBeenViewed,
      'type': type,
      'content': content,
      if (description != null) 'description': description,
      if (question != null) 'question': question,
      'riddleType': riddleType.toString(),
      if (answer != null) 'answer': answer,
      if (options != null) 'options': options,
      if (hint1 != null) 'hint1': hint1,
      if (hint2 != null) 'hint2': hint2,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radius != null) 'radius': radius,
      if (rewardText != null) 'rewardText': rewardText,
      'isFinalClue': isFinalClue,
    };
  }
}
