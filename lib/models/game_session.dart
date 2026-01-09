import 'package:cloud_firestore/cloud_firestore.dart';
import 'player.dart';

enum GameType {
  ticTacToe,
  rockPaperScissors,
  connectFour,
  hangman,
  wordBlitz,
}

enum GameStatus {
  waiting,    // Waiting for second player
  playing,    // Game in progress
  finished,   // Game completed
}

class GameSession {
  final String sessionId;
  final GameType gameType;
  final Player player1;
  final Player? player2;
  final String? currentTurnId;
  final Map<String, dynamic> gameState;
  final GameStatus status;
  final String? winnerId;
  final String? roomCode;
  final DateTime createdAt;

  GameSession({
    required this.sessionId,
    required this.gameType,
    required this.player1,
    this.player2,
    this.currentTurnId,
    Map<String, dynamic>? gameState,
    this.status = GameStatus.waiting,
    this.winnerId,
    this.roomCode,
    DateTime? createdAt,
  }) : gameState = gameState ?? {},
       createdAt = createdAt ?? DateTime.now();

  bool get isPlayer1Turn => currentTurnId == player1.oderId;
  bool get isWaitingForPlayer => status == GameStatus.waiting;
  bool get isPlaying => status == GameStatus.playing;
  bool get isFinished => status == GameStatus.finished;
  bool get isFull => player2 != null;

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'gameType': gameType.name,
      'player1': player1.toMap(),
      'player2': player2?.toMap(),
      'currentTurnId': currentTurnId,
      'gameState': gameState,
      'status': status.name,
      'winnerId': winnerId,
      'roomCode': roomCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      sessionId: map['sessionId'] ?? '',
      gameType: GameType.values.firstWhere(
        (e) => e.name == map['gameType'],
        orElse: () => GameType.ticTacToe,
      ),
      player1: Player.fromMap(map['player1'] ?? {}),
      player2: map['player2'] != null ? Player.fromMap(map['player2']) : null,
      currentTurnId: map['currentTurnId'],
      gameState: Map<String, dynamic>.from(map['gameState'] ?? {}),
      status: GameStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GameStatus.waiting,
      ),
      winnerId: map['winnerId'],
      roomCode: map['roomCode'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  GameSession copyWith({
    String? sessionId,
    GameType? gameType,
    Player? player1,
    Player? player2,
    String? currentTurnId,
    Map<String, dynamic>? gameState,
    GameStatus? status,
    String? winnerId,
    String? roomCode,
  }) {
    return GameSession(
      sessionId: sessionId ?? this.sessionId,
      gameType: gameType ?? this.gameType,
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      currentTurnId: currentTurnId ?? this.currentTurnId,
      gameState: gameState ?? this.gameState,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      roomCode: roomCode ?? this.roomCode,
      createdAt: createdAt,
    );
  }
}
