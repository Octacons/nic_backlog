import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nic_backlog/data/models/game_model.dart';

class GameRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GameRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User belum login.");
    return user.uid;
  }

  Future<String> uploadGameCover(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception("File gambar tidak ditemukan di penyimpanan lokal.");
      }

      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final formattedBase64 = 'data:image/jpeg;base64,$base64String';

      return formattedBase64;
    } catch (e) {
      throw Exception("Gagal memproses gambar: ${e.toString()}");
    }
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

  Future<List<GameModel>> fetchGames() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('games')
          .get();

      return snapshot.docs
          .map((doc) => GameModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception("Gagal mengambil data game: ${e.toString()}");
    }
  }
}
