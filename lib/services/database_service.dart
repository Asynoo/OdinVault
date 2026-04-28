import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_entry.dart';
import '../models/totp_entry.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'vaultpass.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE passwords (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            username TEXT NOT NULL,
            encrypted_password TEXT NOT NULL,
            url TEXT,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE totp_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            issuer TEXT NOT NULL,
            encrypted_secret TEXT NOT NULL,
            digits INTEGER NOT NULL DEFAULT 6,
            period INTEGER NOT NULL DEFAULT 30,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<List<PasswordEntry>> getPasswords() async {
    final database = await db;
    final maps = await database.query('passwords', orderBy: 'title ASC');
    return maps.map(PasswordEntry.fromMap).toList();
  }

  static Future<int> insertPassword(PasswordEntry entry) async {
    final database = await db;
    return database.insert('passwords', entry.toMap()..remove('id'));
  }

  static Future<void> updatePassword(PasswordEntry entry) async {
    final database = await db;
    await database.update(
      'passwords',
      entry.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  static Future<void> deletePassword(int id) async {
    final database = await db;
    await database.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<TotpEntry>> getTotpEntries() async {
    final database = await db;
    final maps = await database.query('totp_entries', orderBy: 'name ASC');
    return maps.map(TotpEntry.fromMap).toList();
  }

  static Future<int> insertTotp(TotpEntry entry) async {
    final database = await db;
    return database.insert('totp_entries', entry.toMap()..remove('id'));
  }

  static Future<void> deleteTotp(int id) async {
    final database = await db;
    await database.delete('totp_entries', where: 'id = ?', whereArgs: [id]);
  }
}
