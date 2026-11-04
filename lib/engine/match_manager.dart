import 'dart:async';
import 'package:flutter/foundation.dart';
import 'checkout_calculator.dart';
import 'models/player.dart';

/// klasa stanu meczu i reguł gry w Darta (501/301) i turami zawodników
class MatchManager extends ChangeNotifier {
  final List<Player> playersInGame;
  final List<Visit> matchScores = [];

  int playerStartingSet = 0;
  int currentPlayerIdx = 0;
  int startingLegPlayerIdx = 0;

  int dartsThrownThisTurn = 0;
  int dartsAtDoubleThisTurn = 0;
  List<int> currentTurnScores = [];
  List<String> currentTurnLabels = [];
  int pointsBeforeTurn = 0;

  int numberOfLegs;
  int numberOfSets;
  int numberOfThrows = 0;

  bool isGameOver = false;
  Player? winner;
  String currentCheckoutHint = " ";
  bool isBotThrowing = false;

  MatchManager(this.playersInGame, this.numberOfLegs, this.numberOfSets);

  Player get player => playersInGame[currentPlayerIdx];

  /// Zarejestrowanie pojedynczego rzutu lotką
  void throwMade(int score, String label, {bool isDouble = false}) {
    if (dartsThrownThisTurn == 0) {
      pointsBeforeTurn = player.points;
    }

    // Wykrywanie próby rzutu na double
    bool wasDoubleAttempt = false;
    if (player.points == 50 && (label == 'Bullseye' || label == 'Outer Bull')) {
      wasDoubleAttempt = true;
    } else if (player.points <= 40 && player.points % 2 == 0) {
      String expectedDouble = 'D${player.points ~/ 2}';
      // Rzut był próbą na double, jeśli trafiono w oczekiwany double LUB w pojedynczy sektor tego samego numeru (pudło obok)
      if (label == expectedDouble || label == 'S${player.points ~/ 2}') {
        wasDoubleAttempt = true;
      }
    }

    if (wasDoubleAttempt) {
      dartsAtDoubleThisTurn++;
      String targetDouble = player.points == 50 ? 'Bullseye' : 'D${player.points ~/ 2}';
      if (isDouble && (label == targetDouble)) {
        player.rewardTarget(targetDouble);
      } else {
        player.penalizeTarget(targetDouble);
      }
    }

    currentTurnScores.add(score);
    currentTurnLabels.add(label);
    dartsThrownThisTurn++;
    player.points -= score;

    bool isBust = false;
    bool isWin = false;

    // BUST: mniej niż 0, dokładnie 1 punkt lub 0 bez podwójnego
    if (player.points < 0 || player.points == 1) {
      isBust = true;
    } else if (player.points == 0) {
      if (isDouble) {
        isWin = true;
      } else {
        isBust = true;
      }
    }

    updateCheckoutHint();
    notifyListeners();

    if (dartsThrownThisTurn == 3 || isBust || isWin) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _finalizeTurn(isBust, isWin);
      });
    }
  }

  void _finalizeTurn(bool isBust, bool isWin) {
    int totalScore = currentTurnScores.fold(0, (sum, val) => sum + val);

    if (isBust) {
      player.points = pointsBeforeTurn;
      totalScore = 0;
    }

    var visit = Visit(
      playerId: player.id,
      score: totalScore,
      dartsThrown: dartsThrownThisTurn,
      dartsAtDouble: dartsAtDoubleThisTurn,
      pointsBeforeThrow: pointsBeforeTurn,
      isBust: isBust,
    );

    matchScores.add(visit);
    player.addVisit(visit);

    currentTurnScores.clear();
    currentTurnLabels.clear();
    dartsThrownThisTurn = 0;
    dartsAtDoubleThisTurn = 0;

    if (isWin) {
      _handleWin();
    } else {
      _switchPlayer();
      notifyListeners();
    }
  }

  /// Cofnięcie ostatniego rzutu lub całej wizyty
  void removeVisitFromHistory() {
    if (isBotThrowing) return; // Blokada podczas rzutu bota

    if (dartsThrownThisTurn > 0) {
      int lastScore = currentTurnScores.removeLast();
      currentTurnLabels.removeLast();
      dartsThrownThisTurn--;
      player.points += lastScore;
    } else {
      if (matchScores.isEmpty) return;

      var lastVisit = matchScores.removeLast();
      var playerToUndo = playersInGame.firstWhere(
        (p) => p.id == lastVisit.playerId,
      );

      playerToUndo.undoLastVisit();
      currentPlayerIdx = playersInGame.indexOf(playerToUndo);

      currentTurnScores.clear();
      currentTurnLabels.clear();
      dartsThrownThisTurn = 0;
    }

    updateCheckoutHint();
    notifyListeners();
  }

  /// Tura bota z sekwencją rzutów z opóźnieniem symulującym myślenie
  void _executeBotTurn(BotPlayer bot) async {
    isBotThrowing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    while (!isGameOver && player.id == bot.id && dartsThrownThisTurn < 3) {
      String targetName = bot.decideTarget(
        player.points,
        3 - dartsThrownThisTurn,
      );

      var (targetX, targetY) = bot.getTargetCoordinates(targetName);
      var (hitX, hitY) = bot.singleThrow(targetX, targetY, bot.sigma);
      var (radius, angle) = bot.cartesianSystemToPolar(hitX, hitY);
      var (score, isDouble, hitName) = bot.evaluateThrow(radius, angle);

      throwMade(score, hitName, isDouble: isDouble);

      if (player.points <= 1 ||
          player.points == 0 ||
          dartsThrownThisTurn == 3) {
        break;
      }

      await Future.delayed(const Duration(milliseconds: 1000));
    }

    isBotThrowing = false;
    notifyListeners();
  }

  void _handleWin() {
    player.legWon();

    if (player.legs == numberOfLegs) {
      player.setWon();
      player.legs = 0;

      if (player.sets == numberOfSets) {
        _endGame(player);
        notifyListeners();
        return;
      }
      playerStartingSet = (playerStartingSet + 1) % playersInGame.length;
      startingLegPlayerIdx = playerStartingSet;
    } else {
      startingLegPlayerIdx = (startingLegPlayerIdx + 1) % playersInGame.length;
    }

    _resetPoints();
    currentPlayerIdx = startingLegPlayerIdx;

    notifyListeners();
    startCurrentTurn();
  }

  void _resetPoints() {
    for (var p in playersInGame) {
      p.resetPoints();
    }
  }

  void _switchPlayer() {
    currentPlayerIdx = (currentPlayerIdx + 1) % playersInGame.length;
    startCurrentTurn();
  }

  void startCurrentTurn() {
    CheckoutProcess.clearCache();
    updateCheckoutHint();

    if (player is BotPlayer) {
      _executeBotTurn(player as BotPlayer);
    }
  }

  void _endGame(Player matchWinner) {
    isGameOver = true;
    winner = matchWinner;
  }

  /// Resetowanie całego meczu do stanu początkowego
  void restartMatch() {
    isGameOver = false;
    winner = null;
    playerStartingSet = 0;
    currentPlayerIdx = 0;
    startingLegPlayerIdx = 0;
    dartsThrownThisTurn = 0;
    dartsAtDoubleThisTurn = 0;
    currentTurnScores.clear();
    currentTurnLabels.clear();
    matchScores.clear();
    currentCheckoutHint = " ";
    isBotThrowing = false;

    for (var p in playersInGame) {
      p.resetFull();
    }

    notifyListeners();
    startCurrentTurn();
  }

  /// Wyliczanie podpowiedzi checkoutu
  void updateCheckoutHint() async {
    if (player.points > 170 || dartsThrownThisTurn == 3 || player.points < 2) {
      currentCheckoutHint = " ";
      notifyListeners();
      return;
    }

    var request = CheckoutRequest(
      pointsLeft: player.points,
      dartsLeft: 3 - dartsThrownThisTurn,
      targetWeights: player.targetWeights,
    );

    var hints = await CheckoutProcess.getCheckout(request);

    if (hints != null && hints.isNotEmpty) {
      currentCheckoutHint = hints[0].join(' -> ');
    } else {
      currentCheckoutHint = " ";
    }
    notifyListeners();
  }
}
