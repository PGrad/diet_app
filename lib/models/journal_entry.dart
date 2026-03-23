class JournalEntry {
  final int? id;
  final String type; // 'food' or 'symptoms'
  final String content;
  final String createdAt; // ISO 8601

  JournalEntry({
    this.id,
    required this.type,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'content': content,
        'created_at': createdAt,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
        id: map['id'] as int?,
        type: map['type'] as String,
        content: map['content'] as String,
        createdAt: map['created_at'] as String,
      );

  JournalEntry copyWith({String? content}) => JournalEntry(
        id: id,
        type: type,
        content: content ?? this.content,
        createdAt: createdAt,
      );
}
