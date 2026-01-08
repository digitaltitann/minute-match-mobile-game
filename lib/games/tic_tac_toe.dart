import 'package:flutter/material.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> board = List.filled(9, '');
  bool isXTurn = true;
  String? winner;
  List<int> winningLine = [];

  void _handleTap(int index) {
    if (board[index].isNotEmpty || winner != null) return;

    setState(() {
      board[index] = isXTurn ? 'X' : 'O';
      isXTurn = !isXTurn;
      _checkWinner();
    });
  }

  void _checkWinner() {
    const winPatterns = [
      [0, 1, 2], // top row
      [3, 4, 5], // middle row
      [6, 7, 8], // bottom row
      [0, 3, 6], // left column
      [1, 4, 7], // middle column
      [2, 5, 8], // right column
      [0, 4, 8], // diagonal
      [2, 4, 6], // anti-diagonal
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]].isNotEmpty &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        winner = board[pattern[0]];
        winningLine = pattern;
        return;
      }
    }

    // Check for draw
    if (!board.contains('')) {
      winner = 'Draw';
    }
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      isXTurn = true;
      winner = null;
      winningLine = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final boardSize = screenHeight * 0.45;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Player indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PlayerIndicator(
                        label: 'Player X',
                        symbol: 'X',
                        isActive: isXTurn && winner == null,
                        color: Colors.purpleAccent,
                      ),
                      _PlayerIndicator(
                        label: 'Player O',
                        symbol: 'O',
                        isActive: !isXTurn && winner == null,
                        color: Colors.cyanAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Game board
                  Container(
                    width: boardSize,
                    height: boardSize,
                    constraints: const BoxConstraints(
                      maxWidth: 350,
                      maxHeight: 350,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return _GameCell(
                          value: board[index],
                          isWinning: winningLine.contains(index),
                          onTap: () => _handleTap(index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Status / Result
                  if (winner != null)
                    Column(
                      children: [
                        Text(
                          winner == 'Draw' ? "It's a Draw!" : 'Player $winner Wins!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: winner == 'X'
                                ? Colors.purpleAccent
                                : winner == 'O'
                                    ? Colors.cyanAccent
                                    : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                      ],
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerIndicator extends StatelessWidget {
  final String label;
  final String symbol;
  final bool isActive;
  final Color color;

  const _PlayerIndicator({
    required this.label,
    required this.symbol,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            symbol,
            style: TextStyle(
              fontSize: 32,
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

class _GameCell extends StatelessWidget {
  final String value;
  final bool isWinning;
  final VoidCallback onTap;

  const _GameCell({
    required this.value,
    required this.isWinning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color cellColor = Colors.deepPurple.shade800;
    Color textColor = value == 'X' ? Colors.purpleAccent : Colors.cyanAccent;

    if (isWinning) {
      cellColor = textColor.withOpacity(0.3);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isWinning
              ? [
                  BoxShadow(
                    color: textColor.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            scale: value.isNotEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
