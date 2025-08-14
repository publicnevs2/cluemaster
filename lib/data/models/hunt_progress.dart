// lib/data/models/hunt_progress.dart

class HuntProgress {
  // Eindeutiger Name der Jagd, zu der dieser Fortschritt gehört
  final String huntName;

  // KORREKTUR: `final` wurde entfernt, damit wir die Werte setzen können
  DateTime? startTime;
  DateTime? endTime;

  // KORREKTUR: `final` wurde entfernt, damit wir den Wert ändern können.
  int failedAttempts;
  int hintsUsed; // Momentan ungenutzt, aber bereit für die Zukunft

  // Die eindeutige ID dieses Eintrags, um ihn zu identifizieren
  final String progressId;

  HuntProgress({
    required this.huntName,
    this.startTime,
    this.endTime,
    this.failedAttempts = 0,
    this.hintsUsed = 0,
    String? progressId,
  }) : progressId = progressId ?? DateTime.now().toIso8601String();

  // Eine Hilfsfunktion, um die Dauer der Jagd einfach zu berechnen
  Duration get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    // Falls die Jagd noch läuft, zeige die bisherige Dauer an
    if (startTime != null) {
      return DateTime.now().difference(startTime!);
    }
    return Duration.zero;
  }


  // --- JSON-Konvertierung für die Speicherung in einer Datei ---

  factory HuntProgress.fromJson(Map<String, dynamic> json) {
    return HuntProgress(
      huntName: json['huntName'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      failedAttempts: json['failedAttempts'] ?? 0,
      hintsUsed: json['hintsUsed'] ?? 0,
      progressId: json['progressId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'huntName': huntName,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'failedAttempts': failedAttempts,
      'hintsUsed': hintsUsed,
      'progressId': progressId,
    };
  }
}