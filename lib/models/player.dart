import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String oderId;
  final String username;
  final int wins;
  final int losses;
  final DateTime createdAt;

  Player({
    required this.oderId,
    required this.username,
    this.wins = 0,
    this.losses = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get totalGames => wins + losses;
  double get winRate => totalGames > 0 ? wins / totalGames : 0;

  Map<String, dynamic> toMap() {
    return {
      'oderId': oderId,
      'username': username,
      'wins': wins,
      'losses': losses,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      oderId: map['oderId'] ?? '',
      username: map['username'] ?? '',
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Player copyWith({
    String? oderId,
    String? username,
    int? wins,
    int? losses,
  }) {
    return Player(
      oderId: oderId ?? this.oderId,
      username: username ?? this.username,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      createdAt: createdAt,
    );
  }
}
