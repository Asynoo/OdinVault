import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/password_entry.dart';
import '../services/auth_service.dart';
import '../services/auto_lock_service.dart';
import '../services/database_service.dart';
import '../utils/password_health.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/password_card.dart';
import 'add_edit_screen.dart';
import 'generator_screen.dart';
import 'totp_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with WidgetsBindingObserver {
  final _totpKey = GlobalKey<TotpScreenState>();
  int _navIndex = 0;
  List<PasswordEntry> _entries = [];
  Map<int, HealthIssue> _healthMap = {};
  String _search = '';
  bool _loading = true;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadEntries();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _checkAutoLock();
    }
  }

  Future<void> _checkAutoLock() async {
    if (_backgroundedAt == null) return;
    final enabled = await AutoLockService.isEnabled();
    if (!enabled) {
      _backgroundedAt = null;
      return;
    }
    final minutes = await AutoLockService.getMinutes();
    final elapsed = DateTime.now().difference(_backgroundedAt!).inMinutes;
    _backgroundedAt = null;
    if (elapsed >= minutes && mounted) _logout();
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final entries = await DatabaseService.getPasswords();
    final healthMap = PasswordHealth.analyze(entries);
    setState(() {
      _entries = entries;
      _healthMap = healthMap;
      _loading = false;
    });
  }

  List<PasswordEntry> get _filtered {
    if (_search.isEmpty) return _entries;
    final q = _search.toLowerCase();
    return _entries
        .where((e) =>
            e.title.toLowerCase().contains(q) ||
            e.username.toLowerCase().contains(q))
        .toList();
  }

  void _logout() {
    AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _addEntry() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddEditScreen()),
    );
    if (result == true) _loadEntries();
  }

  Future<void> _editEntry(PasswordEntry entry) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEditScreen(entry: entry)),
    );
    if (result == true) _loadEntries();
  }

  Future<void> _deleteEntry(PasswordEntry entry) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l.deleteEntryTitle,
      content: l.deleteEntryContent(entry.title),
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
    );
    if (confirmed) {
      await DatabaseService.deletePassword(entry.id!);
      _loadEntries();
    }
  }

  Widget _buildHealthBanner(AppLocalizations l) {
    final weakCount = _healthMap.values
        .where((h) => h == HealthIssue.weak || h == HealthIssue.both)
        .length;
    final dupeCount = _healthMap.values
        .where((h) => h == HealthIssue.duplicate || h == HealthIssue.both)
        .length;
    final parts = [
      if (weakCount > 0) l.weakPasswordsCount(weakCount),
      if (dupeCount > 0) l.reusedPasswordsCount(dupeCount),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha(25),
          border: Border.all(color: Colors.orange.withAlpha(80)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.shield_outlined, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Text(
              parts.join(' · '),
              style: const TextStyle(color: Colors.orange, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultTab(AppLocalizations l) {
    final hasIssues = _healthMap.values.any((h) => h != HealthIssue.none);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SearchBar(
            hintText: l.searchPasswords,
            leading: const Icon(Icons.search),
            onChanged: (v) => setState(() => _search = v),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        if (!_loading && hasIssues) _buildHealthBanner(l),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.lock_open,
                      message: _search.isEmpty
                          ? l.noPasswordsYet
                          : l.noSearchResults(_search),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final entry = _filtered[i];
                        return PasswordCard(
                          entry: entry,
                          health: _healthMap[entry.id] ?? HealthIssue.none,
                          onEdit: () => _editEntry(entry),
                          onDelete: () => _deleteEntry(entry),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tabs = [
      _buildVaultTab(l),
      TotpScreen(key: _totpKey),
      const GeneratorScreen(),
      SettingsScreen(
        onLogout: _logout,
        onDataChanged: () {
          _loadEntries();
          _totpKey.currentState?.refresh();
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l.lockVault,
            onPressed: _logout,
          ),
        ],
      ),
      body: tabs[_navIndex],
      floatingActionButton: _navIndex == 0
          ? FloatingActionButton(
              onPressed: _addEntry,
              tooltip: l.addPasswordTooltip,
              child: const Icon(Icons.add),
            )
          : _navIndex == 1
              ? TotpFab(onAdded: () => _totpKey.currentState?.refresh())
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.password), label: l.passwordsTab),
          NavigationDestination(
              icon: const Icon(Icons.security), label: l.twoFaTab),
          NavigationDestination(
              icon: const Icon(Icons.casino_outlined), label: l.generatorTab),
          NavigationDestination(
              icon: const Icon(Icons.settings), label: l.settingsTab),
        ],
      ),
    );
  }
}
