// lib/data/models/clue.dart

// SECTION: Enums für Rätsel-Typen und Effekte
enum RiddleType {
  TEXT,
  MULTIPLE_CHOICE,
  GPS,
}

enum ImageEffect {
  NONE,
  PUZZLE,
  INVERT_COLORS,
  BLACK_AND_WHITE,
}

enum TextEffect {
  NONE,
  MORSE_CODE,
  REVERSE,
  NO_VOWELS,
  MIRROR_WORDS,
}

// SECTION: Clue Klasse
class Clue {
  // --- Kerneigenschaften ---
  final String code;
  bool solved;
  bool hasBeenViewed;

  // --- HINWEIS (Was der Spieler immer sieht) ---
  final String type;
  final String content;
  final String? description;
  final String? backgroundImagePath;
  final ImageEffect imageEffect;
  final TextEffect textEffect;

  // --- OPTIONALES RÄTSEL ---
  final String? question;
  final RiddleType riddleType;
  final String? answer;
  final List<String>? options;
  final String? hint1;
  final String? hint2;
  final double? latitude;
  final double? longitude;
  final double? radius;

  // --- BELOHNUNG & NÄCHSTER SCHRITT ---
  final String? rewardText;
  final String? nextClueCode;
  final bool isFinalClue;
  final bool autoTriggerNextClue;

  // ============================================================
  // NEU: FELDER FÜR DAS INVENTAR-SYSTEM
  // ============================================================
  /// Die ID des Items, das der Spieler als Belohnung erhält.
  final String? rewardItemId;

  /// Die ID des Items, das der Spieler besitzen muss, um diesen Hinweis zu sehen.
  final String? requiredItemId;

  // ============================================================
  // NEU: FELDER FÜR ZEITGESTEUERTE TRIGGER
  // ============================================================
  /// Nach wie vielen Sekunden soll der Timer auslösen?
  final int? timedTriggerAfterSeconds;

  /// Welche Nachricht soll im Timer-Popup angezeigt werden?
  final String? timedTriggerMessage;

  /// Welches Item soll der Timer als Belohnung geben?
  final String? timedTriggerRewardItemId;

  /// Welchen Code soll der Timer als Belohnung geben?
  final String? timedTriggerNextClueCode;


  // SECTION: Konstruktor
  Clue({
    required this.code,
    this.solved = false,
    this.hasBeenViewed = false,
    required this.type,
    required this.content,
    this.description,
    this.backgroundImagePath,
    this.imageEffect = ImageEffect.NONE,
    this.textEffect = TextEffect.NONE,
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
    this.nextClueCode,
    this.isFinalClue = false,
    this.autoTriggerNextClue = true,
    // NEUE Felder im Konstruktor
    this.rewardItemId,
    this.requiredItemId,
    this.timedTriggerAfterSeconds,
    this.timedTriggerMessage,
    this.timedTriggerRewardItemId,
    this.timedTriggerNextClueCode,
  });

  // SECTION: Hilfs-Methoden (Getters)
  bool get isRiddle => question != null && question!.isNotEmpty;
  bool get isGpsRiddle => isRiddle && riddleType == RiddleType.GPS;
  bool get isMultipleChoice =>
      isRiddle && riddleType == RiddleType.MULTIPLE_CHOICE;

  // SECTION: JSON-Konvertierung
  factory Clue.fromJson(String code, Map<String, dynamic> json) {
    return Clue(
      code: code,
      solved: json['solved'] ?? false,
      hasBeenViewed: json['hasBeenViewed'] ?? false,
      type: json['type'],
      content: json['content'],
      description: json['description'],
      backgroundImagePath: json['backgroundImagePath'],
      imageEffect: ImageEffect.values.firstWhere(
          (e) => e.toString() == json['imageEffect'],
          orElse: () => ImageEffect.NONE),
      textEffect: TextEffect.values.firstWhere(
          (e) => e.toString() == json['textEffect'],
          orElse: () => TextEffect.NONE),
      question: json['question'],
      riddleType: RiddleType.values.firstWhere(
          (e) => e.toString() == json['riddleType'], orElse: () {
        if (json['options'] != null && (json['options'] as List).isNotEmpty) {
          return RiddleType.MULTIPLE_CHOICE;
        }
        return RiddleType.TEXT;
      }),
      answer: json['answer'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      hint1: json['hint1'],
      hint2: json['hint2'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      rewardText: json['rewardText'],
      nextClueCode: json['nextClueCode'],
      isFinalClue: json['isFinalClue'] ?? false,
      autoTriggerNextClue: json['autoTriggerNextClue'] ?? true,
      // NEUE Felder aus JSON lesen
      rewardItemId: json['rewardItemId'],
      requiredItemId: json['requiredItemId'],
      timedTriggerAfterSeconds: json['timedTriggerAfterSeconds'],
      timedTriggerMessage: json['timedTriggerMessage'],
      timedTriggerRewardItemId: json['timedTriggerRewardItemId'],
      timedTriggerNextClueCode: json['timedTriggerNextClueCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solved': solved,
      'hasBeenViewed': hasBeenViewed,
      'type': type,
      'content': content,
      if (description != null) 'description': description,
      if (backgroundImagePath != null) 'backgroundImagePath': backgroundImagePath,
      'imageEffect': imageEffect.toString(),
      'textEffect': textEffect.toString(),
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
      if (nextClueCode != null) 'nextClueCode': nextClueCode,
      'isFinalClue': isFinalClue,
      'autoTriggerNextClue': autoTriggerNextClue,
      // NEUE Felder in JSON schreiben
      if (rewardItemId != null) 'rewardItemId': rewardItemId,
      if (requiredItemId != null) 'requiredItemId': requiredItemId,
      if (timedTriggerAfterSeconds != null) 'timedTriggerAfterSeconds': timedTriggerAfterSeconds,
      if (timedTriggerMessage != null) 'timedTriggerMessage': timedTriggerMessage,
      if (timedTriggerRewardItemId != null) 'timedTriggerRewardItemId': timedTriggerRewardItemId,
      if (timedTriggerNextClueCode != null) 'timedTriggerNextClueCode': timedTriggerNextClueCode,
    };
  }
}