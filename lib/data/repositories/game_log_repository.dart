import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nic_backlog/data/models/game_log_model.dart';
import 'package:nic_backlog/utils/app_logger.dart';

class GameLogRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GameLogRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      AppLogger.error(
        '[AUTH] Gagal: User belum login / session kosong',
        name: 'GameLogRepository._currentUserId',
      );
      throw Exception("User belum login.");
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _logsCollection(String gameId) {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('games')
        .doc(gameId)
        .collection('logs');
  }

  Future<List<GameLogModel>> fetchGameLogs(String gameId) async {
    const logTag = 'GameLogRepository.fetchGameLogs';
    try {
      AppLogger.request('Mengambil logs untuk game [$gameId]...', name: logTag);

      final snapshot = await _logsCollection(
        gameId,
      ).orderBy('date', descending: true).get();

      AppLogger.response(
        'Sukses mengambil logs game [$gameId]. Total logs: ${snapshot.docs.length}',
        name: logTag,
      );

      return snapshot.docs
          .map((doc) => GameLogModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Gagal mengambil log game [$gameId]: $e',
        name: logTag,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception("Gagal mengambil log game: ${e.toString()}");
    }
  }

  Future<void> addGameLog(String gameId, GameLogModel log) async {
    const logTag = 'GameLogRepository.addGameLog';
    try {
      final payload = log.toMap();
      AppLogger.request(
        'Menambahkan log baru ke game [$gameId]:\nPayload: $payload',
        name: logTag,
      );

      final docRef = await _logsCollection(gameId).add(payload);

      AppLogger.response(
        'Sukses menambahkan log! Document ID: ${docRef.id}',
        name: logTag,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Gagal menambahkan log ke game [$gameId]: $e',
        name: logTag,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception("Gagal menambahkan log: ${e.toString()}");
    }
  }

  Future<void> deleteGameLog(String gameId, String logId) async {
    const logTag = 'GameLogRepository.deleteGameLog';
    try {
      AppLogger.request(
        'Menghapus log [$logId] dari game [$gameId]',
        name: logTag,
      );

      await _logsCollection(gameId).doc(logId).delete();

      AppLogger.response('Sukses menghapus log [$logId]', name: logTag);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Gagal menghapus log [$logId]: $e',
        name: logTag,
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception("Gagal menghapus log: ${e.toString()}");
    }
  }
}
