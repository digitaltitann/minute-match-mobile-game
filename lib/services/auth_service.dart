import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usernameKey = 'username';

  Player? _currentPlayer;
  Player? get currentPlayer => _currentPlayer;

  String? get oderId => _auth.currentUser?.uid;
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign in anonymously and load/create player profile
  Future<Player?> signIn() async {
    try {
      // Sign in anonymously if not already signed in
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      final uid = _auth.currentUser!.uid;

      // Try to load existing player from Firestore
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        _currentPlayer = Player.fromMap(doc.data()!);
      } else {
        // Check for stored username
        final prefs = await SharedPreferences.getInstance();
        final username = prefs.getString(_usernameKey);

        if (username != null) {
          // Create new player with stored username
          _currentPlayer = Player(oderId: uid, username: username);
          await _savePlayerToFirestore();
        }
      }

      return _currentPlayer;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  /// Check if user has set a username
  Future<bool> hasUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) != null;
  }

  /// Get stored username
  Future<String?> getStoredUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /// Set username for current user
  Future<bool> setUsername(String username) async {
    try {
      if (_auth.currentUser == null) {
        await signIn();
      }

      final uid = _auth.currentUser!.uid;

      // Store locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);

      // Create/update player
      _currentPlayer = Player(
        oderId: uid,
        username: username,
        wins: _currentPlayer?.wins ?? 0,
        losses: _currentPlayer?.losses ?? 0,
      );

      // Save to Firestore
      await _savePlayerToFirestore();

      return true;
    } catch (e) {
      print('Error setting username: $e');
      return false;
    }
  }

  /// Save current player to Firestore
  Future<void> _savePlayerToFirestore() async {
    if (_currentPlayer == null) return;

    await _firestore
        .collection('users')
        .doc(_currentPlayer!.oderId)
        .set(_currentPlayer!.toMap());
  }

  /// Update player stats after a game
  Future<void> updateStats({required bool won}) async {
    if (_currentPlayer == null) return;

    _currentPlayer = _currentPlayer!.copyWith(
      wins: won ? _currentPlayer!.wins + 1 : _currentPlayer!.wins,
      losses: won ? _currentPlayer!.losses : _currentPlayer!.losses + 1,
    );

    await _savePlayerToFirestore();
  }

  /// Sign out (clears local session but keeps username)
  Future<void> signOut() async {
    await _auth.signOut();
    _currentPlayer = null;
  }
}
