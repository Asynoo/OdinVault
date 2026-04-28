import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Delete "${entry.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseService.deletePassword(entry.id!);
      _loadEntries();
    }
  }

  String _decryptPassword(String encrypted) {
    final key = AuthService.sessionKey;
    if (key == null) return '';
    return EncryptionService.decrypt(encrypted, key);
  }

  Widget _buildVaultTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SearchBar(
            hintText: 'Search passwords...',
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
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_open,
                              size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text(
                            _search.isEmpty
                                ? 'No passwords yet.\nTap + to add one.'
                                : 'No results for "$_search"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white38),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => PasswordCard(
                        entry: _filtered[i],
                        getDecryptedPassword: _decryptPassword,
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
    final tabs = [
      _buildVaultTab(),
      const TotpScreen(),
      SettingsScreen(onLogout: _logout),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Odin Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Lock',
            onPressed: _logout,
          ),
        ],
      ),
      body: tabs[_navIndex],
      floatingActionButton: _navIndex == 0
          ? FloatingActionButton(
              onPressed: _addEntry,
              tooltip: 'Add password',
              child: const Icon(Icons.add),
            )
          : _navIndex == 1
              ? const TotpFab()
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.password), label: 'Passwords'),
          NavigationDestination(
              icon: Icon(Icons.security), label: '2FA'),
          NavigationDestination(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
