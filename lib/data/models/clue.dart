// lib/data/models/clue.dart

enum RiddleType {
  TEXT,
  MULTIPLE_CHOICE,
  GPS,
  DECISION,
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

class Clue {
  final String code;
  bool solved;
  bool hasBeenViewed;
  
  // ============================================================
  // NEU: Zeitstempel für die chronologische Sortierung
  // ============================================================
  DateTime? viewedTimestamp;

  final String type;
  final String content;
  final String? description;
  final String? backgroundImagePath;
  final ImageEffect imageEffect;
  final TextEffect textEffect;
  final String? question;
  final RiddleType riddleType;
  final String? answer;
  final List<String>? options;
  final String? hint1;
  final String? hint2;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? rewardText;
  final String? nextClueCode;
  final bool isFinalClue;
  final bool autoTriggerNextClue;
  final List<String>? decisionNextClueCodes;
  final String? rewardItemId;
  final String? requiredItemId;
  final int? timedTriggerAfterSeconds;
  final String? timedTriggerMessage;
  final String? timedTriggerRewardItemId;
  final String? timedTriggerNextClueCode;

  Clue({
    required this.code,
    this.solved = false,
    this.hasBeenViewed = false,
    this.viewedTimestamp, // NEU im Konstruktor
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
    this.rewardItemId,
    this.requiredItemId,
    this.timedTriggerAfterSeconds,
    this.timedTriggerMessage,
    this.timedTriggerRewardItemId,
    this.timedTriggerNextClueCode,
    this.decisionNextClueCodes,
  });

  bool get isRiddle => question != null && question!.isNotEmpty;
  bool get isGpsRiddle => isRiddle && riddleType == RiddleType.GPS;
  bool get isMultipleChoice => isRiddle && riddleType == RiddleType.MULTIPLE_CHOICE;
  bool get isDecisionRiddle => isRiddle && riddleType == RiddleType.DECISION;

  factory Clue.fromJson(String code, Map<String, dynamic> json) {
    return Clue(
      code: code,
      solved: json['solved'] ?? false,
      hasBeenViewed: json['hasBeenViewed'] ?? false,
      // NEU: Liest den Zeitstempel aus der JSON
      viewedTimestamp: json['viewedTimestamp'] != null
          ? DateTime.tryParse(json['viewedTimestamp'])
          : null,
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
      decisionNextClueCodes: json['decisionNextClueCodes'] != null ? List<String>.from(json['decisionNextClueCodes']) : null,
      hint1: json['hint1'],
      hint2: json['hint2'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      rewardText: json['rewardText'],
      nextClueCode: json['nextClueCode'],
      isFinalClue: json['isFinalClue'] ?? false,
      autoTriggerNextClue: json['autoTriggerNextClue'] ?? true,
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
      // NEU: Schreibt den Zeitstempel in die JSON
      if (viewedTimestamp != null) 'viewedTimestamp': viewedTimestamp!.toIso8601String(),
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
      if (decisionNextClueCodes != null) 'decisionNextClueCodes': decisionNextClueCodes,
      if (hint1 != null) 'hint1': hint1,
      if (hint2 != null) 'hint2': hint2,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radius != null) 'radius': radius,
      if (rewardText != null) 'rewardText': rewardText,
      if (nextClueCode != null) 'nextClueCode': nextClueCode,
      'isFinalClue': isFinalClue,
      'autoTriggerNextClue': autoTriggerNextClue,
      if (rewardItemId != null) 'rewardItemId': rewardItemId,
      if (requiredItemId != null) 'requiredItemId': requiredItemId,
      if (timedTriggerAfterSeconds != null) 'timedTriggerAfterSeconds': timedTriggerAfterSeconds,
      if (timedTriggerMessage != null) 'timedTriggerMessage': timedTriggerMessage,
      if (timedTriggerRewardItemId != null) 'timedTriggerRewardItemId': timedTriggerRewardItemId,
      if (timedTriggerNextClueCode != null) 'timedTriggerNextClueCode': timedTriggerNextClueCode,
    };
  }
}
