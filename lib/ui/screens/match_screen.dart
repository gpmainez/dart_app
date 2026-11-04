import 'package:flutter/material.dart';
import '../../engine/match_manager.dart';
import '../widgets/dart_pad.dart';
import '../widgets/player_score_card.dart';

/// Ekran aktywnego meczu darta z wynikami, podpowiedzią checkoutu i tarczą do wprowadzania punktów.
class MatchScreen extends StatefulWidget {
  final MatchManager match;
  const MatchScreen({super.key, required this.match});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late MatchManager match;

  @override
  void initState() {
    super.initState();
    match = widget.match;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      match.startCurrentTurn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: match,
      builder: (context, child) {
        var player1 = match.playersInGame[0];
        var player2 = match.playersInGame[1];

        if (match.isGameOver) {
          var w = match.winner!;
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'WYGRYWA: ${w.name}',
                    style: const TextStyle(fontSize: 32, color: Colors.greenAccent),
                  ),
                  const SizedBox(height: 20),
                  Text('Średnia meczowa: ${w.average.toStringAsFixed(1)}'),
                  Text('Skuteczność na doublach: ${w.checkoutPercentage.toStringAsFixed(0)}%'),
                  const SizedBox(height: 10),
                  Text('Maksy (180s): ${w.count180s}'),
                  Text('Wizyty 140+: ${w.count140s}'),
                  Text('Wizyty 100+: ${w.count100s}'),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      match.restartMatch();
                    },
                    child: const Text('Zagraj ponownie'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Powrót do menu'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mecz'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.grey[900],
                    child: Row(
                      children: [
                        Expanded(
                          child: PlayerScoreCard(
                            playerName: player1.name,
                            points: player1.points,
                            legs: player1.legs,
                            sets: player1.sets,
                            avg: player1.average,
                            doublePercentage: player1.checkoutPercentage,
                            first9Avg: 0.0,
                            isActive: match.currentPlayerIdx == 0,
                          ),
                        ),
                        const VerticalDivider(
                          color: Colors.black54,
                          thickness: 1,
                          width: 1,
                        ),
                        Expanded(
                          child: PlayerScoreCard(
                            playerName: player2.name,
                            points: player2.points,
                            legs: player2.legs,
                            sets: player2.sets,
                            avg: player2.average,
                            doublePercentage: player2.checkoutPercentage,
                            first9Avg: 0.0,
                            isActive: match.currentPlayerIdx == 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  color: Colors.grey[850],
                  alignment: Alignment.center,
                  child: Text(
                    match.currentCheckoutHint,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Colors.grey[900],
                    padding: const EdgeInsets.all(20.0),
                    child: DartPad(
                      currentTurnLabels: match.currentTurnLabels,
                      isEnabled: !match.isBotThrowing,
                      onDartThrown: (score, label, isDouble) {
                        match.throwMade(score, label, isDouble: isDouble);
                      },
                      onUndo: () {
                        match.removeVisitFromHistory();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
