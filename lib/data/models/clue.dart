// ============================================================
// SECTION: Enum für die Freischalt-Methode
// ============================================================
/// Definiert, wie ein Hinweis freigeschaltet werden kann.
enum UnlockMethod {
  CODE, // Standard: durch Eingabe des `code`
  GPS,  // Neu: durch Erreichen eines geografischen Standorts
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
  final String type; // 'text', 'image', 'audio', 'video'
  final String content; // Der Inhalt des Hinweises (Text oder Dateipfad)
  final String? description; // Optionale Beschreibung zum Hinweis

  // ============================================================
  // SECTION: OPTIONALES RÄTSEL
  // ============================================================
  final String? question;
  final String? answer;
  final List<String>? options;
  final String? hint1;
  final String? hint2;

  // ============================================================
  // SECTION: BELOHNUNG (Was nach dem Lösen eines Rätsels angezeigt wird)
  // ============================================================
  final String? rewardText;

  // ============================================================
  // SECTION: FINALE (v1.42)
  // ============================================================
  final bool isFinalClue;

  // ============================================================
  // SECTION: GPS-ERWEITERUNG (NEU)
  // ============================================================
  final UnlockMethod unlockMethod;
  final double? latitude;
  final double? longitude;
  final double? radius; // in Metern

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
    this.answer,
    this.options,
    this.hint1,
    this.hint2,
    this.rewardText,
    this.isFinalClue = false,
    // GPS-Felder im Konstruktor
    this.unlockMethod = UnlockMethod.CODE, // Standard ist CODE
    this.latitude,
    this.longitude,
    this.radius,
  });

  // ============================================================
  // SECTION: Hilfs-Methoden (Getters)
  // ============================================================

  /// Prüft, ob dieser Hinweis ein Rätsel ist.
  bool get isRiddle => question != null && question!.isNotEmpty && answer != null;

  /// Prüft, ob das Rätsel ein Multiple-Choice-Rätsel ist.
  bool get isMultipleChoice => isRiddle && options != null && options!.isNotEmpty;
  
  /// NEU: Prüft, ob dieser Hinweis per GPS freigeschaltet wird.
  bool get isGpsClue => unlockMethod == UnlockMethod.GPS && latitude != null && longitude != null;

  // ============================================================
  // SECTION: JSON-Konvertierung
  // ============================================================

  /// Erstellt ein Clue-Objekt aus JSON-Daten.
  factory Clue.fromJson(String code, Map<String, dynamic> json) {
    return Clue(
      code: code,
      solved: json['solved'] ?? false,
      hasBeenViewed: json['hasBeenViewed'] ?? false,
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
      // NEU: GPS-Felder aus JSON lesen
      unlockMethod: UnlockMethod.values.firstWhere(
            (e) => e.toString() == json['unlockMethod'],
            orElse: () => UnlockMethod.CODE // Fallback für alte Daten
      ),
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
    );
  }

  /// Wandelt das Clue-Objekt in ein JSON-Format um.
  Map<String, dynamic> toJson() {
    return {
      'solved': solved,
      'hasBeenViewed': hasBeenViewed,
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
      // NEU: GPS-Felder in JSON schreiben
      'unlockMethod': unlockMethod.toString(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radius != null) 'radius': radius,
    };
  }
}
