import 'dart:math';
import '../checkout_calculator.dart';

/// Zapis pojedynczej tury (wizyty przy tarczy - maks. 3 lotki).
class Visit {
  final int playerId;
  final int score;
  final int dartsThrown;
  final int dartsAtDouble;
  bool isBust;
  final int pointsBeforeThrow;

  Visit({
    required this.playerId,
    required this.score,
    this.dartsThrown = 0,
    this.dartsAtDouble = 0,
    required this.pointsBeforeThrow,
    this.isBust = false,
  });
}

/// Klasa bazowa dla zawodnika (człowiek lub bot).
abstract class Player {
  final int id;
  final String name;
  final int startingPoints;
  Map<String, double> targetWeights = {};

  int points;
  int legs = 0;
  int sets = 0;
  final List<Visit> _matchHistory = [];

  Player(this.id, this.name, this.startingPoints) : points = startingPoints;

  List<Visit> get matchHistory => List.unmodifiable(_matchHistory);

  void addVisit(Visit visit) {
    _matchHistory.add(visit);
  }

  void undoLastVisit() {
    if (_matchHistory.isNotEmpty) {
      var last = _matchHistory.removeLast();
      points = last.pointsBeforeThrow;
    }
  }

  void legWon() {
    legs++;
  }

  void setWon() {
    sets++;
    legs = 0;
  }

  void resetPoints() {
    points = startingPoints;
  }

  /// Średnia z 3 lotek (3-dart average)
  double get average {
    if (_matchHistory.isEmpty) return 0.0;

    int totalPoints = _matchHistory
        .where((v) => !v.isBust)
        .fold(0, (sum, v) => sum + v.score);
    int totalDarts = _matchHistory.fold(0, (sum, v) => sum + v.dartsThrown);

    if (totalDarts == 0) return 0.0;
    return totalPoints / (totalDarts / 3);
  }

  /// Skuteczność na doublach w procentach
  double get checkoutPercentage {
    int attempts = _matchHistory.fold(0, (sum, v) => sum + v.dartsAtDouble);
    if (attempts == 0) return 0.0;

    return (legs / attempts) * 100;
  }

  int get count100s =>
      _matchHistory.where((v) => v.score >= 100 && v.score < 140).length;

  int get count140s =>
      _matchHistory.where((v) => v.score >= 140 && v.score < 180).length;

  int get count180s => _matchHistory.where((v) => v.score == 180).length;

  /// Zwiększenie kary dla sektora, w który gracz nie trafia (algorytm rzadziej go wybierze)
  void penalizeTarget(String targetName) {
    double currentWeight = targetWeights[targetName] ?? 1.0;

    if (currentWeight < 5.0) {
      targetWeights[targetName] = currentWeight * 1.1;
    }

    CheckoutProcess.clearCache();
  }

  /// Nagrodzenie ulubionego sektora gracza
  void rewardTarget(String targetName) {
    double currentWeight = targetWeights[targetName] ?? 1.0;

    if (currentWeight > 0.5) {
      targetWeights[targetName] = currentWeight * 0.95;
    }

    CheckoutProcess.clearCache();
  }

  /// Reset stanu gracza na potrzeby nowego meczu
  void resetFull() {
    points = startingPoints;
    legs = 0;
    sets = 0;
    _matchHistory.clear();
  }
}

/// Gracz sterowany przez człowieka
class HumanPlayer extends Player {
  HumanPlayer(super.id, super.name, super.startingPoints);
}

/// Gracz symulowany przez komputer z modelowaniem rozrzutu metodą Gaussa
class BotPlayer extends Player {
  final int botAverage;
  static final Random _random = Random();

  // Kolejność liczb na tarczy zgodnie z ruchem wskazówek zegara (od góry/godziny 12: 20 jest u góry)
  // Indeksy względem układu biegunowego (gdzie kąt 0 stopni to oś X / godzina 3)
  static const List<int> dartboardNumbers = [
    6,
    10,
    15,
    2,
    17,
    3,
    19,
    7,
    16,
    8,
    11,
    14,
    9,
    12,
    5,
    20,
    1,
    18,
    4,
    13,
  ];

