import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nic_backlog/data/models/game_model.dart';
import 'package:nic_backlog/utils/app_logger.dart';

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
    if (user == null) {
      AppLogger.log(
        '[AUTH] Gagal: User belum login / session kosong',
        name: 'GameRepository._currentUserId',
      );
      throw Exception("User belum login.");
    }
    return user.uid;
  }

  Future<String> uploadGameCover(File imageFile) async {
    const logTag = 'GameRepository.uploadGameCover';
    try {
      AppLogger.request(
        'Memproses file cover: ${imageFile.path}',
        name: logTag,
      );

      if (!await imageFile.exists()) {
        throw Exception("File gambar tidak ditemukan di penyimpanan lokal.");
      }

      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final formattedBase64 = 'data:image/jpeg;base64,$base64String';

      AppLogger.response(
        'Berhasil encode base64 (Ukuran file: ${bytes.lengthInBytes} bytes)',
        name: logTag,
      );

      return formattedBase64;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Gagal memproses gambar: $e',
        name: logTag,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception("Gagal memproses gambar: ${e.toString()}");
    }
  }

  Future<void> addGame(GameModel game) async {
    const logTag = 'GameRepository.addGame';
    try {
      final payload = game.toMap();
      AppLogger.request(
        'Menambahkan game baru untuk User [$_currentUserId]:\nPayload: $payload',
        name: logTag,
      );

      final docRef = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('games')
          .add(payload);

      AppLogger.response(
        'Sukses menambahkan game! Document ID: ${docRef.id}',
        name: logTag,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Gagal menambahkan game: $e',
        name: logTag,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception("Gagal menambahkan game: ${e.toString()}");
    }
  }

  Future<List<GameModel>> fetchGames() async {
    const logTag = 'GameRepository.fetchGames';
    try {
      AppLogger.request(
        'Mengambil daftar game untuk User [$_currentUserId]...',
        name: logTag,
      );

      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('games')
          .get();

      AppLogger.response(
        'Sukses mengambil game. Total item: ${snapshot.docs.length}',
        name: logTag,
      );

      return snapshot.docs
          .map((doc) => GameModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Gagal mengambil data game: $e',
        name: logTag,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception("Gagal mengambil data game: ${e.toString()}");
    }
  }

  Future<GameModel> fetchGameById(String gameId) async {
    const logTag = 'GameRepository.fetchGameById';
    try {
      AppLogger.request(
        'Mengambil detail game [$gameId] untuk User [$_currentUserId]...',
        name: logTag,
      );

      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('games')
          .doc(gameId)
          .get();

      if (!doc.exists) {
        AppLogger.error(
          'Game ID [$gameId] tidak ditemukan di Firestore',
          name: logTag,
        );
        throw Exception("Game tidak ditemukan.");
      }

      AppLogger.response('Dokumen game ditemukan: ${doc.data()}', name: logTag);

      return GameModel.fromMap(doc.data()!, doc.id);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Gagal mengambil detail game [$gameId]: $e',
        name: logTag,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception("Gagal mengambil detail game: ${e.toString()}");
    }
  }

  Future<void> updateGame({required GameModel game, File? imageFile}) async {
    const tag = 'GameRepository.updateGame';
    try {
      String finalImageUrl = game.imageUrl;
      if (imageFile != null) {
        AppLogger.request(
          'Mengupload/memproses cover baru untuk game [${game.id}]',
          name: tag,
        );
        finalImageUrl = await uploadGameCover(imageFile);
      }

      final updatedGame = game.copyWith(imageUrl: finalImageUrl);
      final payload = updatedGame.toMap();

      AppLogger.request(
        'Mengupdate dokumen game [${game.id}] untuk User [$_currentUserId]',
        name: tag,
        data: payload,
      );

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('games')
          .doc(game.id)
          .update(payload);

      AppLogger.response('Game [${game.id}] berhasil diupdate', name: tag);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Gagal mengupdate game [${game.id}]: $e',
        name: tag,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception("Gagal mengupdate game: ${e.toString()}");
    }
  }
}
