import 'package:flutter/material.dart';

class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});

  @override
  State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  String secretWord = '';
  Set<String> guessedLetters = {};
  int wrongGuesses = 0;
  static const int maxWrongGuesses = 6;
  bool isSettingWord = true;
  final TextEditingController _wordController = TextEditingController();

  List<String> get wordLetters => secretWord.toUpperCase().split('');

  bool get hasWon {
    if (secretWord.isEmpty) return false;
    return wordLetters.every(
      (letter) => !letter.contains(RegExp(r'[A-Z]')) || guessedLetters.contains(letter),
    );
  }

  bool get hasLost => wrongGuesses >= maxWrongGuesses;

  void _setWord() {
    final word = _wordController.text.trim();
    if (word.isEmpty || word.length < 2) return;

    setState(() {
      secretWord = word.toUpperCase();
      isSettingWord = false;
      _wordController.clear();
    });
  }

  void _guessLetter(String letter) {
    if (guessedLetters.contains(letter) || hasWon || hasLost) return;

    setState(() {
      guessedLetters.add(letter);
      if (!wordLetters.contains(letter)) {
        wrongGuesses++;
      }
    });
  }

  void _resetGame() {
    setState(() {
      secretWord = '';
      guessedLetters = {};
      wrongGuesses = 0;
      isSettingWord = true;
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Hangman'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isSettingWord ? _buildWordInput() : _buildGamePlay(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordInput() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Player 1',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purpleAccent,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter a secret word',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        const Text(
          '(Player 2 look away!)',
          style: TextStyle(fontSize: 14, color: Colors.white38),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 280,
          child: TextField(
            controller: _wordController,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Type word here...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.deepPurple.shade900,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
              ),
            ),
            onSubmitted: (_) => _setWord(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _setWord,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: const Text('Start Game', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildGamePlay() {
    return Column(
      children: [
        // Hangman drawing
        _HangmanDrawing(wrongGuesses: wrongGuesses),
        const SizedBox(height: 20),

        // Wrong guesses counter
        Text(
          'Wrong: $wrongGuesses / $maxWrongGuesses',
          style: TextStyle(
            fontSize: 16,
            color: wrongGuesses > 3 ? Colors.redAccent : Colors.white70,
          ),
        ),
        const SizedBox(height: 20),

        // Word display
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: wordLetters.map((letter) {
            final isLetter = letter.contains(RegExp(r'[A-Z]'));
            final isGuessed = guessedLetters.contains(letter);
            final showLetter = !isLetter || isGuessed || hasLost;

            return Container(
              width: 36,
              height: 44,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isLetter ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  showLetter ? letter : '',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: hasLost && !isGuessed ? Colors.redAccent : Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),

        // Win/Lose message
        if (hasWon || hasLost) ...[
          Text(
            hasWon ? 'Player 2 Wins!' : 'Player 1 Wins!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: hasWon ? Colors.cyanAccent : Colors.purpleAccent,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Play Again'),
          ),
        ] else ...[
          // Letter keyboard
          const Text(
            'Player 2 - Guess a letter',
            style: TextStyle(fontSize: 16, color: Colors.cyanAccent),
          ),
          const SizedBox(height: 16),
          _LetterKeyboard(
            guessedLetters: guessedLetters,
            correctLetters: wordLetters.toSet(),
            onLetterTap: _guessLetter,
          ),
        ],
      ],
    );
  }
}

class _HangmanDrawing extends StatelessWidget {
  final int wrongGuesses;

  const _HangmanDrawing({required this.wrongGuesses});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: CustomPaint(
        painter: _HangmanPainter(wrongGuesses),
      ),
    );
  }
}

class _HangmanPainter extends CustomPainter {
  final int wrongGuesses;

  _HangmanPainter(this.wrongGuesses);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final headPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Gallows (always shown)
    // Base
    canvas.drawLine(
      Offset(20, size.height - 10),
      Offset(size.width - 20, size.height - 10),
      paint,
    );
    // Pole
    canvas.drawLine(
      const Offset(50, 10),
      Offset(50, size.height - 10),
      paint,
    );
    // Top
    canvas.drawLine(
      const Offset(50, 10),
      const Offset(110, 10),
      paint,
    );
    // Rope
    canvas.drawLine(
      const Offset(110, 10),
      const Offset(110, 30),
      paint,
    );

    // Head
    if (wrongGuesses >= 1) {
      canvas.drawCircle(const Offset(110, 45), 15, headPaint);
    }

    // Body
    if (wrongGuesses >= 2) {
      canvas.drawLine(
        const Offset(110, 60),
        const Offset(110, 95),
        paint,
      );
    }

    // Left arm
    if (wrongGuesses >= 3) {
      canvas.drawLine(
        const Offset(110, 70),
        const Offset(85, 85),
        paint,
      );
    }

    // Right arm
    if (wrongGuesses >= 4) {
      canvas.drawLine(
        const Offset(110, 70),
        const Offset(135, 85),
        paint,
      );
    }

    // Left leg
    if (wrongGuesses >= 5) {
      canvas.drawLine(
        const Offset(110, 95),
        const Offset(90, 125),
        paint,
      );
    }

    // Right leg
    if (wrongGuesses >= 6) {
      canvas.drawLine(
        const Offset(110, 95),
        const Offset(130, 125),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HangmanPainter oldDelegate) {
    return oldDelegate.wrongGuesses != wrongGuesses;
  }
}

class _LetterKeyboard extends StatelessWidget {
  final Set<String> guessedLetters;
  final Set<String> correctLetters;
  final Function(String) onLetterTap;

  const _LetterKeyboard({
    required this.guessedLetters,
    required this.correctLetters,
    required this.onLetterTap,
  });

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((letter) {
              final isGuessed = guessedLetters.contains(letter);
              final isCorrect = correctLetters.contains(letter);

              Color bgColor;
              Color textColor;

              if (isGuessed) {
                bgColor = isCorrect ? Colors.green.shade700 : Colors.red.shade700;
                textColor = Colors.white54;
              } else {
                bgColor = Colors.deepPurple.shade700;
                textColor = Colors.white;
              }

              return GestureDetector(
                onTap: isGuessed ? null : () => onLetterTap(letter),
                child: Container(
                  width: 32,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
