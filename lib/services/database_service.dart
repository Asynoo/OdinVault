import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_entry.dart';
import '../models/password_entry.dart';
import '../models/totp_entry.dart';

class DatabaseService {
  static const tablePasswords = 'passwords';
  static const tableTotp = 'totp_entries';
  static const tableNotes = 'notes';

  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  static const _createPasswords = '''
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
  ''';

  static const _createTotp = '''
    CREATE TABLE totp_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      issuer TEXT NOT NULL,
      encrypted_secret TEXT NOT NULL,
      digits INTEGER NOT NULL DEFAULT 6,
      period INTEGER NOT NULL DEFAULT 30,
      created_at TEXT NOT NULL
    )
  ''';

  static const _createNotes = '''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      encrypted_content TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'vaultpass.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await db.execute(_createPasswords);
        await db.execute(_createTotp);
        await db.execute(_createNotes);
      },
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) await db.execute(_createNotes);
      },
    );
  }

  static Future<List<PasswordEntry>> getPasswords() async {
    final database = await db;
    final maps = await database.query(tablePasswords, orderBy: 'title ASC');
    return maps.map(PasswordEntry.fromMap).toList();
  }

  static Future<int> insertPassword(PasswordEntry entry) async {
    final database = await db;
    return database.insert(tablePasswords, entry.toMap()..remove('id'));
  }

  static Future<void> updatePassword(PasswordEntry entry) async {
    final database = await db;
    await database.update(
      tablePasswords,
      entry.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  static Future<void> deletePassword(int id) async {
    final database = await db;
    await database.delete(tablePasswords, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<TotpEntry>> getTotpEntries() async {
    final database = await db;
    final maps = await database.query(tableTotp, orderBy: 'name ASC');
    return maps.map(TotpEntry.fromMap).toList();
  }

  static Future<int> insertTotp(TotpEntry entry) async {
    final database = await db;
    return database.insert(tableTotp, entry.toMap()..remove('id'));
  }

  static Future<void> updateTotp(TotpEntry entry) async {
    final database = await db;
    await database.update(
      tableTotp,
      entry.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  static Future<void> deleteTotp(int id) async {
    final database = await db;
    await database.delete(tableTotp, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<NoteEntry>> getNotes() async {
    final database = await db;
    final maps = await database.query(tableNotes, orderBy: 'updated_at DESC');
    return maps.map(NoteEntry.fromMap).toList();
  }

  static Future<int> insertNote(NoteEntry entry) async {
    final database = await db;
    return database.insert(tableNotes, entry.toMap()..remove('id'));
  }

  static Future<void> updateNote(NoteEntry entry) async {
    final database = await db;
    await database.update(
      tableNotes,
      entry.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  static Future<void> deleteNote(int id) async {
    final database = await db;
    await database.delete(tableNotes, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
