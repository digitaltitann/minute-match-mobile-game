import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_session.dart';
import '../models/player.dart';
import '../services/auth_service.dart';
import '../services/matchmaking_service.dart';
import '../games/tic_tac_toe_online.dart';

class LobbyScreen extends StatefulWidget {
  final GameType gameType;
  final String gameTitle;

  const LobbyScreen({
    super.key,
    required this.gameType,
    required this.gameTitle,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final AuthService _authService = AuthService();
  final MatchmakingService _matchmaking = MatchmakingService();

  bool _isSearching = false;
  bool _isCreatingRoom = false;
  bool _isJoiningRoom = false;
  String? _roomCode;
  String? _error;

  StreamSubscription? _matchSubscription;
  final TextEditingController _roomCodeController = TextEditingController();

  Player get _player => _authService.currentPlayer!;

  @override
  void dispose() {
    _matchSubscription?.cancel();
    _roomCodeController.dispose();
    if (_isSearching) {
      _matchmaking.leaveQueue(_player.oderId, widget.gameType);
    }
    if (_roomCode != null && _isCreatingRoom) {
      _matchmaking.deleteRoom(_roomCode!);
    }
    super.dispose();
  }

  Future<void> _startQuickMatch() async {
    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final stream = await _matchmaking.joinQueue(_player, widget.gameType);

      _matchSubscription = stream.listen((session) {
        if (session != null && mounted) {
          _navigateToGame(session);
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _error = 'Failed to join queue: $e';
      });
    }
  }

  Future<void> _cancelSearch() async {
    await _matchSubscription?.cancel();
    await _matchmaking.leaveQueue(_player.oderId, widget.gameType);
    setState(() => _isSearching = false);
  }

  Future<void> _createRoom() async {
    setState(() {
      _isCreatingRoom = true;
      _error = null;
    });

    try {
      final code = await _matchmaking.createRoom(_player, widget.gameType);

      setState(() => _roomCode = code);

      // Listen for guest joining
      _matchSubscription = _matchmaking.listenToRoom(code).listen((session) {
        if (session != null && mounted) {
          _navigateToGame(session);
        }
      });
    } catch (e) {
      setState(() {
        _isCreatingRoom = false;
        _error = 'Failed to create room: $e';
      });
    }
  }

  Future<void> _cancelRoom() async {
    if (_roomCode != null) {
      await _matchmaking.deleteRoom(_roomCode!);
    }
    await _matchSubscription?.cancel();
    setState(() {
      _isCreatingRoom = false;
      _roomCode = null;
    });
  }

  Future<void> _joinRoom() async {
    final code = _roomCodeController.text.trim();

    if (code.length != 4) {
      setState(() => _error = 'Please enter a 4-digit code');
      return;
    }

    setState(() {
      _isJoiningRoom = true;
      _error = null;
    });

    try {
      final session = await _matchmaking.joinRoom(code, _player);

      if (session != null && mounted) {
        _navigateToGame(session);
      }
    } catch (e) {
      setState(() {
        _isJoiningRoom = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _navigateToGame(GameSession session) {
    _matchSubscription?.cancel();

    // Navigate to the appropriate game screen
    Widget gameScreen;

    switch (widget.gameType) {
      case GameType.ticTacToe:
        gameScreen = TicTacToeOnline(session: session);
        break;
      default:
        // For now, only Tic Tac Toe is implemented
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This game is not yet available online')),
        );
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => gameScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.gameTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Player info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.purpleAccent,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _player.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Quick Match
              if (!_isCreatingRoom && _roomCode == null)
                _buildQuickMatchSection(),

              const SizedBox(height: 24),

              // Room section
              if (!_isSearching) _buildRoomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMatchSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade800, Colors.purple.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.flash_on, size: 40, color: Colors.amber),
          const SizedBox(height: 12),
          const Text(
            'Quick Match',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Play against a random opponent',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          if (_isSearching) ...[
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 12),
            const Text(
              'Searching for opponent...',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _cancelSearch,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ] else
            ElevatedButton(
              onPressed: _startQuickMatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'FIND MATCH',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.people, size: 40, color: Colors.cyanAccent),
          const SizedBox(height: 12),
          const Text(
            'Play with Friend',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          if (_isCreatingRoom && _roomCode != null) ...[
            const Text(
              'Share this code with your friend:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent, width: 2),
              ),
              child: Text(
                _roomCode!,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                  letterSpacing: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Waiting for friend to join...',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const CircularProgressIndicator(color: Colors.cyanAccent),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _cancelRoom,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ] else ...[
            // Create Room button
            ElevatedButton.icon(
              onPressed: _createRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'CREATE ROOM',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // OR divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade700)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 20),

            // Join Room
            const Text(
              'Enter room code:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 160,
              child: TextField(
                controller: _roomCodeController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '0000',
                  hintStyle: TextStyle(color: Colors.grey.shade700),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isJoiningRoom ? null : _joinRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: _isJoiningRoom
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('JOIN'),
            ),
          ],
        ],
      ),
    );
  }
}
