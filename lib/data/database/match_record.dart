/// Model rekordu podsumowania meczu przechowywanego w relacyjnej bazie SQLite.
class MatchRecord {
  final int? id;
  final String winnerName;
  final String player1Name;
  final String player2Name;
  final double player1Average;
  final double player2Average;
  final double winnerCheckoutPercentage;
  final int total180s;
  final String playedAt;

  const MatchRecord({
    this.id,
    required this.winnerName,
    required this.player1Name,
    required this.player2Name,
    required this.player1Average,
    required this.player2Average,
    required this.winnerCheckoutPercentage,
    required this.total180s,
    required this.playedAt,
  });

  /// Mapowanie obiektu na rekord bazodanowy (kolumny w SQLite).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'winner_name': winnerName,
      'player1_name': player1Name,
      'player2_name': player2Name,
      'player1_avg': player1Average,
      'player2_avg': player2Average,
      'winner_checkout_pct': winnerCheckoutPercentage,
      'total_180s': total180s,
      'played_at': playedAt,
    };
  }

  /// Odtwarzanie obiektu modelu z wiersza zwróconego przez zapytanie SQL.
  factory MatchRecord.fromMap(Map<String, dynamic> map) {
    return MatchRecord(
      id: map['id'] as int?,
      winnerName: map['winner_name'] as String,
      player1Name: map['player1_name'] as String,
      player2Name: map['player2_name'] as String,
      player1Average: (map['player1_avg'] as num).toDouble(),
      player2Average: (map['player2_avg'] as num).toDouble(),
      winnerCheckoutPercentage: (map['winner_checkout_pct'] as num).toDouble(),
      total180s: map['total_180s'] as int,
      playedAt: map['played_at'] as String,
    );
  }
}
