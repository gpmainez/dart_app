import 'package:flutter/material.dart';
import '../../data/database/match_database.dart';
import '../../data/database/match_record.dart';

/// Ekran prezentujący listę zakończonych meczów z bazy SQLite.
class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  late Future<List<MatchRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = MatchDatabase.instance.getAllMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historia Meczów (SQLite)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Wyczyść historię',
            onPressed: () async {
              await MatchDatabase.instance.clearHistory();
              _loadHistory();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<MatchRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final matches = snapshot.data ?? [];

          if (matches.isEmpty) {
            return const Center(
              child: Text(
                'Brak zapisanych meczów w bazie danych.\nZagraj mecz, aby zapisać wynik!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final m = matches[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.deepPurple.shade700, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🏆 Wygrana: ${m.winnerName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                          Text(
                            m.playedAt,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(m.player1Name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('AVG: ${m.player1Average.toStringAsFixed(1)}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const Text('VS', style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
                          Column(
                            children: [
                              Text(m.player2Name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('AVG: ${m.player2Average.toStringAsFixed(1)}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Skuteczność D: ${m.winnerCheckoutPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                          Text(
                            'Maksy 180s: ${m.total180s}',
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
