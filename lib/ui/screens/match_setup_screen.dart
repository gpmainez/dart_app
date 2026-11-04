import 'package:flutter/material.dart';
import '../../engine/match_manager.dart';
import '../../engine/models/player.dart';
import 'match_screen.dart';

/// Ekran konfiguracji meczu (Gracz vs Bot, Gracz vs Gracz, wybór punktów i formatu).
class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  int _startingPoints = 501;
  final int _legsToWin = 2;
  final int _setsToWin = 1;
  bool _playAgainstBot = true;
  BotDifficulty _botDifficulty = BotDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Match Setup'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nowy Mecz',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Wybór punktów początkowych
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 301, label: Text('301')),
                ButtonSegment(value: 501, label: Text('501')),
              ],
              selected: {_startingPoints},
              onSelectionChanged: (set) => setState(() => _startingPoints = set.first),
            ),
            const SizedBox(height: 16),
            // Wybór trybu gry
            SwitchListTile(
              title: const Text('Graj przeciwko Botowi'),
              subtitle: Text(
                _playAgainstBot
                    ? 'Komputer z silnikiem Gaussa'
                    : 'Lokalny mecz 2 graczy',
              ),
              value: _playAgainstBot,
              onChanged: (val) => setState(() => _playAgainstBot = val),
            ),
            if (_playAgainstBot) ...[
              const SizedBox(height: 8),
              const Text('Poziom trudności bota:'),
              const SizedBox(height: 8),
              SegmentedButton<BotDifficulty>(
                segments: const [
                  ButtonSegment(value: BotDifficulty.easy, label: Text('Łatwy')),
                  ButtonSegment(value: BotDifficulty.medium, label: Text('Średni')),
                  ButtonSegment(value: BotDifficulty.hard, label: Text('Phil Taylor')),
                ],
                selected: {_botDifficulty},
                onSelectionChanged: (set) => setState(() => _botDifficulty = set.first),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                final player1 = HumanPlayer(1, 'Gracz 1', _startingPoints);
                final Player player2 = _playAgainstBot
                    ? BotFactory.createBot(_botDifficulty, _startingPoints, id: 2)
                    : HumanPlayer(2, 'Gracz 2', _startingPoints);

                final match = MatchManager([player1, player2], _legsToWin, _setsToWin);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MatchScreen(match: match)),
                );
              },
              child: const Text(
                'ROZPOCZNIJ MECZ',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
