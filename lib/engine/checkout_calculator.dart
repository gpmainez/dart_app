import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

///  cel na tarczy (np. D20, T19, Bullseye) z przypisaną wagą trudności
class DartTarget {
  final String name;
  final int score;
  final int weight;
  final bool isDouble;

  const DartTarget({
    required this.name,
    required this.score,
    required this.weight,
    this.isDouble = false,
  });
}

/// stan w kolejce priorytetowej do przeszukiwania ścieżki checkoutu.
class SearchState {
  final int scoreRemaining;
  final int accumulatedWeight;
  final int dartsThrown;
  final List<String> pathHistory;
  final bool lastWasDouble;

  SearchState({
    required this.scoreRemaining,
    required this.accumulatedWeight,
    required this.dartsThrown,
    required this.pathHistory,
    required this.lastWasDouble,
  });
}

/// oblsugiwanie checkoutow – uwzględnia punkty, liczbę lotek i preferencje gracza.
class CheckoutRequest {
  final int pointsLeft;
  final int dartsLeft;
  final Map<String, double> targetWeights;

  CheckoutRequest({
    required this.pointsLeft,
    required this.dartsLeft,
    this.targetWeights = const {},
  });

  String get cacheKey {
    int weightsHash = const MapEquality().hash(targetWeights);
    return '${pointsLeft}_${dartsLeft}_$weightsHash';
  }
}

///  kalkulacja z pamięcią podręczną i opcjonalnym odpalaniem w Isolate przez compute.
class CheckoutProcess {
  static final Map<String, List<List<String>>> _cache = {};

  static Future<List<List<String>>?> getCheckout(
    CheckoutRequest request,
  ) async {
    if (_cache.containsKey(request.cacheKey)) {
      return _cache[request.cacheKey];
    }

    final result = await compute(CheckoutCalculator.calculate, request);

    if (result != null) {
      _cache[request.cacheKey] = result;
    }

    return result;
  }

  static void clearCache() {
    _cache.clear();
  }
}

/// algorytm  optymalnych checkoutów kolejka priorytetowej (Dijkstra / branch-and-bound).
class CheckoutCalculator {
  static final List<DartTarget> allBoardTargets = [
    const DartTarget(name: 'Outer Bull', score: 25, weight: 3, isDouble: false),
    const DartTarget(name: 'Bullseye', score: 50, weight: 5, isDouble: true),

    for (int i = 1; i <= 20; i++) ...[
      DartTarget(name: 'S$i', score: i, weight: 1, isDouble: false),
      DartTarget(name: 'D$i', score: i * 2, weight: 2, isDouble: true),
      DartTarget(name: 'T$i', score: i * 3, weight: 3, isDouble: false),
    ],
  ];

  static List<List<String>>? calculate(CheckoutRequest request) {
    if (request.pointsLeft > 170 || request.pointsLeft < 2) return null;

    var bestCosts = List.generate(171, (_) => List.filled(4, 10000));
    List<List<String>> foundCheckouts = [];

    var queue = PriorityQueue<SearchState>(
      (a, b) => a.accumulatedWeight.compareTo(b.accumulatedWeight),
    );

    queue.add(
      SearchState(
        scoreRemaining: request.pointsLeft,
        accumulatedWeight: 0,
        dartsThrown: 0,
        pathHistory: [],
        lastWasDouble: false,
      ),
    );
    bestCosts[request.pointsLeft][0] = 0;

    while (queue.isNotEmpty) {
      var currentState = queue.removeFirst();

      // wygrana jesli pozostało dokładnie 0 punktów i ostatni rzut trafił w Double
      if (currentState.scoreRemaining == 0 && currentState.lastWasDouble) {
        foundCheckouts.add(currentState.pathHistory);
        if (foundCheckouts.length >= 8) return foundCheckouts;
        continue;
      }

      if (currentState.dartsThrown == request.dartsLeft) continue;

      for (var target in allBoardTargets) {
        int newScore = currentState.scoreRemaining - target.score;

        // W darcie nie można zostawić 1 punktu (nie da się skończyć na double) ani zejść poniżej zera
        if (newScore < 0 || newScore == 1) continue;

        double playerModifier = request.targetWeights[target.name] ?? 1.0;

        int finalTargetWeight = (target.weight * playerModifier).round();
        int newWeight = currentState.accumulatedWeight + finalTargetWeight + 1;
        int newDartsThrown = currentState.dartsThrown + 1;

        if (newWeight <= bestCosts[newScore][newDartsThrown] + 2) {
          if (newWeight < bestCosts[newScore][newDartsThrown]) {
            bestCosts[newScore][newDartsThrown] = newWeight;
          }
          var newPath = List<String>.from(currentState.pathHistory)
            ..add(target.name);

          queue.add(
            SearchState(
              scoreRemaining: newScore,
              accumulatedWeight: newWeight,
              dartsThrown: newDartsThrown,
              pathHistory: newPath,
              lastWasDouble: target.isDouble,
            ),
          );
        }
      }
    }

    return foundCheckouts.isNotEmpty ? foundCheckouts : null;
  }
}
