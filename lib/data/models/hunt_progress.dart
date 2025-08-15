// lib/data/models/hunt_progress.dart

class HuntProgress {
  final String huntName;
  DateTime? startTime;
  DateTime? endTime;
  int failedAttempts;
  int hintsUsed;

  // HIER IST DIE FEHLENDE ZEILE:
  double distanceWalkedInMeters;

  final String progressId;

  HuntProgress({
    required this.huntName,
    this.startTime,
    this.endTime,
    this.failedAttempts = 0,
    this.hintsUsed = 0,
    // UND HIER:
    this.distanceWalkedInMeters = 0.0,
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
      // UND HIER:
      distanceWalkedInMeters: (json['distanceWalkedInMeters'] as num?)?.toDouble() ?? 0.0,
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
      // UND HIER:
      'distanceWalkedInMeters': distanceWalkedInMeters,
      'progressId': progressId,
    };
  }
}