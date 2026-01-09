import 'package:flutter/material.dart';
import '../games/tic_tac_toe.dart';
import '../games/rock_paper_scissors.dart';
import '../games/connect_four.dart';
import '../games/hangman.dart';
import '../games/word_blitz.dart';
import '../models/game_session.dart';
import '../services/auth_service.dart';
import 'lobby_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final username = authService.currentPlayer?.username ?? 'Player';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Username display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.purpleAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MINUTE',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 8,
                      ),
                    ),
                    const Text(
                      'MATCH',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '1v1 Retro Game Battles',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Online Games Section
                    const Text(
                      'PLAY ONLINE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GameButton(
                      title: 'Tic Tac Toe',
                      icon: Icons.grid_3x3,
                      isOnline: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LobbyScreen(
                              gameType: GameType.ticTacToe,
                              gameTitle: 'Tic Tac Toe',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Local Games Section
                    const Text(
                      'LOCAL MULTIPLAYER',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GameButton(
                      title: 'Tic Tac Toe',
                      icon: Icons.grid_3x3,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TicTacToeGame(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _GameButton(
                      title: 'Rock Paper Scissors',
                      icon: Icons.front_hand,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RockPaperScissorsGame(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _GameButton(
                      title: 'Connect 4',
                      icon: Icons.circle,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConnectFourGame(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _GameButton(
                      title: 'Hangman',
                      icon: Icons.person,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HangmanGame(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _GameButton(
                      title: 'Word Blitz',
                      icon: Icons.flash_on,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WordBlitzGame(),
                          ),
                        );
                      },
                    ),
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

class _GameButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isOnline;

  const _GameButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isOnline ? Colors.cyan.shade800 : Colors.deepPurple;
    final accentColor = isOnline ? Colors.cyanAccent : Colors.purpleAccent;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: enabled ? bgColor : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: enabled ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: enabled ? Colors.white : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isOnline) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
