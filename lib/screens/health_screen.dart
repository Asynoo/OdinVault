import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/password_entry.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/password_health.dart';
import 'add_edit_screen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<PasswordEntry> _entries = [];
  Map<int, HealthIssue> _healthMap = {};
  bool _loading = true;
  bool _anyEdited = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await DatabaseService.getPasswords();
    final map = PasswordHealth.analyze(entries);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _healthMap = map;
      _loading = false;
    });
  }

  List<PasswordEntry> get _issues {
    const order = {
      HealthIssue.both: 0,
      HealthIssue.weak: 1,
      HealthIssue.duplicate: 2,
    };
    return _entries
        .where((e) => (_healthMap[e.id] ?? HealthIssue.none) != HealthIssue.none)
        .toList()
      ..sort((a, b) => (order[_healthMap[a.id]] ?? 3)
          .compareTo(order[_healthMap[b.id]] ?? 3));
  }

  Future<void> _edit(PasswordEntry entry) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEditScreen(entry: entry)),
    );
    if (result == true) {
      _anyEdited = true;
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final issues = _issues;
    final weakCount = _healthMap.values
        .where((h) => h == HealthIssue.weak || h == HealthIssue.both)
        .length;
    final dupeCount = _healthMap.values
        .where((h) => h == HealthIssue.duplicate || h == HealthIssue.both)
        .length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, r) => Navigator.of(context).pop(_anyEdited),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.healthScreenTitle),
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(_anyEdited),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : issues.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined,
                            size: 64, color: Colors.green.withAlpha(180)),
                        const SizedBox(height: 16),
                        Text(
                          l.allPasswordsHealthy,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _SummaryRow(
                          weakCount: weakCount, dupeCount: dupeCount, l: l),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: issues.length,
                          itemBuilder: (_, i) {
                            final entry = issues[i];
                            return _HealthTile(
                              entry: entry,
                              health: _healthMap[entry.id] ?? HealthIssue.none,
                              onTap: () => _edit(entry),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int weakCount;
  final int dupeCount;
  final AppLocalizations l;

  const _SummaryRow(
      {required this.weakCount, required this.dupeCount, required this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          if (weakCount > 0)
            Expanded(
              child: _StatChip(
                count: weakCount,
                label: l.strengthWeak,
                color: Colors.red,
              ),
            ),
          if (weakCount > 0 && dupeCount > 0) const SizedBox(width: 8),
          if (dupeCount > 0)
            Expanded(
              child: _StatChip(
                count: dupeCount,
                label: l.reusedPasswordWarning,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatChip(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color.withAlpha(80)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      height: 1.1)),
              Text(label,
                  style: TextStyle(color: color, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthTile extends StatelessWidget {
  final PasswordEntry entry;
  final HealthIssue health;
  final VoidCallback onTap;

  const _HealthTile(
      {required this.entry, required this.health, required this.onTap});

  Color _strengthColor(double s) {
    if (s < 0.4) return Colors.red;
    if (s < 0.7) return Colors.orange;
    return Colors.green;
  }

  String _strengthLabel(AppLocalizations l, double s) {
    if (s < 0.4) return l.strengthWeak;
    if (s < 0.7) return l.strengthFair;
    return l.strengthStrong;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final pwd = AuthService.decrypt(entry.encryptedPassword);
    final strength = PasswordHealth.strength(pwd);
    final strengthColor = _strengthColor(strength);
    final isWeak = health == HealthIssue.weak || health == HealthIssue.both;
    final isDupe = health == HealthIssue.duplicate || health == HealthIssue.both;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  entry.title[0].toUpperCase(),
                  style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    Text(entry.username,
                        style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: strength,
                              minHeight: 4,
                              backgroundColor:
                                  scheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation(
                                  strengthColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _strengthLabel(l, strength),
                          style: TextStyle(
                              fontSize: 11, color: strengthColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (isWeak)
                          _Badge(
                              label: l.weakPasswordWarning,
                              color: Colors.red),
                        if (isWeak && isDupe) const SizedBox(width: 4),
                        if (isDupe)
                          _Badge(
                              label: l.reusedPasswordWarning,
                              color: Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        border: Border.all(color: color.withAlpha(80)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500)),
    );
  }
}
