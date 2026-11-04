import 'package:flutter_test/flutter_test.dart';
import 'package:dart_app/engine/checkout_calculator.dart';

void main() {
  group('CheckoutCalculator Tests', () {
    test('170 points with 3 darts should return the Big Fish (T20, T20, Bullseye)', () {
      final request = CheckoutRequest(pointsLeft: 170, dartsLeft: 3);
      final checkouts = CheckoutCalculator.calculate(request);

      expect(checkouts, isNotNull);
      expect(checkouts, isNotEmpty);
      expect(checkouts!.first, equals(['T20', 'T20', 'Bullseye']));
    });

    test('40 points with 1 dart should return [D20]', () {
      final request = CheckoutRequest(pointsLeft: 40, dartsLeft: 1);
      final checkouts = CheckoutCalculator.calculate(request);

      expect(checkouts, isNotNull);
      expect(checkouts, isNotEmpty);
      expect(checkouts!.first, equals(['D20']));
    });

    test('50 points with 1 dart should return [Bullseye]', () {
      final request = CheckoutRequest(pointsLeft: 50, dartsLeft: 1);
      final checkouts = CheckoutCalculator.calculate(request);

      expect(checkouts, isNotNull);
      expect(checkouts, isNotEmpty);
      expect(checkouts!.first, equals(['Bullseye']));
    });

    test('Impossible checkouts (169, 168, 165, 163, 159) should return null', () {
      final impossibleScores = [169, 168, 165, 163, 159];

      for (var score in impossibleScores) {
        final request = CheckoutRequest(pointsLeft: score, dartsLeft: 3);
        final checkouts = CheckoutCalculator.calculate(request);
        expect(checkouts, isNull, reason: 'Score $score should not be checkoutable in 3 darts');
      }
    });

    test('Scores below 2 or above 170 should return null', () {
      expect(CheckoutCalculator.calculate(CheckoutRequest(pointsLeft: 1, dartsLeft: 3)), isNull);
      expect(CheckoutCalculator.calculate(CheckoutRequest(pointsLeft: 0, dartsLeft: 3)), isNull);
      expect(CheckoutCalculator.calculate(CheckoutRequest(pointsLeft: 171, dartsLeft: 3)), isNull);
    });

    test('Darts constraint: 40 points with 0 darts left should return null', () {
      final request = CheckoutRequest(pointsLeft: 40, dartsLeft: 0);
      final checkouts = CheckoutCalculator.calculate(request);
      expect(checkouts, isNull);
    });
  });
}
