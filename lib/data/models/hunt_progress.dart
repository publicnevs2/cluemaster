// lib/data/models/hunt_progress.dart

class HuntProgress {
  final String huntName;
  DateTime? startTime;
  DateTime? endTime;
  int failedAttempts;
  int hintsUsed;
  double distanceWalkedInMeters;

  // ============================================================
  // NEU: Das Inventar des Spielers ("Rucksack")
  // ============================================================
  /// Eine Menge (Set) der IDs aller gesammelten Items.
  /// Ein Set wird verwendet, um Duplikate automatisch zu verhindern.
  Set<String> collectedItemIds;

  final String progressId;

  HuntProgress({
    required this.huntName,
    this.startTime,
    this.endTime,
    this.failedAttempts = 0,
    this.hintsUsed = 0,
    this.distanceWalkedInMeters = 0.0,
    // NEU: Initialisiert das Inventar als leeres Set.
    this.collectedItemIds = const {},
    String? progressId,
  }) : progressId = progressId ?? DateTime.now().toIso8601String();

  Duration get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    if (startTime != null) {
      return DateTime.now().difference(startTime!);
    }
    return Duration.zero;
  }

  factory HuntProgress.fromJson(Map<String, dynamic> json) {
    return HuntProgress(
      huntName: json['huntName'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      failedAttempts: json['failedAttempts'] ?? 0,
      hintsUsed: json['hintsUsed'] ?? 0,
      distanceWalkedInMeters: (json['distanceWalkedInMeters'] as num?)?.toDouble() ?? 0.0,
      // NEU: Liest die Item-IDs aus der JSON-Datei.
      collectedItemIds: json['collectedItemIds'] != null
          ? Set<String>.from(json['collectedItemIds'])
          : {},
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
      'distanceWalkedInMeters': distanceWalkedInMeters,
      // NEU: Schreibt die Item-IDs in die JSON-Datei.
      'collectedItemIds': collectedItemIds.toList(),
      'progressId': progressId,
    };
  }
}