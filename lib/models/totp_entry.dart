class TotpEntry {
  final int? id;
  final String name;
  final String issuer;
  final String encryptedSecret;
  final int digits;
  final int period;
  final DateTime createdAt;

  const TotpEntry({
    this.id,
    required this.name,
    required this.issuer,
    required this.encryptedSecret,
    this.digits = 6,
    this.period = 30,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'issuer': issuer,
        'encrypted_secret': encryptedSecret,
        'digits': digits,
        'period': period,
        'created_at': createdAt.toIso8601String(),
      };

  factory TotpEntry.fromMap(Map<String, dynamic> map) => TotpEntry(
        id: map['id'] as int?,
        name: map['name'] as String,
        issuer: map['issuer'] as String,
        encryptedSecret: map['encrypted_secret'] as String,
        digits: map['digits'] as int,
        period: map['period'] as int,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
