import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class WordBlitzGame extends StatefulWidget {
  const WordBlitzGame({super.key});

  @override
  State<WordBlitzGame> createState() => _WordBlitzGameState();
}

class _WordBlitzGameState extends State<WordBlitzGame> {
  static const int timeLimit = 30;
  static const int letterCount = 7;

  List<String> letters = [];
  List<bool> usedLetters = [];
  String currentWord = '';

  int currentPlayer = 0; // 0 = not started, 1 = player 1, 2 = player 2
  String player1Word = '';
  int player1Score = 0;
  String player2Word = '';
  int player2Score = 0;

  int timeRemaining = timeLimit;
  Timer? timer;
  bool gameOver = false;

  static const Map<String, int> letterScores = {
    'A': 1, 'B': 3, 'C': 3, 'D': 2, 'E': 1, 'F': 4, 'G': 2, 'H': 4,
    'I': 1, 'J': 8, 'K': 5, 'L': 1, 'M': 3, 'N': 1, 'O': 1, 'P': 3,
    'Q': 10, 'R': 1, 'S': 1, 'T': 1, 'U': 1, 'V': 4, 'W': 4, 'X': 8,
    'Y': 4, 'Z': 10,
  };

  // Weighted letter distribution (more vowels and common consonants)
  static const String letterPool =
    'AAAAAAAAABBCCDDDDEEEEEEEEEEEEEFFGGGHHIIIIIIIIIJKLLLLMM'
    'NNNNNNOOOOOOOOOPPQRRRRRRSSSSTTTTTTTUUUUVVWWXYYZ';

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _generateLetters() {
    final random = Random();
    letters = [];

    // Ensure at least 2 vowels
    const vowels = 'AEIOU';
    int vowelCount = 0;

    while (letters.length < letterCount) {
      String letter = letterPool[random.nextInt(letterPool.length)];

      // If we need more vowels and this isn't one, try again
      if (letters.length >= letterCount - 2 && vowelCount < 2 && !vowels.contains(letter)) {
        letter = vowels[random.nextInt(vowels.length)];
      }

      letters.add(letter);
      if (vowels.contains(letter)) vowelCount++;
    }

    letters.shuffle();
    usedLetters = List.filled(letterCount, false);
  }

