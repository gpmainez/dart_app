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
  int _legsToWin = 2;
  int _setsToWin = 1;
  bool _playAgainstBot = true;
  BotDifficulty _botDifficulty = BotDifficulty.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Match Setup'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
            const Text('Punkty początkowe:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            // Wybór punktów początkowych
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 301, label: Text('301')),
                ButtonSegment(value: 501, label: Text('501')),
              ],
              selected: {_startingPoints},
              onSelectionChanged: (set) => setState(() => _startingPoints = set.first),
            ),
            const SizedBox(height: 20),
            // Format meczu: Legi do wygrania seta
            const Text('Legi do wygrania seta (First to):', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 5, label: Text('5')),
              ],
              selected: {_legsToWin},
              onSelectionChanged: (set) => setState(() => _legsToWin = set.first),
            ),
            const SizedBox(height: 20),
            // Format meczu: Sety do wygrania meczu
            const Text('Sety do wygrania meczu (First to):', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
              ],
              selected: {_setsToWin},
              onSelectionChanged: (set) => setState(() => _setsToWin = set.first),
            ),
            const SizedBox(height: 20),
            // Wybór trybu gry
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
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
              const Text('Poziom trudności bota:', style: TextStyle(color: Colors.grey)),
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
            const SizedBox(height: 36),
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
