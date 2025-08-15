// lib/data/models/item.dart

// Definiert die verschiedenen Arten von Inhalten, die ein Item haben kann.
// Wir fügen hier schon 'interactive_widget' für die Zukunft hinzu.
enum ItemContentType { text, image, audio, video, interactive_widget }

class Item {
  // --- KERN-EIGENSCHAFTEN ---

  /// Eindeutige ID, um das Item zu identifizieren (z.B. "morse-code-tabelle").
  final String id;

  /// Der Name, der im Inventar angezeigt wird (z.B. "Morsecode-Tabelle").
  final String name;

  /// Der Pfad zum kleinen Vorschaubild für die Rucksack-Übersicht.
  final String thumbnailPath;


  // --- INHALTS-EIGENSCHAFTEN ---

  /// Der Typ des Hauptinhalts (Text, Bild, Audio, Video etc.).
  final ItemContentType contentType;

  /// Der eigentliche Inhalt. Bei Text ist es der Text selbst.
  /// Bei Medien (Bild, Audio, Video) ist es der Pfad zur Datei.
  /// Bei interaktiven Widgets ist es eine Kennung (z.B. "caesar_cipher").
  final String content;


  // --- STORY & LORE ---

  /// Eine optionale, kurze Beschreibung oder "Flavor Text".
  final String? description;

  /// Optionaler Text, der angezeigt wird, wenn der Spieler das Item "genauer untersucht".
  /// Perfekt für versteckte Hinweise oder Story-Details.
  final String? examineText;


  const Item({
    required this.id,
    required this.name,
    required this.thumbnailPath,
    required this.contentType,
    required this.content,
    this.description,
    this.examineText,
  });

  // --- JSON-KONVERTIERUNG (für die Speicherung) ---
  // Damit wir die Items in einer Konfigurationsdatei speichern können.

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      thumbnailPath: json['thumbnailPath'],
      contentType: ItemContentType.values.firstWhere(
        (e) => e.toString() == json['contentType'],
        orElse: () => ItemContentType.text, // Fallback
      ),
      content: json['content'],
      description: json['description'],
      examineText: json['examineText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnailPath': thumbnailPath,
      'contentType': contentType.toString(),
      'content': content,
      'description': description,
      'examineText': examineText,
    };
  }
}