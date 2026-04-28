class PasswordEntry {
  final int? id;
  final String title;
  final String username;
  final String encryptedPassword;
  final String? url;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PasswordEntry({
    this.id,
    required this.title,
    required this.username,
    required this.encryptedPassword,
    this.url,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'username': username,
        'encrypted_password': encryptedPassword,
        'url': url,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory PasswordEntry.fromMap(Map<String, dynamic> map) => PasswordEntry(
        id: map['id'] as int?,
        title: map['title'] as String,
        username: map['username'] as String,
        encryptedPassword: map['encrypted_password'] as String,
        url: map['url'] as String?,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  PasswordEntry copyWith({
    int? id,
    String? title,
    String? username,
    String? encryptedPassword,
    String? url,
    String? notes,
    DateTime? updatedAt,
  }) =>
      PasswordEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        username: username ?? this.username,
        encryptedPassword: encryptedPassword ?? this.encryptedPassword,
        url: url ?? this.url,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
