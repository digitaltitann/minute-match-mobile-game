import 'package:flutter/material.dart';

class ConnectFourGame extends StatefulWidget {
  const ConnectFourGame({super.key});

  @override
  State<ConnectFourGame> createState() => _ConnectFourGameState();
}

class _ConnectFourGameState extends State<ConnectFourGame> {
  static const int rows = 6;
  static const int cols = 7;

  List<List<int>> board = List.generate(rows, (_) => List.filled(cols, 0));
  bool isPlayer1Turn = true;
  int? winner;
  List<List<int>> winningCells = [];

  void _dropDisc(int col) {
    if (winner != null) return;

    int row = -1;
    for (int r = rows - 1; r >= 0; r--) {
      if (board[r][col] == 0) {
        row = r;
        break;
      }
    }

    if (row == -1) return;

    setState(() {
      board[row][col] = isPlayer1Turn ? 1 : 2;
      _checkWinner(row, col);
      isPlayer1Turn = !isPlayer1Turn;
    });
  }

  void _checkWinner(int row, int col) {
    int player = board[row][col];

    List<List<int>> directions = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];

    for (var dir in directions) {
      List<List<int>> cells = [[row, col]];

      int r = row + dir[0];
      int c = col + dir[1];
      while (r >= 0 && r < rows && c >= 0 && c < cols && board[r][c] == player) {
        cells.add([r, c]);
        r += dir[0];
        c += dir[1];
      }

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

    bool isDraw = true;
    for (int c = 0; c < cols; c++) {
      if (board[0][c] == 0) {
        isDraw = false;
        break;
      }
    }
    if (isDraw) {
      winner = 0;
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
    final maxBoardWidth = (screenWidth - 60).clamp(200.0, 320.0);
    final cellSize = maxBoardWidth / cols;

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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PlayerIndicator(
                        label: 'P1',
                        color: Colors.purpleAccent,
                        isActive: isPlayer1Turn && winner == null,
                      ),
                      const SizedBox(width: 20),
                      _PlayerIndicator(
                        label: 'P2',
                        color: Colors.cyanAccent,
                        isActive: !isPlayer1Turn && winner == null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(rows, (row) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(cols, (col) {
                            return GestureDetector(
                              onTap: () => _dropDisc(col),
                              child: _Cell(
                                size: cellSize - 2,
                                value: board[row][col],
                                isWinning: _isWinningCell(row, col),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (winner != null) ...[
                    Text(
                      winner == 0 ? "It's a Draw!" : 'Player $winner Wins!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: winner == 1
                            ? Colors.purpleAccent
                            : winner == 2
                                ? Colors.cyanAccent
                                : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _resetGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Play Again'),
                    ),
                  ],
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
  final Color color;
  final bool isActive;

  const _PlayerIndicator({
    required this.label,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? color : Colors.grey.shade800,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
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
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size - 6,
          height: size - 6,
          decoration: BoxDecoration(
            color: discColor,
            shape: BoxShape.circle,
            border: isWinning && value != 0
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
        ),
      ),
    );
  }
}
