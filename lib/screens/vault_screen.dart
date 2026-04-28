import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/password_entry.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/password_card.dart';
import 'add_edit_screen.dart';
import 'totp_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final _totpKey = GlobalKey<TotpScreenState>();
  int _navIndex = 0;
  List<PasswordEntry> _entries = [];
  String _search = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final entries = await DatabaseService.getPasswords();
    setState(() {
      _entries = entries;
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

  Widget _buildVaultTab(AppLocalizations l) {
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
                      itemBuilder: (_, i) => PasswordCard(
                        entry: _filtered[i],
                        onEdit: () => _editEntry(_filtered[i]),
                        onDelete: () => _deleteEntry(_filtered[i]),
                      ),
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
      SettingsScreen(onLogout: _logout),
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
              icon: const Icon(Icons.settings), label: l.settingsTab),
        ],
      ),
    );
  }
}
