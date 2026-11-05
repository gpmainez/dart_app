import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'match_record.dart';

/// Warstwa dostępu do danych (DAO) obsługująca relacyjną bazę SQLite.
class MatchDatabase {
  static final MatchDatabase instance = MatchDatabase._init();
  static Database? _database;

  MatchDatabase._init();

  /// Konstruktor umożliwiający wstrzyknięcie instancji bazy (np. in-memory w testach jednostkowych).
  MatchDatabase.withDatabase(Database db) {
    _database = db;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dart_matches.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        winner_name TEXT NOT NULL,
        player1_name TEXT NOT NULL,
        player2_name TEXT NOT NULL,
        player1_avg REAL NOT NULL,
        player2_avg REAL NOT NULL,
        winner_checkout_pct REAL NOT NULL,
        total_180s INTEGER NOT NULL,
        played_at TEXT NOT NULL
      )
    ''');
  }

  /// Zapisanie nowego rekordu ukończonego meczu do bazy SQLite.
  Future<int> insertMatch(MatchRecord record) async {
    final db = await database;
    return await db.insert('matches', record.toMap());
  }

  /// Pobranie wszystkich rozegranych meczów w kolejności od najnowszych.
  Future<List<MatchRecord>> getAllMatches() async {
    final db = await database;
    final result = await db.query('matches', orderBy: 'id DESC');
    return result.map((map) => MatchRecord.fromMap(map)).toList();
  }

  /// Usunięcie historii meczów.
  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete('matches');
  }

  /// Zamknięcie połączenia z bazą.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
