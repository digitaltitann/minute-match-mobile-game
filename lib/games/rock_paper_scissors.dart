import 'package:flutter/material.dart';

enum Choice { rock, paper, scissors }

class RockPaperScissorsGame extends StatefulWidget {
  const RockPaperScissorsGame({super.key});

  @override
  State<RockPaperScissorsGame> createState() => _RockPaperScissorsGameState();
}

class _RockPaperScissorsGameState extends State<RockPaperScissorsGame> {
  int player1Score = 0;
  int player2Score = 0;
  int currentRound = 1;

  Choice? player1Choice;
  Choice? player2Choice;

  bool isPlayer1Turn = true;
  bool showResult = false;
  String? roundWinner;
  String? gameWinner;

  void _makeChoice(Choice choice) {
    setState(() {
      if (isPlayer1Turn) {
        player1Choice = choice;
        isPlayer1Turn = false;
      } else {
        player2Choice = choice;
        _determineRoundWinner();
      }
    });
  }

  void _determineRoundWinner() {
    showResult = true;

    if (player1Choice == player2Choice) {
      roundWinner = 'Tie';
    } else if (
      (player1Choice == Choice.rock && player2Choice == Choice.scissors) ||
      (player1Choice == Choice.paper && player2Choice == Choice.rock) ||
      (player1Choice == Choice.scissors && player2Choice == Choice.paper)
    ) {
      roundWinner = 'Player 1';
      player1Score++;
    } else {
      roundWinner = 'Player 2';
      player2Score++;
    }

    // Check for game winner (best of 3 = first to 2)
    if (player1Score >= 2) {
      gameWinner = 'Player 1';
    } else if (player2Score >= 2) {
      gameWinner = 'Player 2';
    }
  }

  void _nextRound() {
    setState(() {
      player1Choice = null;
      player2Choice = null;
      isPlayer1Turn = true;
      showResult = false;
      roundWinner = null;
      currentRound++;
    });
  }

  void _resetGame() {
    setState(() {
      player1Score = 0;
      player2Score = 0;
      currentRound = 1;
      player1Choice = null;
      player2Choice = null;
      isPlayer1Turn = true;
      showResult = false;
      roundWinner = null;
      gameWinner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Rock Paper Scissors'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Score display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ScoreCard(
                          label: 'Player 1',
                          score: player1Score,
                          isActive: isPlayer1Turn && !showResult && gameWinner == null,
                          color: Colors.purpleAccent,
                        ),
                        Column(
                          children: [
                            Text(
                              'Round $currentRound',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const Text(
                              'Best of 3',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                        _ScoreCard(
                          label: 'Player 2',
                          score: player2Score,
                          isActive: !isPlayer1Turn && !showResult && gameWinner == null,
                          color: Colors.cyanAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Game area
                    if (gameWinner != null) ...[
                      // Game over
                      Text(
                        '$gameWinner Wins!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: gameWinner == 'Player 1'
                              ? Colors.purpleAccent
                              : Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$player1Score - $player2Score',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: _resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Play Again',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ] else if (showResult) ...[
                      // Show round result
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ChoiceDisplay(
                            choice: player1Choice!,
                            label: 'Player 1',
                            color: Colors.purpleAccent,
                          ),
                          const Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                          _ChoiceDisplay(
                            choice: player2Choice!,
                            label: 'Player 2',
                            color: Colors.cyanAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        roundWinner == 'Tie' ? "It's a Tie!" : '$roundWinner wins this round!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: roundWinner == 'Player 1'
                              ? Colors.purpleAccent
                              : roundWinner == 'Player 2'
                                  ? Colors.cyanAccent
                                  : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _nextRound,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Next Round',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ] else ...[
                      // Player selection
                      Text(
                        isPlayer1Turn ? "Player 1's Turn" : "Player 2's Turn",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isPlayer1Turn ? Colors.purpleAccent : Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isPlayer1Turn
                            ? 'Choose your weapon (Player 2 look away!)'
                            : 'Choose your weapon (Player 1 look away!)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: Choice.values.map((choice) {
                          return _ChoiceButton(
                            choice: choice,
                            onTap: () => _makeChoice(choice),
                            color: isPlayer1Turn ? Colors.purpleAccent : Colors.cyanAccent,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final bool isActive;
  final Color color;

  const _ScoreCard({
    required this.label,
    required this.score,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : Colors.grey.shade800,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            '$score',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.grey,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final Choice choice;
  final VoidCallback onTap;
  final Color color;

  const _ChoiceButton({
    required this.choice,
    required this.onTap,
    required this.color,
  });

  String get emoji {
    switch (choice) {
      case Choice.rock:
        return '🪨';
      case Choice.paper:
        return '📄';
      case Choice.scissors:
        return '✂️';
    }
  }

  String get label {
    switch (choice) {
      case Choice.rock:
        return 'Rock';
      case Choice.paper:
        return 'Paper';
      case Choice.scissors:
        return 'Scissors';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceDisplay extends StatelessWidget {
  final Choice choice;
  final String label;
  final Color color;

  const _ChoiceDisplay({
    required this.choice,
    required this.label,
    required this.color,
  });

  String get emoji {
    switch (choice) {
      case Choice.rock:
        return '🪨';
      case Choice.paper:
        return '📄';
      case Choice.scissors:
        return '✂️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 50),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
