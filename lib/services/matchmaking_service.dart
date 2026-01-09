import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';
import '../models/game_session.dart';

class MatchmakingService {
  static final MatchmakingService _instance = MatchmakingService._internal();
  factory MatchmakingService() => _instance;
  MatchmakingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _queueSubscription;
  StreamSubscription? _roomSubscription;

  /// Generate a random 4-digit room code
  String _generateRoomCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  /// Generate a unique session ID
  String _generateSessionId() {
    return _firestore.collection('game_sessions').doc().id;
  }

  // ============ RANDOM MATCHMAKING ============

  /// Join the matchmaking queue for a game type
  Future<Stream<GameSession?>> joinQueue(Player player, GameType gameType) async {
    final queueRef = _firestore
        .collection('matchmaking')
        .doc(gameType.name)
        .collection('queue');

    // Check if there's already someone waiting
    final waiting = await queueRef
        .orderBy('joinedAt')
        .limit(1)
        .get();

    if (waiting.docs.isNotEmpty) {
      // Found a match! Create game session
      final opponent = Player.fromMap(waiting.docs.first.data());

      // Don't match with yourself
      if (opponent.oderId == player.oderId) {
        // Add to queue and wait
        return _addToQueueAndWait(player, gameType, queueRef);
      }

      // Remove opponent from queue
      await waiting.docs.first.reference.delete();

      // Create game session
      final session = await _createGameSession(
        gameType: gameType,
        player1: opponent,
        player2: player,
      );

      // Return a stream with the session
      return _firestore
          .collection('game_sessions')
          .doc(session.sessionId)
          .snapshots()
          .map((doc) => doc.exists ? GameSession.fromMap(doc.data()!) : null);
    } else {
      // No one waiting, add to queue
      return _addToQueueAndWait(player, gameType, queueRef);
    }
  }

