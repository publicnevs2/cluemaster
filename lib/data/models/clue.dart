// ============================================================
// SECTION: Enums für Rätsel-Typen und Effekte
// ============================================================

/// Definiert, welche Art von Rätsel ein Hinweis enthalten kann.
enum RiddleType {
  TEXT,
  MULTIPLE_CHOICE,
  GPS,
}

/// Definiert, welcher visuelle Effekt auf einen Bild-Hinweis angewendet wird.
enum ImageEffect {
  NONE,
  PUZZLE,
  INVERT_COLORS,
  BLACK_AND_WHITE,
}

/// NEU: Definiert, welcher Effekt auf einen Text-Hinweis angewendet wird.
enum TextEffect {
  NONE,           // Normaler Text
  MORSE_CODE,     // Text als Morsecode
  REVERSE,        // Kompletter Text rückwärts
  NO_VOWELS,      // Alle Vokale entfernt
  MIRROR_WORDS,   // Buchstaben jedes Wortes spiegeln
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
  final ImageEffect imageEffect;
  final TextEffect textEffect; // NEU: Feld für den Text-Effekt

  // ============================================================
  // SECTION: OPTIONALES RÄTSEL
  // ============================================================
  final String? question;
  final RiddleType riddleType;
  
  final String? answer;
  final List<String>? options;
  final String? hint1;
  final String? hint2;

  final double? latitude;
  final double? longitude;
  final double? radius;

  // ============================================================
  // SECTION: BELOHNUNG & FINALE
  // ============================================================
  final String? rewardText;
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
    this.imageEffect = ImageEffect.NONE,
    this.textEffect = TextEffect.NONE, // NEU: Standardwert ist NONE
    this.question,
    this.riddleType = RiddleType.TEXT,
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
  bool get isRiddle => question != null && question!.isNotEmpty;
  bool get isGpsRiddle => isRiddle && riddleType == RiddleType.GPS;
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
      imageEffect: ImageEffect.values.firstWhere(
            (e) => e.toString() == json['imageEffect'],
            orElse: () => ImageEffect.NONE
      ),
      textEffect: TextEffect.values.firstWhere( // NEU: Aus JSON lesen
            (e) => e.toString() == json['textEffect'],
            orElse: () => TextEffect.NONE
      ),
      question: json['question'],
      riddleType: RiddleType.values.firstWhere(
            (e) => e.toString() == json['riddleType'],
            orElse: () {
              if (json['options'] != null && (json['options'] as List).isNotEmpty) {
                return RiddleType.MULTIPLE_CHOICE;
              }
              return RiddleType.TEXT;
            }
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
      'imageEffect': imageEffect.toString(),
      'textEffect': textEffect.toString(), // NEU: In JSON schreiben
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
