import 'package:flutter/material.dart';

/// Panel klawiatury numerycznej do wprowadzania rzutów lotką.
class DartPad extends StatefulWidget {
  final List<String> currentTurnLabels;
  final bool isEnabled;
  final Function(int score, String label, bool isDouble) onDartThrown;
  final VoidCallback onUndo;

  const DartPad({
    super.key,
    required this.currentTurnLabels,
    this.isEnabled = true,
    required this.onDartThrown,
    required this.onUndo,
  });

  @override
  State<DartPad> createState() => _DartPadState();
}

class _DartPadState extends State<DartPad> {
  int _scoreMultiplier = 1;

  void _handleKeyPress(String value) {
    if (!widget.isEnabled) return;

    // Obsługa odklikiwania (toggle) dla Double i Triple
    if (value == 'D') {
      setState(() => _scoreMultiplier = _scoreMultiplier == 2 ? 1 : 2);
      return;
    } else if (value == 'T') {
      setState(() => _scoreMultiplier = _scoreMultiplier == 3 ? 1 : 3);
      return;
    }

    if (value == 'DEL') {
      widget.onUndo();
      setState(() => _scoreMultiplier = 1);
      return;
    }

    int sectorScore = int.parse(value);

    // Zabezpieczenie: w darcie nie ma Triple Bullseye ani Triple Outer Bull
    if (_scoreMultiplier == 3 && (sectorScore == 25 || sectorScore == 50)) {
      return;
    }

    // 25 podwójne to Bullseye (50)
    if (_scoreMultiplier == 2 && sectorScore == 25) {
      sectorScore = 50;
      _scoreMultiplier = 1;
    }

    int score = _scoreMultiplier * sectorScore;

    String label = sectorScore.toString();
    if (_scoreMultiplier == 2) label = 'D$sectorScore';
    if (_scoreMultiplier == 3) label = 'T$sectorScore';
    if (sectorScore == 50) label = 'Bullseye';
    if (sectorScore == 25) label = 'Outer Bull';

    bool isDouble = (_scoreMultiplier == 2) || (sectorScore == 50);

    widget.onDartThrown(score, label, isDouble);

    setState(() => _scoreMultiplier = 1);
  }

  @override
  Widget build(BuildContext context) {
    final isTripleSelected = _scoreMultiplier == 3;

    return AbsorbPointer(
      absorbing: !widget.isEnabled,
      child: Opacity(
        opacity: widget.isEnabled ? 1.0 : 0.6,
        child: Column(
          children: [
            Container(
              height: 55,
              margin: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildDartBox(0), _buildDartBox(1), _buildDartBox(2)],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildButton('1'),
                  _buildButton('2'),
                  _buildButton('3'),
                  _buildButton('4'),
                  _buildButton('5'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildButton('6'),
                  _buildButton('7'),
                  _buildButton('8'),
                  _buildButton('9'),
                  _buildButton('10'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildButton('11'),
                  _buildButton('12'),
                  _buildButton('13'),
                  _buildButton('14'),
                  _buildButton('15'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildButton('16'),
                  _buildButton('17'),
                  _buildButton('18'),
                  _buildButton('19'),
                  _buildButton('20'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Wygaszanie 25 i 50 gdy wybrano modyfikator Triple
                  _buildButton('25', isButtonEnabled: !isTripleSelected),
                  _buildButton('50', isButtonEnabled: !isTripleSelected),
                  _buildButton('D', isSelected: _scoreMultiplier == 2),
                  _buildButton('T', isSelected: _scoreMultiplier == 3),
                  _buildButton('DEL'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDartBox(int index) {
    String text = index < widget.currentTurnLabels.length
        ? widget.currentTurnLabels[index]
        : '';
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.black45,
          border: Border.all(color: Colors.grey[600]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    bool isSelected = false,
    bool isButtonEnabled = true,
  }) {
    Color? bgColor = Colors.grey[800];
    if (isSelected) {
      bgColor = Colors.green[600];
    } else if (!isButtonEnabled) {
      bgColor = Colors.grey[900];
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: isButtonEnabled ? () => _handleKeyPress(text) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: isButtonEnabled ? Colors.white : Colors.grey[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
