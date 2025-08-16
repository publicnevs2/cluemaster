// lib/data/models/item.dart

// NEU: Definiert die übergeordnete Kategorie eines Items.
enum ItemCategory {
  /// Ein normales, jagd-spezifisches Item (Text, Bild etc.).
  REGULAR,
  /// Ein globales Nachschlagewerk (z.B. Morse-Alphabet).
  INFO,
  /// Ein globales, interaktives Werkzeug (z.B. Taschenlampe).
  INTERACTIVE,
}

enum ItemContentType { text, image, audio, video, interactive_widget }

class Item {
  final String id;
  final String name;
  final String thumbnailPath;
  final ItemContentType contentType;
  final String content;
  final String? description;
  final String? examineText;

  // ============================================================
  // NEU: Die Kategorie des Items
  // ============================================================
  final ItemCategory itemCategory;


  const Item({
    required this.id,
    required this.name,
    required this.thumbnailPath,
    required this.contentType,
    required this.content,
    this.description,
    this.examineText,
    this.itemCategory = ItemCategory.REGULAR, // NEU im Konstruktor
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      thumbnailPath: json['thumbnailPath'],
      contentType: ItemContentType.values.firstWhere(
        (e) => e.toString() == json['contentType'],
        orElse: () => ItemContentType.text,
      ),
      content: json['content'],
      description: json['description'],
      examineText: json['examineText'],
      // NEU: Liest die Kategorie aus der JSON, mit REGULAR als Fallback
      itemCategory: ItemCategory.values.firstWhere(
        (e) => e.toString() == json['itemCategory'],
        orElse: () => ItemCategory.REGULAR,
      ),
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
      // NEU: Schreibt die Kategorie in die JSON
      'itemCategory': itemCategory.toString(),
    };
  }
}
