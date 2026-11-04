import 'package:flutter_test/flutter_test.dart';
import 'package:dart_app/engine/match_manager.dart';
import 'package:dart_app/engine/models/player.dart';

void main() {
  group('MatchManager & Game Logic Tests', () {
    late MatchManager match;
    late HumanPlayer p1;
    late HumanPlayer p2;

    setUp(() {
      p1 = HumanPlayer(1, 'Player 1', 501);
      p2 = HumanPlayer(2, 'Player 2', 501);
      match = MatchManager([p1, p2], 2, 1);
    });

    test('Initial match state is correct', () {
      expect(match.currentPlayerIdx, equals(0));
      expect(match.player.points, equals(501));
      expect(match.isGameOver, isFalse);
    });

    test('Throw reduces points and records history', () {
      match.throwMade(60, 'T20');
      expect(p1.points, equals(441));
      expect(match.currentTurnScores, equals([60]));
      expect(match.currentTurnLabels, equals(['T20']));
    });

    test('Undo within turn reverts single throw', () {
      match.throwMade(60, 'T20');
      expect(p1.points, equals(441));

      match.removeVisitFromHistory();
      expect(p1.points, equals(501));
      expect(match.currentTurnScores, isEmpty);
    });

    test('Bust when score reaches 1 point', () {
      p1.points = 40;
      // Gracz rzuca 39 punktów -> zostaje 1 punkt (Bust)
      match.throwMade(39, 'T13');
      expect(p1.points, equals(1));
    });

    test('Leg won on double out', () {
      p1.points = 40;
      match.throwMade(40, 'D20', isDouble: true);
      expect(p1.points, equals(0));
    });

    test('Bot throw evaluation calculates coordinates and sectors', () {
      final bot = BotFactory.createBot(BotDifficulty.medium, 501);
      final (x, y) = bot.getTargetCoordinates('T20');
      final (radius, angle) = bot.cartesianSystemToPolar(x, y);
      final (score, isDouble, label) = bot.evaluateThrow(radius, angle);

      expect(score, equals(60));
      expect(isDouble, isFalse);
      expect(label, equals('T20'));
    });
  });
}
