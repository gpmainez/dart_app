import 'package:flutter/material.dart';

/// Kafelek z punktacją i statystykami pojedynczego gracza.
class PlayerScoreCard extends StatelessWidget {
  final String playerName;
  final int points;
  final int legs;
  final int sets;
  final double avg;
  final double doublePercentage;
  final double first9Avg;
  final bool isActive;

  const PlayerScoreCard({
    super.key,
    required this.playerName,
    required this.points,
    required this.legs,
    required this.sets,
    required this.avg,
    required this.doublePercentage,
    required this.first9Avg,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple[600],
        borderRadius: BorderRadius.circular(16),
        border: Border(
          bottom: BorderSide(
            color: isActive ? Colors.white : Colors.transparent,
            width: 6.0,
          ),
          top: BorderSide(
            color: isActive ? Colors.white : Colors.transparent,
            width: 2.0,
          ),
          right: BorderSide(
            color: isActive ? Colors.white : Colors.transparent,
            width: 2.0,
          ),
          left: BorderSide(
            color: isActive ? Colors.white : Colors.transparent,
            width: 2.0,
          ),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 3, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            playerName,
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
          Text(
            '$points',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('LEGS', style: TextStyle(color: Colors.grey)),
                  Text(
                    '$legs',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('SETS', style: TextStyle(color: Colors.grey)),
                  Text(
                    '$sets',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('AVG', avg.toStringAsFixed(1)),
              _buildStatColumn(
                '% D',
                '${doublePercentage.toStringAsFixed(0)}%',
              ),
              _buildStatColumn("9-AVG", first9Avg.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
