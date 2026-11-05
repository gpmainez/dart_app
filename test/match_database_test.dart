import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dart_app/data/database/match_database.dart';
import 'package:dart_app/data/database/match_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja FFI do testów SQLite w środowisku desktopowym / test runnerze Dart
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('MatchDatabase (SQLite) Tests', () {
    late Database inMemoryDb;
    late MatchDatabase matchDb;

    setUp(() async {
      inMemoryDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await inMemoryDb.execute('''
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
      matchDb = MatchDatabase.withDatabase(inMemoryDb);
    });

    tearDown(() async {
      await inMemoryDb.close();
    });

    test('Insert match and retrieve from SQLite database', () async {
      const match = MatchRecord(
        winnerName: 'Gracz 1',
        player1Name: 'Gracz 1',
        player2Name: 'Pro Bot',
        player1Average: 84.5,
        player2Average: 71.2,
        winnerCheckoutPercentage: 40.0,
        total180s: 2,
        playedAt: '2026-11-05 19:30',
      );

      final id = await matchDb.insertMatch(match);
      expect(id, isPositive);

      final matches = await matchDb.getAllMatches();
      expect(matches.length, equals(1));
      expect(matches.first.winnerName, equals('Gracz 1'));
      expect(matches.first.player1Average, equals(84.5));
      expect(matches.first.total180s, equals(2));
    });

    test('Clear history empties the matches table', () async {
      const match1 = MatchRecord(
        winnerName: 'Gracz 1',
        player1Name: 'Gracz 1',
        player2Name: 'Gracz 2',
        player1Average: 65.0,
        player2Average: 60.0,
        winnerCheckoutPercentage: 33.3,
        total180s: 0,
        playedAt: '2026-11-05 19:00',
      );

      await matchDb.insertMatch(match1);
      final beforeDelete = await matchDb.getAllMatches();
      expect(beforeDelete.length, equals(1));

      await matchDb.clearHistory();
      final afterDelete = await matchDb.getAllMatches();
      expect(afterDelete, isEmpty);
    });
  });
}
