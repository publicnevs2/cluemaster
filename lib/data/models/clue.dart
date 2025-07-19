class Clue {
  final String code;
  final String type; // 'text', 'image' oder 'audio'
  final String content;
  final String? description;
  bool solved;

  Clue({
    required this.code,
    required this.type,
    required this.content,
    this.description,
    this.solved = false,
  });

  factory Clue.fromJson(String code, Map<String, dynamic> json) {
    return Clue(
      code: code,
      type: json['type'],
      content: json['content'],
      description: json['description'],
      solved: json['solved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      if (description != null) 'description': description,
      'solved': solved,
    };
  }
}