  void _startGame() {
    _generateLetters();
    setState(() {
      currentPlayer = 1;
      currentWord = '';
      timeRemaining = timeLimit;
    });
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        timeRemaining--;
        if (timeRemaining <= 0) {
          _submitWord();
        }
      });
    });
  }

  void _toggleLetter(int index) {
    if (timer == null || gameOver) return;

    setState(() {
      if (usedLetters[index]) {
        // Remove this letter and all letters after it in the word
        int letterPos = currentWord.indexOf(letters[index]);
        if (letterPos != -1) {
          // Find which letters to un-use
          String removed = currentWord.substring(letterPos);
          currentWord = currentWord.substring(0, letterPos);

          // Reset used status for removed letters
          for (int i = 0; i < letters.length; i++) {
            if (usedLetters[i] && removed.contains(letters[i])) {
              // Only reset if this instance was used
              int countInRemoved = removed.split(letters[i]).length - 1;
              int countInWord = currentWord.split(letters[i]).length - 1;
              int timesUsed = usedLetters.where((u) => u).length;
              if (countInRemoved > 0) {
                usedLetters[i] = false;
                removed = removed.replaceFirst(letters[i], '');
              }
            }
          }
        }
        usedLetters[index] = false;
      } else {
        usedLetters[index] = true;
        currentWord += letters[index];
      }
    });
  }

  int _calculateScore(String word) {
    if (word.length < 2) return 0;
    int score = 0;
    for (var letter in word.split('')) {
      score += letterScores[letter] ?? 0;
    }
    // Bonus for longer words
    if (word.length >= 5) score += 5;
    if (word.length >= 7) score += 10;
    return score;
  }

  void _submitWord() {
    timer?.cancel();

    setState(() {
      if (currentPlayer == 1) {
        player1Word = currentWord;
        player1Score = _calculateScore(currentWord);
        currentPlayer = 2;
        currentWord = '';
        usedLetters = List.filled(letterCount, false);
        timeRemaining = timeLimit;
        _startTimer();
      } else {
        player2Word = currentWord;
        player2Score = _calculateScore(currentWord);
        gameOver = true;
      }
    });
  }

  void _resetGame() {
    timer?.cancel();
    setState(() {
      letters = [];
      usedLetters = [];
      currentWord = '';
      currentPlayer = 0;
      player1Word = '';
      player1Score = 0;
      player2Word = '';
      player2Score = 0;
      timeRemaining = timeLimit;
      gameOver = false;
    });
  }

  String _getWinner() {
    if (player1Score > player2Score) return 'Player 1 Wins!';
    if (player2Score > player1Score) return 'Player 2 Wins!';
    return "It's a Tie!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Word Blitz'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: currentPlayer == 0
                  ? _buildStartScreen()
                  : gameOver
                      ? _buildResultScreen()
                      : _buildGameScreen(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.flash_on, size: 80, color: Colors.amber),
        const SizedBox(height: 20),
        const Text(
          'WORD BLITZ',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Both players get the same 7 letters',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        const Text(
          '30 seconds to make your best word',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        const Text(
          'Highest score wins!',
          style: TextStyle(fontSize: 16, color: Colors.amber),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: const Text(
            'START',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    Color playerColor = currentPlayer == 1 ? Colors.purpleAccent : Colors.cyanAccent;

    return Column(
      children: [
        // Player indicator
        Text(
          'Player $currentPlayer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: playerColor,
          ),
        ),
        if (currentPlayer == 2)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '(Player 1 look away!)',
              style: TextStyle(fontSize: 12, color: Colors.white38),
            ),
          ),
        const SizedBox(height: 20),

        // Timer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: timeRemaining <= 10
                ? Colors.red.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$timeRemaining',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: timeRemaining <= 10 ? Colors.redAccent : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Current word display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                currentWord.isEmpty ? 'TAP LETTERS' : currentWord,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: currentWord.isEmpty ? Colors.white38 : Colors.white,
                  letterSpacing: 4,
                ),
              ),
              if (currentWord.length >= 2)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Score: ${_calculateScore(currentWord)}',
                    style: const TextStyle(fontSize: 16, color: Colors.amber),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Letter tiles
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(letters.length, (index) {
            return GestureDetector(
              onTap: () => _toggleLetter(index),
              child: Container(
                width: 44,
                height: 52,
                decoration: BoxDecoration(
                  color: usedLetters[index]
                      ? Colors.amber.shade700
                      : Colors.deepPurple.shade700,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: usedLetters[index] ? Colors.amber : Colors.deepPurple.shade400,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      letters[index],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: usedLetters[index] ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                      '${letterScores[letters[index]]}',
                      style: TextStyle(
                        fontSize: 10,
                        color: usedLetters[index] ? Colors.black54 : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 30),

        // Submit button
        ElevatedButton(
          onPressed: currentWord.length >= 2 ? _submitWord : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            disabledBackgroundColor: Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: Text(
            currentPlayer == 1 ? 'SUBMIT - Next Player' : 'SUBMIT - See Results',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    String winner = _getWinner();
    Color winnerColor = player1Score > player2Score
        ? Colors.purpleAccent
        : player2Score > player1Score
            ? Colors.cyanAccent
            : Colors.amber;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          winner,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: winnerColor,
          ),
        ),
        const SizedBox(height: 30),

        // Letters used
        const Text(
          'Letters:',
          style: TextStyle(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 8),
        Text(
          letters.join(' '),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 30),

        // Player 1 result
        _PlayerResult(
          player: 1,
          word: player1Word,
          score: player1Score,
          isWinner: player1Score > player2Score,
        ),
        const SizedBox(height: 16),

        // Player 2 result
        _PlayerResult(
          player: 2,
          word: player2Word,
          score: player2Score,
          isWinner: player2Score > player1Score,
        ),
        const SizedBox(height: 30),

        ElevatedButton.icon(
          onPressed: _resetGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text('Play Again'),
        ),
      ],
    );
  }
}

class _PlayerResult extends StatelessWidget {
  final int player;
  final String word;
  final int score;
  final bool isWinner;

  const _PlayerResult({
    required this.player,
    required this.word,
    required this.score,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    Color playerColor = player == 1 ? Colors.purpleAccent : Colors.cyanAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWinner ? playerColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? playerColor : Colors.grey.shade800,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: playerColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Text(
              'P$player',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: playerColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.isEmpty ? '(no word)' : word,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: word.isEmpty ? Colors.white38 : Colors.white,
                  ),
                ),
                Text(
                  '${word.length} letters',
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.amber : Colors.white70,
                ),
              ),
              const Text(
                'pts',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
