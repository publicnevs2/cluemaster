// lib/data/models/hunt.dart

import 'clue.dart';
import 'item.dart';

// ============================================================
// NEU: Die Klasse für unsere Geofence-Trigger
// ============================================================
class GeofenceTrigger {
  final String id;
  final double latitude;
  final double longitude;
  final double radius;
  final String message;
  final String? rewardItemId;
  final String? rewardClueCode; // Für zukünftige Features
  bool hasBeenTriggered;

  GeofenceTrigger({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.message,
    this.rewardItemId,
    this.rewardClueCode,
    this.hasBeenTriggered = false,
  });

  factory GeofenceTrigger.fromJson(Map<String, dynamic> json) {
    return GeofenceTrigger(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      message: json['message'],
      rewardItemId: json['rewardItemId'],
      rewardClueCode: json['rewardClueCode'],
      hasBeenTriggered: json['hasBeenTriggered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'message': message,
      if (rewardItemId != null) 'rewardItemId': rewardItemId,
      if (rewardClueCode != null) 'rewardClueCode': rewardClueCode,
      'hasBeenTriggered': hasBeenTriggered,
    };
  }
}

class Hunt {
  final String name;
  Map<String, Clue> clues;
  final String? briefingText;
  final String? briefingImageUrl;
  final int? targetTimeInMinutes;
  Map<String, Item> items;
  final List<String> startingItemIds;

  // ============================================================
  // NEU: Eine Liste für alle Geofence-Trigger dieser Jagd
  // ============================================================
  final List<GeofenceTrigger> geofenceTriggers;

  Hunt({
    required this.name,
    this.clues = const {},
    this.briefingText,
    this.briefingImageUrl,
    this.targetTimeInMinutes,
    this.items = const {},
    this.startingItemIds = const [],
    this.geofenceTriggers = const [], // NEU im Konstruktor
  });

  factory Hunt.fromJson(Map<String, dynamic> json) {
    final cluesData = json['clues'] as Map<String, dynamic>;
    final cluesMap = cluesData.map(
      (code, clueJson) => MapEntry(code, Clue.fromJson(code, clueJson)),
    );

    final itemsData = json['items'] as Map<String, dynamic>? ?? {};
    final itemsMap = itemsData.map(
      (id, itemJson) => MapEntry(id, Item.fromJson(itemJson..['id'] = id)),
    );

    return Hunt(
      name: json['name'],
      clues: cluesMap,
      briefingText: json['briefingText'] as String?,
      briefingImageUrl: json['briefingImageUrl'] as String?,
      targetTimeInMinutes: json['targetTimeInMinutes'] as int?,
      items: itemsMap,
      startingItemIds: json['startingItemIds'] != null
          ? List<String>.from(json['startingItemIds'])
          : [],
      // ============================================================
      // NEU: Liest die Geofence-Trigger aus der JSON-Datei
      // ============================================================
      geofenceTriggers: json['geofenceTriggers'] != null
          ? (json['geofenceTriggers'] as List)
              .map((triggerJson) => GeofenceTrigger.fromJson(triggerJson))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final cluesJson = clues.map(
      (code, clue) => MapEntry(code, clue.toJson()),
    );
    
    final itemsJson = items.map(
      (id, item) => MapEntry(id, item.toJson()),
    );

    // ============================================================
    // NEU: Schreibt die Geofence-Trigger in die JSON-Datei
    // ============================================================
    final geofenceTriggersJson =
        geofenceTriggers.map((trigger) => trigger.toJson()).toList();

    return {
      'name': name,
      'briefingText': briefingText,
      'briefingImageUrl': briefingImageUrl,
      if (targetTimeInMinutes != null) 'targetTimeInMinutes': targetTimeInMinutes,
      'items': itemsJson,
      'startingItemIds': startingItemIds,
      'geofenceTriggers': geofenceTriggersJson, // NEU in der JSON
      'clues': cluesJson,
    };
  }
}
