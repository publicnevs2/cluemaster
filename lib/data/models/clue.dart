class Clue {
  final String code;
  final String type; // 'text', 'image', 'audio' oder 'video'
  final String content;
  final String? description;
  bool solved;

  // NEUE, OPTIONALE FELDER FÜR RÄTSEL
  final String? question;
  final String? answer;

  Clue({
    required this.code,
    required this.type,
    required this.content,
    this.description,
    this.solved = false,
    this.question, // Hinzugefügt
    this.answer,   // Hinzugefügt
  });

  // Prüft, ob dieser Hinweis ein Rätsel ist.
  bool get isRiddle => question != null && answer != null;

  factory Clue.fromJson(String code, Map<String, dynamic> json) {
    return Clue(
      code: code,
      type: json['type'],
      content: json['content'],
      description: json['description'],
      solved: json['solved'] ?? false,
      // Liest die neuen Felder aus der JSON-Datei, falls sie existieren.
      question: json['question'],
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      if (description != null) 'description': description,
      'solved': solved,
      // Schreibt die neuen Felder in die JSON-Datei, falls sie existieren.
      if (question != null) 'question': question,
      if (answer != null) 'answer': answer,
    };
  }
}
