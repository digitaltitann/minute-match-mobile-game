import 'package:flutter/material.dart';
import '../games/tic_tac_toe.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(height: 60),
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
                const SizedBox(height: 16),
                _GameButton(
                  title: 'Coming Soon...',
                  icon: Icons.lock,
                  onTap: null,
                  enabled: false,
                ),
              ],
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

  const _GameButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: enabled ? Colors.deepPurple : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
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
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: enabled ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
