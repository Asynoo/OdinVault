import '../models/password_entry.dart';
import '../services/auth_service.dart';

enum HealthIssue { none, weak, duplicate, both }

class PasswordHealth {
  static double strength(String password) {
    if (password.isEmpty) return 0;
    double score = 0;
    if (password.length >= 8) score += 0.25;
    if (password.length >= 12) score += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.15;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  static Map<int, HealthIssue> analyze(List<PasswordEntry> entries) {
    final plaintexts = {
      for (final e in entries)
        e.id!: AuthService.decrypt(e.encryptedPassword),
    };

    final weakIds = {
      for (final e in entries)
        if (strength(plaintexts[e.id!]!) < 0.4) e.id!,
    };

    final pwdGroups = <String, List<int>>{};
    plaintexts.forEach(
        (id, pwd) => pwdGroups.putIfAbsent(pwd, () => []).add(id));
    final dupeIds = {
      for (final ids in pwdGroups.values)
        if (ids.length > 1) ...ids,
    };

    return {
      for (final e in entries)
        e.id!: switch ((weakIds.contains(e.id!), dupeIds.contains(e.id!))) {
          (true, true) => HealthIssue.both,
          (true, false) => HealthIssue.weak,
          (false, true) => HealthIssue.duplicate,
          _ => HealthIssue.none,
        },
    };
  }
}
