import 'package:flutter/material.dart';

class ConnectFourGame extends StatefulWidget {
  const ConnectFourGame({super.key});

  @override
  State<ConnectFourGame> createState() => _ConnectFourGameState();
}

class _ConnectFourGameState extends State<ConnectFourGame> {
  static const int rows = 6;
  static const int cols = 7;

  // 0 = empty, 1 = player 1, 2 = player 2
  List<List<int>> board = List.generate(rows, (_) => List.filled(cols, 0));
  bool isPlayer1Turn = true;
  int? winner;
  List<List<int>> winningCells = [];

  void _dropDisc(int col) {
    if (winner != null) return;

    // Find the lowest empty row in this column
    int row = -1;
    for (int r = rows - 1; r >= 0; r--) {
      if (board[r][col] == 0) {
        row = r;
        break;
      }
    }

    // Column is full
    if (row == -1) return;

    setState(() {
      board[row][col] = isPlayer1Turn ? 1 : 2;
      _checkWinner(row, col);
      isPlayer1Turn = !isPlayer1Turn;
    });
  }

  void _checkWinner(int row, int col) {
    int player = board[row][col];

    // Check all directions: horizontal, vertical, diagonal (both)
    List<List<int>> directions = [
      [0, 1],   // horizontal
      [1, 0],   // vertical
      [1, 1],   // diagonal down-right
      [1, -1],  // diagonal down-left
    ];

    for (var dir in directions) {
      List<List<int>> cells = [[row, col]];

      // Check forward direction
      int r = row + dir[0];
      int c = col + dir[1];
      while (r >= 0 && r < rows && c >= 0 && c < cols && board[r][c] == player) {
        cells.add([r, c]);
        r += dir[0];
        c += dir[1];
      }

      // Check backward direction
      r = row - dir[0];
      c = col - dir[1];
      while (r >= 0 && r < rows && c >= 0 && c < cols && board[r][c] == player) {
        cells.add([r, c]);
        r -= dir[0];
        c -= dir[1];
      }

      if (cells.length >= 4) {
        winner = player;
        winningCells = cells;
        return;
      }
    }

    // Check for draw
    bool isDraw = true;
    for (int c = 0; c < cols; c++) {
      if (board[0][c] == 0) {
        isDraw = false;
        break;
      }
    }
    if (isDraw) {
      winner = 0; // 0 indicates draw
    }
  }

  void _resetGame() {
    setState(() {
      board = List.generate(rows, (_) => List.filled(cols, 0));
      isPlayer1Turn = true;
      winner = null;
      winningCells = [];
    });
  }

  bool _isWinningCell(int row, int col) {
    for (var cell in winningCells) {
      if (cell[0] == row && cell[1] == col) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardWidth = (screenWidth - 40).clamp(0.0, 380.0);
    final cellSize = boardWidth / cols;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Connect 4'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Player indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PlayerIndicator(
                          label: 'Player 1',
                          color: Colors.purpleAccent,
                          isActive: isPlayer1Turn && winner == null,
                        ),
                        _PlayerIndicator(
                          label: 'Player 2',
                          color: Colors.cyanAccent,
                          isActive: !isPlayer1Turn && winner == null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Game board
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: List.generate(rows, (row) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(cols, (col) {
                              return GestureDetector(
                                onTap: () => _dropDisc(col),
                                child: _Cell(
                                  size: cellSize - 4,
                                  value: board[row][col],
                                  isWinning: _isWinningCell(row, col),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Result / Status
                    if (winner != null) ...[
                      Text(
                        winner == 0
                            ? "It's a Draw!"
                            : 'Player $winner Wins!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: winner == 1
                              ? Colors.purpleAccent
                              : winner == 2
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

class _PlayerIndicator extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;

  const _PlayerIndicator({
    required this.label,
    required this.color,
    required this.isActive,
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
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final double size;
  final int value;
  final bool isWinning;

  const _Cell({
    required this.size,
    required this.value,
    required this.isWinning,
  });

  @override
  Widget build(BuildContext context) {
    Color discColor;
    if (value == 1) {
      discColor = Colors.purpleAccent;
    } else if (value == 2) {
      discColor = Colors.cyanAccent;
    } else {
      discColor = Colors.blue.shade800;
    }

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size - 8,
          height: size - 8,
          decoration: BoxDecoration(
            color: discColor,
            shape: BoxShape.circle,
            boxShadow: isWinning && value != 0
                ? [
                    BoxShadow(
                      color: discColor.withOpacity(0.8),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
            border: isWinning && value != 0
                ? Border.all(color: Colors.white, width: 3)
                : null,
          ),
        ),
      ),
    );
  }
}
