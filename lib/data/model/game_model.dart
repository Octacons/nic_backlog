import 'package:nic_backlog/data/model/gamelog_model.dart';

enum GameStatus { playing, completed, backlogged, dropped }

class GameModel {
  final String id;
  final String title;
  final String imageUrl;
  final String genre;
  final String description;
  final DateTime releaseDate;
  final GameStatus status;
  final double overallRating;
  final List<GameLogModel> logs;
  GameModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.genre,
    required this.description,
    required this.releaseDate,
    required this.status,
    this.overallRating = 0.0,
    this.logs = const [],
  });

  static GameStatus _stringToStatus(String statusStr) {
    switch (statusStr) {
      case 'playing':
        return GameStatus.playing;
      case 'completed':
        return GameStatus.completed;
      case 'dropped':
        return GameStatus.dropped;
      default:
        return GameStatus.backlogged;
    }
  }

  factory GameModel.fromMap(
    Map<String, dynamic> map,
    String docId, {
    List<GameLogModel>? logs,
  }) {
    return GameModel(
      id: docId,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      genre: map['genre'] ?? '',
      description: map['description'] ?? '',
      releaseDate: DateTime.parse(map['releaseDate']),
      status: _stringToStatus(map['status'] ?? 'backlogged'),
      overallRating: (map['overallRating'] as num?)?.toDouble() ?? 0.0,
      logs: logs ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'genre': genre,
      'description': description,
      'releaseDate': releaseDate.toIso8601String(),
      'status': status.name,
      'overallRating': overallRating,
    };
  }
}
