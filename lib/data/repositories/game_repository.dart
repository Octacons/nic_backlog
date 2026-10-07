import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nic_backlog/data/models/game_model.dart';

class GameRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GameRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User belum login.");
    return user.uid;
  }

  Future<void> addGame(GameModel game) async {
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('games')
          .add(game.toMap());
    } catch (e) {
      throw Exception("Gagal menambahkan game: ${e.toString()}");
    }
  }
}