  BotPlayer(super.id, super.name, super.startingPoints, this.botAverage);

  /// Odchylenie standardowe błędu rzutu – im wyższa średnia bota, tym mniejszy rozrzut
  double get sigma => 1000.0 / botAverage;

  /// Konwersja współrzędnych kartezjańskich (x, y w mm) na biegunowe (promień, kąt w stopniach)
  (double, double) cartesianSystemToPolar(double x, double y) {
    double radius = sqrt(x * x + y * y);

    double angleInRadians = atan2(y, x);
    double angleInDegrees = angleInRadians * (180 / pi);

    if (angleInDegrees < 0) {
      angleInDegrees += 360;
    }

    return (radius, angleInDegrees);
  }

  /// Generowanie liczby losowej o rozkładzie normalnym N(0, 1) transformacją Boxa-Mullera
  static double _gaussianRandom() {
    double u1 = _random.nextDouble();
    double u2 = _random.nextDouble();

    if (u1 == 0.0) u1 = 0.000001;

    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }

  /// Symulacja pojedynczego rzutu z odchyleniem gaussowskim
  (double, double) singleThrow(double targetX, double targetY, double sigma) {
    double offsetX = _gaussianRandom() * sigma;
    double offsetY = _gaussianRandom() * sigma;

    return (targetX + offsetX, targetY + offsetY);
  }

  /// Zwraca fizyczne współrzędne (x, y) środka danego sektora na tarczy
  (double, double) getTargetCoordinates(String targetName) {
    if (targetName == "Bullseye" || targetName == "BULLSEYE") return (0.0, 0.0);
    if (targetName == "Outer Bull" || targetName == "OUTER BULL") return (0.0, 11.0);
    if (targetName == "Miss" || targetName == "MISS") return (0.0, 180.0);

    String type = targetName[0];
    int number = int.parse(targetName.substring(1));

    double radius = switch (type) {
      'T' => 103.0,
      'D' => 166.0,
      _ => 134.0,
    };

    int index = dartboardNumbers.indexOf(number);
    double angleInDegrees = index * 18.0;
    double angleInRadians = angleInDegrees * (pi / 180.0);

    double x = radius * cos(angleInRadians);
    double y = radius * sin(angleInRadians);

    return (x, y);
  }

  /// Ewaluacja punktowa i sektorowa trafienia na podstawie promienia i kąta
  (int, bool, String) evaluateThrow(double radius, double angleInDegrees) {
    if (radius <= 6.35) {
      return (50, true, "Bullseye");
    }
    if (radius <= 15.9) {
      return (25, false, "Outer Bull");
    }

    if (radius > 170.0) {
      return (0, false, "Miss");
    }

    int index = ((angleInDegrees + 9) % 360) ~/ 18;
    int baseScore = dartboardNumbers[index];

    if (radius > 99.0 && radius <= 107.0) {
      return (baseScore * 3, false, "T$baseScore");
    } else if (radius > 162.0 && radius <= 170.0) {
      return (baseScore * 2, true, "D$baseScore");
    } else {
      return (baseScore, false, "S$baseScore");
    }
  }

  /// Wybór sektora, w który bot ma celować (kalkulator checkoutu lub potrójne 20)
  String decideTarget(int currentPoints, int dartsLeft) {
    if (currentPoints <= 170) {
      var request = CheckoutRequest(
        pointsLeft: currentPoints,
        dartsLeft: dartsLeft,
        targetWeights: targetWeights,
      );

      var checkouts = CheckoutCalculator.calculate(request);
      if (checkouts != null && checkouts.isNotEmpty) {
        return checkouts[0][0];
      }
    }
    return "T20";
  }
}

enum BotDifficulty { easy, medium, hard }

class BotFactory {
  static BotPlayer createBot(BotDifficulty difficulty, int startingScore, {int id = 2}) {
    switch (difficulty) {
      case BotDifficulty.easy:
        return BotPlayer(id, 'Rookie Bot', startingScore, 40);
      case BotDifficulty.medium:
        return BotPlayer(id, 'Pro Bot', startingScore, 70);
      case BotDifficulty.hard:
        return BotPlayer(id, 'Phil Taylor Bot', startingScore, 120);
    }
  }
}
