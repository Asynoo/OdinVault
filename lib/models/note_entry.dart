class NoteEntry {
  final int? id;
  final String title;
  final String encryptedContent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteEntry({
    this.id,
    required this.title,
    required this.encryptedContent,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'encrypted_content': encryptedContent,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory NoteEntry.fromMap(Map<String, dynamic> map) => NoteEntry(
        id: map['id'] as int?,
        title: map['title'] as String,
        encryptedContent: map['encrypted_content'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  NoteEntry copyWith({
    String? title,
    String? encryptedContent,
    DateTime? updatedAt,
  }) =>
      NoteEntry(
        id: id,
        title: title ?? this.title,
        encryptedContent: encryptedContent ?? this.encryptedContent,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
