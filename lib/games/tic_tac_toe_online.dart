import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_session.dart';
import '../models/player.dart';
import '../services/auth_service.dart';
import '../services/matchmaking_service.dart';

class TicTacToeOnline extends StatefulWidget {
  final GameSession session;

  const TicTacToeOnline({super.key, required this.session});

  @override
  State<TicTacToeOnline> createState() => _TicTacToeOnlineState();
}

class _TicTacToeOnlineState extends State<TicTacToeOnline> {
  final AuthService _authService = AuthService();
  final MatchmakingService _matchmaking = MatchmakingService();

  late GameSession _session;
  StreamSubscription? _sessionSubscription;

  List<String> get board => List<String>.from(_session.gameState['board'] ?? List.filled(9, ''));
  bool get isMyTurn => _session.currentTurnId == _authService.oderId;
  bool get isPlayer1 => _session.player1.oderId == _authService.oderId;
  String get mySymbol => isPlayer1 ? 'X' : 'O';
  String get opponentSymbol => isPlayer1 ? 'O' : 'X';

  Player get me => isPlayer1 ? _session.player1 : _session.player2!;
  Player get opponent => isPlayer1 ? _session.player2! : _session.player1;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _listenToSession();
  }

  void _listenToSession() {
    _sessionSubscription = _matchmaking
        .listenToSession(_session.sessionId)
        .listen((session) {
      if (session != null && mounted) {
        setState(() => _session = session);
      }
    });
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleTap(int index) async {
    if (!isMyTurn || _session.isFinished || board[index].isNotEmpty) return;

    final newBoard = List<String>.from(board);
    newBoard[index] = mySymbol;

    // Check for winner
    String? winnerId;
    GameStatus status = GameStatus.playing;
    final winner = _checkWinner(newBoard);

    if (winner != null) {
      winnerId = winner == mySymbol ? _authService.oderId : opponent.oderId;
      status = GameStatus.finished;
    } else if (!newBoard.contains('')) {
      // Draw
      status = GameStatus.finished;
    }

    // Update game state
    await _matchmaking.updateGameState(
      _session.sessionId,
      {'board': newBoard},
      nextTurnId: opponent.oderId,
      status: status,
      winnerId: winnerId,
    );
  }

  String? _checkWinner(List<String> board) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6], // diagonals
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]].isNotEmpty &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return board[pattern[0]];
      }
    }
    return null;
  }

  List<int> _getWinningLine() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]].isNotEmpty &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return pattern;
      }
    }
    return [];
  }

  void _exitGame() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final winningLine = _getWinningLine();
    final isDraw = _session.isFinished && _session.winnerId == null;
    final iWon = _session.winnerId == _authService.oderId;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitGame,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Player indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PlayerCard(
                          name: me.username,
                          symbol: mySymbol,
                          isMyTurn: isMyTurn && !_session.isFinished,
                          isMe: true,
                        ),
                        const Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white38,
                          ),
                        ),
                        _PlayerCard(
                          name: opponent.username,
                          symbol: opponentSymbol,
                          isMyTurn: !isMyTurn && !_session.isFinished,
                          isMe: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Turn indicator
                    if (!_session.isFinished)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMyTurn
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isMyTurn ? 'Your turn!' : "Opponent's turn...",
                          style: TextStyle(
                            fontSize: 16,
                            color: isMyTurn ? Colors.greenAccent : Colors.orangeAccent,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Game board
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
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
                              canTap: isMyTurn && board[index].isEmpty && !_session.isFinished,
                              onTap: () => _handleTap(index),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Result
                    if (_session.isFinished) ...[
                      Text(
                        isDraw
                            ? "It's a Draw!"
                            : iWon
                                ? 'You Win!'
                                : 'You Lose!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDraw
                              ? Colors.white
                              : iWon
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _exitGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                        ),
                        icon: const Icon(Icons.home),
                        label: const Text('Back to Menu'),
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

class _PlayerCard extends StatelessWidget {
  final String name;
  final String symbol;
  final bool isMyTurn;
  final bool isMe;

  const _PlayerCard({
    required this.name,
    required this.symbol,
    required this.isMyTurn,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final color = symbol == 'X' ? Colors.purpleAccent : Colors.cyanAccent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMyTurn ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMyTurn ? color : Colors.grey.shade800,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            symbol,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isMe ? '$name (You)' : name,
            style: TextStyle(
              fontSize: 12,
              color: isMyTurn ? Colors.white : Colors.grey,
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
  final bool canTap;
  final VoidCallback onTap;

  const _GameCell({
    required this.value,
    required this.isWinning,
    required this.canTap,
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
      onTap: canTap ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(12),
          border: canTap
              ? Border.all(color: Colors.white24, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
