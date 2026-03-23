import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'journal.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          content TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      '''),
    );
  }

  Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;
    return db.insert('entries', entry.toMap()..remove('id'));
  }

  Future<List<JournalEntry>> getEntriesByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'entries',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );
    return maps.map(JournalEntry.fromMap).toList();
  }

  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<JournalEntry?> getTodayEntryByType(String type) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final maps = await db.query(
      'entries',
      where: 'type = ? AND created_at LIKE ?',
      whereArgs: [type, '$today%'],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return JournalEntry.fromMap(maps.first);
  }
}
