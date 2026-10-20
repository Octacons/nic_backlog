import 'package:nic_backlog/data/models/game_log_model.dart';

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

  GameModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.genre,
    required this.description,
    required this.releaseDate,
    required this.status,
    this.overallRating = 0.0,
  });

  static GameStatus _stringToStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
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
      releaseDate: map['releaseDate'] != null
          ? DateTime.tryParse(map['releaseDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: _stringToStatus(map['status'] ?? 'backlogged'),
      overallRating: (map['overallRating'] as num?)?.toDouble() ?? 0.0,
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

  GameModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? genre,
    String? description,
    DateTime? releaseDate,
    GameStatus? status,
    double? overallRating,
    List<GameLogModel>? logs,
  }) {
    return GameModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      releaseDate: releaseDate ?? this.releaseDate,
      status: status ?? this.status,
      overallRating: overallRating ?? this.overallRating,
    );
  }
}