  /// Add player to queue and wait for match
  Future<Stream<GameSession?>> _addToQueueAndWait(
    Player player,
    GameType gameType,
    CollectionReference queueRef,
  ) async {
    // Add to queue
    await queueRef.doc(player.oderId).set({
      ...player.toMap(),
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // Listen for being matched (removed from queue + session created)
    final controller = StreamController<GameSession?>();

    _queueSubscription = _firestore
        .collection('game_sessions')
        .where('gameType', isEqualTo: gameType.name)
        .where('status', isEqualTo: GameStatus.playing.name)
        .snapshots()
        .listen((snapshot) {
      for (final doc in snapshot.docs) {
        final session = GameSession.fromMap(doc.data());
        if (session.player1.oderId == player.oderId ||
            session.player2?.oderId == player.oderId) {
          controller.add(session);
          break;
        }
      }
    });

    return controller.stream;
  }

  /// Leave the matchmaking queue
  Future<void> leaveQueue(String oderId, GameType gameType) async {
    await _queueSubscription?.cancel();
    await _firestore
        .collection('matchmaking')
        .doc(gameType.name)
        .collection('queue')
        .doc(oderId)
        .delete();
  }

  // ============ ROOM CODES ============

  /// Create a room with a code
  Future<String> createRoom(Player host, GameType gameType) async {
    String roomCode;
    bool codeExists = true;

    // Generate unique room code
    do {
      roomCode = _generateRoomCode();
      final existing = await _firestore.collection('rooms').doc(roomCode).get();
      codeExists = existing.exists;
    } while (codeExists);

    // Create room
    await _firestore.collection('rooms').doc(roomCode).set({
      'roomCode': roomCode,
      'gameType': gameType.name,
      'host': host.toMap(),
      'guest': null,
      'sessionId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return roomCode;
  }

  /// Listen for guest joining room
  Stream<GameSession?> listenToRoom(String roomCode) {
    return _firestore
        .collection('rooms')
        .doc(roomCode)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return null;

      final data = doc.data()!;
      final sessionId = data['sessionId'];

      if (sessionId != null) {
        final sessionDoc = await _firestore
            .collection('game_sessions')
            .doc(sessionId)
            .get();
        if (sessionDoc.exists) {
          return GameSession.fromMap(sessionDoc.data()!);
        }
      }
      return null;
    });
  }

  /// Join a room by code
  Future<GameSession?> joinRoom(String roomCode, Player guest) async {
    final roomRef = _firestore.collection('rooms').doc(roomCode);
    final roomDoc = await roomRef.get();

    if (!roomDoc.exists) {
      throw Exception('Room not found');
    }

    final data = roomDoc.data()!;

    if (data['guest'] != null) {
      throw Exception('Room is full');
    }

    final host = Player.fromMap(data['host']);
    final gameType = GameType.values.firstWhere(
      (e) => e.name == data['gameType'],
    );

    // Create game session
    final session = await _createGameSession(
      gameType: gameType,
      player1: host,
      player2: guest,
      roomCode: roomCode,
    );

    // Update room with guest and session
    await roomRef.update({
      'guest': guest.toMap(),
      'sessionId': session.sessionId,
    });

    return session;
  }

  /// Delete a room
  Future<void> deleteRoom(String roomCode) async {
    await _roomSubscription?.cancel();
    await _firestore.collection('rooms').doc(roomCode).delete();
  }

  // ============ GAME SESSION ============

  /// Create a new game session
  Future<GameSession> _createGameSession({
    required GameType gameType,
    required Player player1,
    required Player player2,
    String? roomCode,
  }) async {
    final sessionId = _generateSessionId();

    // Randomly decide who goes first
    final random = Random();
    final firstPlayer = random.nextBool() ? player1 : player2;

    final session = GameSession(
      sessionId: sessionId,
      gameType: gameType,
      player1: player1,
      player2: player2,
      currentTurnId: firstPlayer.oderId,
      status: GameStatus.playing,
      roomCode: roomCode,
      gameState: _getInitialGameState(gameType),
    );

    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .set(session.toMap());

    return session;
  }

  /// Get initial game state for a game type
  Map<String, dynamic> _getInitialGameState(GameType gameType) {
    switch (gameType) {
      case GameType.ticTacToe:
        return {
          'board': List.filled(9, ''),
        };
      case GameType.connectFour:
        return {
          'board': List.generate(6, (_) => List.filled(7, 0)),
        };
      case GameType.rockPaperScissors:
        return {
          'player1Choice': null,
          'player2Choice': null,
          'player1Score': 0,
          'player2Score': 0,
          'round': 1,
        };
      case GameType.hangman:
        return {
          'secretWord': '',
          'guessedLetters': <String>[],
          'wrongGuesses': 0,
        };
      case GameType.wordBlitz:
        return {
          'letters': <String>[],
          'player1Word': '',
          'player2Word': '',
          'player1Score': 0,
          'player2Score': 0,
          'currentPlayer': 1,
        };
    }
  }

  /// Listen to game session updates
  Stream<GameSession?> listenToSession(String sessionId) {
    return _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .snapshots()
        .map((doc) => doc.exists ? GameSession.fromMap(doc.data()!) : null);
  }

  /// Update game state
  Future<void> updateGameState(
    String sessionId,
    Map<String, dynamic> gameState, {
    String? nextTurnId,
    GameStatus? status,
    String? winnerId,
  }) async {
    final updates = <String, dynamic>{
      'gameState': gameState,
    };

    if (nextTurnId != null) updates['currentTurnId'] = nextTurnId;
    if (status != null) updates['status'] = status.name;
    if (winnerId != null) updates['winnerId'] = winnerId;

    await _firestore
        .collection('game_sessions')
        .doc(sessionId)
        .update(updates);
  }

  /// Clean up subscriptions
  void dispose() {
    _queueSubscription?.cancel();
    _roomSubscription?.cancel();
  }
}
